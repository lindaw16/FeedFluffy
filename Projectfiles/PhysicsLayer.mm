/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim.
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).*
 *
 * PhysicsLayer.mm
 * TheRealFluffy
 *
 *
 */

#import "PhysicsLayer.h"
#import "Box2D.h"
#import "Box2DDebugLayer.h"
#import "cocos2d.h"
#import "Fluffy.h"
#import "OopsDNE.h"
#import "Fruit.h"
#import "Obstacle.h"

//#import "cocos2d.m"


/*
 * Sprite Tags
 * 1: hungry eevee
 * 2: hungry eevee mouth
 * 3: the cannon
 * 4: the bullet
 */

/* BUG LIST
 * the bullets dont bounce off the sides..
 *
 */


//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
const float PTM_RATIO = 32.0f;

const int TILESIZE = 32;
const int TILESET_COLUMNS = 9;
const int TILESET_ROWS = 19;
const int cageLeft = 30;
const int cageBottom = 60;
int bulletCounter = 300;
int cannonRadius = 5.0/PTM_RATIO;
bool ButtonTapped = false;

float angleRadians;
float angleInDegrees;
float realMoveDuration;
b2BodyDef ballBodyDef;
b2Body *_body;
CGPoint realDest;
BOOL levelCompleted;

NSDictionary *goal;
NSMutableDictionary *goalProgress  = [[NSMutableDictionary alloc] init];

@interface PhysicsLayer (PrivateMethods)
-(void) enableBox2dDebugDrawing;
-(void) addSomeJoinedBodies:(CGPoint)pos;
-(void) addNewSpriteAt:(CGPoint)p;
-(b2Vec2) toMeters:(CGPoint)point;
-(CGPoint) toPixels:(b2Vec2)vec;
-(CGSize) winSize;
@end

@implementation PhysicsLayer
{
    
}

+(id) sceneWithLevel:(int)level
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
    PhysicsLayer *layer = [[PhysicsLayer alloc] initWithLevel:level];
	[scene addChild: layer];
	return scene;
}

- (id)initWithLevel: (int) level {
    
    if ((self = [super initWithColor:ccc4(255,255,255,255)])) {
        
        _MoveableSpriteTouch=FALSE;
        self.touchEnabled = YES;
        
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        
        //no gravity -- Do we still need this then?
        b2Vec2 gravity = b2Vec2(0.0f, -0.0f);
        world = new b2World(gravity);
        
        
        // Create edges around the entire screen except the one on the left
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0,0);
        
        _groundBody = world->CreateBody(&groundBodyDef);
        b2EdgeShape groundBox;
        b2FixtureDef groundBoxDef;
        groundBoxDef.shape = &groundBox;
        
        groundBox.Set(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO, 0));
        _groundBody->CreateFixture(&groundBoxDef);
        
        
//        groundBox.Set(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
//        _groundBody->CreateFixture(&groundBoxDef);
//        
        //adding this back in case we need it later
        //groundBox.Set(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
        //_groundBody->CreateFixture(&groundBoxDef);
        
        
        groundBox.Set(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
        _groundBody->CreateFixture(&groundBoxDef);
        
        groundBox.Set(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 0));
        _groundBody->CreateFixture(&groundBoxDef);
        
        
        
        
        _player = [CCSprite spriteWithFile:@"cannon-body2.png"];
        _player.position = ccp(_player.contentSize.width/2 - 4, winSize.height/2 + 32);
        
        
        [self addChild:_player z:1];
        
    
        
        cannonHead = [CCSprite spriteWithFile:@"cannon-head-cropped.png"];
        cannonHead.position = ccp(_player.position.x + 30, _player.position.y - 0.5);
        int asdf = cannonHead.position.x;
        int fdsa = cannonHead.position.y;
        [self addChild:cannonHead z:1];
        
        
        
        
        // Create contact listener
        _contactListener = new MyContactListener();
        world->SetContactListener(_contactListener);
        
        
        //Adding "Launch" button so player can click on it to launch bullet/projectile
        
        // Standard method to create a button
        CCMenuItem *starMenuItem = [CCMenuItemImage
                                    itemFromNormalImage:@"ButtonStar.png" selectedImage:@"ButtonStarSel.png"
                                    target:self selector:@selector(starButtonTapped:)];
        starMenuItem.position = ccp(winSize.width - 40, 30);
        CCMenu *starMenu = [CCMenu menuWithItems:starMenuItem, nil];
        starMenu.position = CGPointZero;
        [self addChild:starMenu z:2];
        
        CCSprite *meep = [CCSprite spriteWithFile:@"gameBackground.png"];
        meep.anchorPoint = CGPointZero;
        [self addChild:meep z:-1];
        
        CCSprite *bar = [CCSprite spriteWithFile: @"gameBar.png"];
        bar.position = ccp(winSize.width / 2, 20);
        [self addChild:bar z:1];
        

        

        // plist level creation stuff
        
        NSString* levelString = [NSString stringWithFormat:@"%i", level];
        NSString *levelName = [@"level" stringByAppendingString:levelString];
        NSString *path = [[NSBundle mainBundle] pathForResource:levelName ofType:@"plist"];
        NSDictionary *level = [NSDictionary dictionaryWithContentsOfFile:path];
        
        goal = [level objectForKey:@"Goal"];
        
        // create new dictionary that keeps track of the level progress
        
        for (NSString *key in goal){
            [goalProgress setObject:@0 forKey:key];
        }
        
        NSDictionary *fluffy = [level objectForKey:@"Fluffy"];
        Fluffy *fluffy2 = [[Fluffy alloc] initWithFluffyImage];
        NSNumber *x = [fluffy objectForKey:@"x"];
        NSNumber *y = [fluffy objectForKey:@"y"];
        fluffy2.position = CGPointMake([x floatValue], [y floatValue]);
        fluffy2.tag = 3;
        
        [self addChild:fluffy2 z:1];
        
        // Create block body
        b2BodyDef fluffyBodyDef;
        fluffyBodyDef.type = b2_dynamicBody;
        fluffyBodyDef.position.Set([x floatValue]/PTM_RATIO, [y floatValue]/PTM_RATIO);
        fluffyBodyDef.userData = (__bridge void*)fluffy2;
        b2Body *fluffyBody = world->CreateBody(&fluffyBodyDef);
        
        // Create block shape
        b2PolygonShape fluffyShape;
        fluffyShape.SetAsBox(fluffy2.contentSize.width/PTM_RATIO/2,
                            fluffy2.contentSize.height/PTM_RATIO/2);
        
        // Create shape definition and add to body
        b2FixtureDef fluffyShapeDef;
        fluffyShapeDef.shape = &fluffyShape;
        fluffyShapeDef.density = 10.0;
        fluffyShapeDef.friction = 0.0;
        fluffyShapeDef.restitution = 0.1f;
        fluffyShapeDef.isSensor = true;
        fluffyBody->CreateFixture(&fluffyShapeDef);
        
        if ([level objectForKey:@"Obstacles"]){
            NSArray *obstacles= [level objectForKey:@"Obstacles"];
            for (NSDictionary *obstacle in obstacles){
                NSString *sName = [obstacle objectForKey:@"spriteName"];
                Obstacle *obstacle2 = [[Obstacle alloc] initWithObstacle: sName];
                NSNumber *x = [obstacle objectForKey:@"x"];
                NSNumber *y = [obstacle objectForKey:@"y"];
                obstacle2.position = CGPointMake([x floatValue], [y floatValue]);
                obstacle2.tag = 4;
            
                [self addChild:obstacle2 z:1];
            
                // Create block body
                b2BodyDef obstacleBodyDef;
                obstacleBodyDef.type = b2_staticBody;
                obstacleBodyDef.position.Set([x floatValue]/PTM_RATIO, [y floatValue]/PTM_RATIO);
                obstacleBodyDef.userData = (__bridge void*)obstacle2;
                b2Body *obstacleBody = world->CreateBody(&obstacleBodyDef);
            
                // Create block shape
                b2PolygonShape obstacleShape;
                obstacleShape.SetAsBox(obstacle2.contentSize.width/PTM_RATIO/2,
                                 obstacle2.contentSize.height/PTM_RATIO/2);
            
                // Create shape definition and add to body
                b2FixtureDef obstacleShapeDef;
                obstacleShapeDef.shape = &obstacleShape;
                obstacleShapeDef.density = 10.0;
                obstacleShapeDef.friction = 0.0;
                obstacleShapeDef.restitution = 0.1f;
                obstacleShapeDef.isSensor = false;
                obstacleBody->CreateFixture(&obstacleShapeDef);
            }
        }
        
        NSArray *fruits = [level objectForKey:@"Fruits"];
        
        for (NSDictionary *fruit in fruits){
            NSString *sName = [fruit objectForKey:@"spriteName"];
            //NSString *spriteName = [sName stringByAppendingString:@".png"];
            Fruit *fruit2 = [[Fruit alloc] initWithFruit: sName];
            fruit2.tag = 2;
            NSNumber *x = [fruit objectForKey:@"x"];
            NSNumber *y = [fruit objectForKey:@"y"];
            
            fruit2.position = CGPointMake([x floatValue], [y floatValue]);
            [self addChild:fruit2 z:0];
            
            // Create block body
            b2BodyDef fruitBodyDef;
            fruitBodyDef.type = b2_dynamicBody;
            fruitBodyDef.position.Set([x floatValue]/PTM_RATIO, [y floatValue]/PTM_RATIO);
            fruitBodyDef.userData = (__bridge void*)fruit2;
            b2Body *fruitBody = world->CreateBody(&fruitBodyDef);
            
            // Create block shape
            b2PolygonShape fruitShape;
            fruitShape.SetAsBox(fruit2.contentSize.width/PTM_RATIO/2,
                                fruit2.contentSize.height/PTM_RATIO/2);
            
            // Create shape definition and add to body
            b2FixtureDef fruitShapeDef;
            fruitShapeDef.shape = &fruitShape;
            fruitShapeDef.density = 10.0;
            fruitShapeDef.friction = 0.0;
            fruitShapeDef.restitution = 0.1f;
            fruitShapeDef.isSensor = true;
            fruitBody->CreateFixture(&fruitShapeDef);
        }
        
        
        [self schedule:@selector(tick:)];
        //[self schedule:@selector(kick) interval:5.0];
        [self setTouchEnabled:YES];
        //[self setAccelerometerEnabled:NO];
        
        [self scheduleUpdate];
    }
    return self;
}

// DETECT COLLISIONS BETWEEN BALL AND FOOD!


- (void)starButtonTapped:(id)sender {
    printf("Button tapped!!!!!!\n");
    
    _nextProjectile = [CCSprite spriteWithFile:@"bullet.png"];
    _nextProjectile.tag = 1;
    
    _nextProjectile.position = _player.position;

    // Create ball body and shape
    
    ballBodyDef.type = b2_dynamicBody;
    //            ballBodyDef.position.Set(100/PTM_RATIO, 100/PTM_RATIO);
    NSLog(@"in Position.SET\n");
    ballBodyDef.position.Set(_player.position.x/PTM_RATIO,_player.position.y/PTM_RATIO);
    ballBodyDef.userData = (__bridge void*)_nextProjectile;
    
    _body = world->CreateBody(&ballBodyDef);
    
    b2CircleShape circle;
    //circle.m_radius = 26.0/PTM_RATIO;
    //circle.m_radius = 9.0/PTM_RATIO;
    circle.m_radius = 20.0/PTM_RATIO;
    
    b2FixtureDef ballShapeDef;
    ballShapeDef.shape = &circle;
    ballShapeDef.density = 0.5f;
    ballShapeDef.friction = 0.0f;
    ballShapeDef.restitution = 1.0f;
    _body->CreateFixture(&ballShapeDef);

    
    float radianAngle = CC_DEGREES_TO_RADIANS(angleInDegrees);
    [_player runAction:[CCSequence actions:[CCCallBlock actionWithBlock:^{[self addChild:_nextProjectile];_nextProjectile = nil;}],nil]];
    //this determines the speed of the ball projectile
    b2Vec2 force = b2Vec2(5 * cos(radianAngle), 5 * sin(radianAngle));
    
    //_body->ApplyLinearImpulse(force, ballBodyDef.position);
    printf("Applying Linear Impulse!");
    _body->ApplyLinearImpulse(force, ballBodyDef.position);
    
    // Move projectile to actual endpoint
    /*[_nextProjectile runAction:
     [CCSequence actions:
     [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
     [CCCallBlockN actionWithBlock:^(CCNode *node) {
     [node removeFromParentAndCleanup:YES];
     }],
     nil]];*/
    bulletCounter--;
    ButtonTapped = false;
    
    
}

-(BOOL) checkLevelCompleted {
    //NSLog(@"CHECKING IF LEVEL IS COMPLETED");
    for (NSString *key in goal){
        int goalValue = [[goal objectForKey:key] intValue];
        int goalProgressValue = [[goalProgress objectForKey:key] intValue];
        //NSLog(@"GOAL VALUE");
        //NSLog(@"%d", goalValue);
        if (goalProgressValue < goalValue) {
            return NO;
        }
    }
    return YES;
}


- (void)tick:(ccTime) dt {
    
    world->Step(dt, 10, 10);
    for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *ballData = (__bridge CCSprite *)(b->GetUserData());
            ballData.position = ccp(b->GetPosition().x * PTM_RATIO,
                                    b->GetPosition().y * PTM_RATIO);
            ballData.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            
            // if ball is going too fast, turn on damping
            //we should do this!!
        }
    }
}




-(void) dealloc
{
	delete world;
    _launchLabel = nil;
    //_body = NULL;
    _groundBody = NULL;
    //world = NULL;
    //delete contactListener;
    delete _contactListener;
#ifndef KK_ARC_ENABLED
	[super dealloc];
#endif
}


-(void) enableBox2dDebugDrawing
{
	// Using John Wordsworth's Box2DDebugLayer class now
	// The advantage is that it draws the debug information over the normal cocos2d graphics,
	// so you'll still see the textures of each object.
	const BOOL useBox2DDebugLayer = YES;
    
	
	float debugDrawScaleFactor = 1.0f;
#if KK_PLATFORM_IOS
	debugDrawScaleFactor = [[CCDirector sharedDirector] contentScaleFactor];
#endif
	debugDrawScaleFactor *= PTM_RATIO;
    
	UInt32 debugDrawFlags = 0;
	debugDrawFlags += b2Draw::e_shapeBit;
	debugDrawFlags += b2Draw::e_jointBit;
	//debugDrawFlags += b2Draw::e_aabbBit;
	//debugDrawFlags += b2Draw::e_pairBit;
	//debugDrawFlags += b2Draw::e_centerOfMassBit;
    
	if (useBox2DDebugLayer)
	{
		Box2DDebugLayer* debugLayer = [Box2DDebugLayer debugLayerWithWorld:world
																  ptmRatio:PTM_RATIO
																	 flags:debugDrawFlags];
		[self addChild:debugLayer z:100];
	}
	else
	{
		debugDraw = new GLESDebugDraw(debugDrawScaleFactor);
		if (debugDraw)
		{
			debugDraw->SetFlags(debugDrawFlags);
			world->SetDebugDraw(debugDraw);
		}
	}
}


-(CCSprite*) addRandomSpriteAt:(CGPoint)pos
{
	CCSpriteBatchNode* batch = (CCSpriteBatchNode*)[self getChildByTag:kTagBatchNode];
	
	int idx = CCRANDOM_0_1() * TILESET_COLUMNS;
	int idy = CCRANDOM_0_1() * TILESET_ROWS;
	CGRect tileRect = CGRectMake(TILESIZE * idx, TILESIZE * idy, TILESIZE, TILESIZE);
	CCSprite* sprite = [CCSprite spriteWithTexture:batch.texture rect:tileRect];
	sprite.batchNode = batch;
	sprite.position = pos;
	[batch addChild:sprite];
	
	return sprite;
}

-(void) bodyCreateFixture:(b2Body*)body
{
	// Define another box shape for our dynamic bodies.
	b2PolygonShape dynamicBox;
	float tileInMeters = TILESIZE / PTM_RATIO;
	dynamicBox.SetAsBox(tileInMeters * 0.5f, tileInMeters * 0.5f);
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 0.3f;
	fixtureDef.friction = 0.5f;
	fixtureDef.restitution = 0.6f;
	body->CreateFixture(&fixtureDef);
	
}
int counter = 1;
-(void) addSomeJoinedBodies:(CGPoint)pos
{
	// Create a body definition and set it to be a dynamic body
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	
    
	// position must be converted to meters
	bodyDef.position = [self toMeters:pos];
	bodyDef.position = bodyDef.position + b2Vec2(-1, -1);
	bodyDef.userData = (__bridge void*)[self addRandomSpriteAt:pos];
	b2Body* bodyA = world->CreateBody(&bodyDef);
	[self bodyCreateFixture:bodyA];
	
	bodyDef.position = [self toMeters:pos];
	bodyDef.userData = (__bridge void*)[self addRandomSpriteAt:pos];
	b2Body* bodyB = world->CreateBody(&bodyDef);
	[self bodyCreateFixture:bodyB];
	
	bodyDef.position = [self toMeters:pos];
	bodyDef.position = bodyDef.position + b2Vec2(1, 1);
	bodyDef.userData = (__bridge void*)[self addRandomSpriteAt:pos];
	b2Body* bodyC = world->CreateBody(&bodyDef);
	[self bodyCreateFixture:bodyC];
	
	b2RevoluteJointDef jointDef;
	jointDef.Initialize(bodyA, bodyB, bodyB->GetWorldCenter());
	bodyA->GetWorld()->CreateJoint(&jointDef);
	
	jointDef.Initialize(bodyB, bodyC, bodyC->GetWorldCenter());
	bodyA->GetWorld()->CreateJoint(&jointDef);
	
	// create an invisible static body to attach to
	bodyDef.type = b2_staticBody;
	bodyDef.position = [self toMeters:pos];
	b2Body* staticBody = world->CreateBody(&bodyDef);
	jointDef.Initialize(staticBody, bodyA, bodyA->GetWorldCenter());
	bodyA->GetWorld()->CreateJoint(&jointDef);
}

-(void) addNewSpriteAt:(CGPoint)pos
{
	// Create a body definition and set it to be a dynamic body
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	
	// position must be converted to meters
	bodyDef.position = [self toMeters:pos];
	
	// assign the sprite as userdata so it's easy to get to the sprite when working with the body
	bodyDef.userData = (__bridge void*)[self addRandomSpriteAt:pos];
	b2Body* body = world->CreateBody(&bodyDef);
	
	[self bodyCreateFixture:body];
}

-(void) update:(ccTime)delta
{
    
	CCDirector* director = [CCDirector sharedDirector];
    
    //do we have to check the current platform stuff?
    
    //Create an instance called input of Kobold2D's built-in super easy to use touch processor
    KKInput* input = [KKInput sharedInput];
    
    //Create a point, pos, by asking input, our touch processor, where there has been a touch
    CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
    
    int x = pos.x;
    int y = pos.y;
    
    CGPoint location;
    CGSize winSize;
    if (input.anyTouchBeganThisFrame) //someone's touching the screen!! :O
    {
        printf("ANY-TOUCH-BEGAN-THIS-FRAME");
        //Checking if 3 bullets have already been used - if so, then no more bullet are thrown.
        if  (bulletCounter<=0) return;
        
        _MoveableSpriteTouch = FALSE;
        
        // Choose one of the touches to work with
                
        location = [self convertToNodeSpace:pos];
        //CGRect leftBorder = CGRectMake(cageLeft, 0, cageLeft+10, 350);
        
    }
    
    else if (input.anyTouchEndedThisFrame)
    {
        printf("ended frame..........\n");
    }
    
    
    else if (input.touchesAvailable)
    {
        //pos.x <= cageLeft
        if (CGRectContainsPoint(_player.boundingBox, pos))
        {
            if (pos.y < 280 && pos.y > cageBottom + 20)
            {
                printf("CANNON BEING MOVEDDDD>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n");
                _player.position = ccp(_player.position.x, y+5);
                _nextProjectile.position = _player.position;
                cannonHead.position = ccp(cannonHead.position.x, y);
            }
        }
        
        
        if (pos.x>=cageLeft+5 and pos.x <=80 )
        {
            //make sure the cannon does not move offscreen
            
            float deltaY = pos.y - _player.position.y;
            float deltaX = pos.x - _player.position.x;
            
            // Bail out if you are shooting down or backwards
            //if (offset.x <= 0) return;
            angleInDegrees = atan2(deltaY, deltaX) * 180 / M_PI;
            
            
            if ( angleInDegrees < 50 && angleInDegrees > -50)
            {
                //dont let the cannon rotate too far
                
                if (counter ==1){
                    
                    cannonHead.position = ccp(cannonHead.position.x - 10.0, cannonHead.position.y - 2.0);
                    counter = 0;
                }
                cannonHead.anchorPoint = ccp(0.3,0.3);
                cannonHead.rotation = -angleInDegrees;
            }
        }
    }
    
///I really dont believe we need thisVVVV
    
	if (director.currentPlatformIsIOS)
	{
		KKInput* input = [KKInput sharedInput];
		if (director.currentDeviceIsSimulator == NO)
		{
			KKAcceleration* acceleration = input.acceleration;
			//CCLOG(@"acceleration: %f, %f", acceleration.rawX, acceleration.rawY);
			b2Vec2 gravity = 10.0f * b2Vec2(acceleration.rawX, acceleration.rawY);
			world->SetGravity(gravity);
		}
        
		if (input.anyTouchEndedThisFrame)
		{
			//[self addNewSpriteAt:[input locationOfAnyTouchInPhase:KKTouchPhaseEnded]];
		}
	}
	else if (director.currentPlatformIsMac)
	{
		KKInput* input = [KKInput sharedInput];
		if (input.isAnyMouseButtonUpThisFrame || CGPointEqualToPoint(input.scrollWheelDelta, CGPointZero) == NO)
		{
			[self addNewSpriteAt:input.mouseLocation];
		}
	}
    
    
    
	
	// The number of iterations influence the accuracy of the physics simulation. With higher values the
	// body's velocity and position are more accurately tracked but at the cost of speed.
	// Usually for games only 1 position iteration is necessary to achieve good results.
	float timeStep = 0.03f;
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	world->Step(timeStep, velocityIterations, positionIterations);
	
	// for each body, get its assigned sprite and update the sprite's position
	for (b2Body* body = world->GetBodyList(); body != nil; body = body->GetNext())
	{
		CCSprite* sprite = (__bridge CCSprite*)body->GetUserData();
		if (sprite != NULL)
		{
			// update the sprite's position to where their physics bodies are
			sprite.position = [self toPixels:body->GetPosition()];
			float angle = body->GetAngle();
			sprite.rotation = CC_RADIANS_TO_DEGREES(angle) * -1;
		}
	}
    
    //check contacts
    //check contacts
    std::vector<b2Body *>toDestroy;
    std::vector<MyContact>::iterator pos2;
    for (pos2=_contactListener->_contacts.begin();
         pos2 != _contactListener->_contacts.end(); ++pos2) {
        MyContact contact = *pos2;
        
        /*if ((contact.fixtureA == _bottomFixture && contact.fixtureB == _ballFixture) ||
         (contact.fixtureA == _ballFixture && contact.fixtureB == _bottomFixture)) {
         //NSLog(@"Ball hit bottom!");
         CCScene *gameOverScene = [GameOverLayer sceneWithWon:NO];
         [[CCDirector sharedDirector] replaceScene:gameOverScene];
         }*/
        
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
            CCSprite *spriteA = (__bridge CCSprite *) bodyA->GetUserData();
            CCSprite *spriteB = (__bridge CCSprite *) bodyB->GetUserData();
            
            //Sprite A = ball, Sprite B = fruit
            if (spriteA.tag == 1 && [spriteB isKindOfClass:[Fruit class]]) {
            //if (spriteA.tag == 1 && spriteB.tag == 2) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) == toDestroy.end()) {
                    toDestroy.push_back(bodyB);
                    
                    Fruit *fruit = (Fruit*) spriteB;
                    NSString *fruitName = fruit.fruitName;
                    NSLog(fruitName);
                    int num = [[goal objectForKey:fruitName] intValue];
                    NSLog(@"%d", num);
                    int fruitNum = [[goalProgress objectForKey:fruitName] intValue];
                    NSLog(@"%d", fruitNum);
                    fruitNum++;
                    [goalProgress setObject:[NSNumber numberWithInt: fruitNum] forKey:fruitName];
                    int fruitNum2 = [[goalProgress objectForKey:fruitName] intValue];
                    NSLog(@"Hit Fruit");
                }
            }
            
            //Sprite A = fruit, Sprite B = ball
            else if ([spriteA isKindOfClass:[Fruit class]] && spriteB.tag == 1) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end()) {
                    toDestroy.push_back(bodyA);
                    Fruit *fruit = (Fruit*) spriteA;
                    NSString *fruitName = fruit.fruitName;
                    NSLog(fruitName);
                    int num = [[goal objectForKey:fruitName] intValue];
                    NSLog(@"%d", num);
                    int fruitNum = [[goalProgress objectForKey:fruitName] intValue];
                    NSLog(@"%d", fruitNum);
                    fruitNum++;
                    [goalProgress setObject:[NSNumber numberWithInt: fruitNum] forKey:fruitName];
                    int fruitNum2 = [[goalProgress objectForKey:fruitName] intValue];
                    NSLog(@"Hit Fruit");
                }
            }
            
            //Sprite A = ball, Sprite B = fluffy
            else if (spriteA.tag == 1 && [spriteA isKindOfClass:[Fluffy class]]) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) == toDestroy.end()) {
                    toDestroy.push_back(bodyA);
                    BOOL levelCompleted = [self checkLevelCompleted];

                    if (levelCompleted){
                        [[CCDirector sharedDirector] replaceScene: (CCScene*)[[OopsDNE alloc] init]];
                        counter = 1;
                    }
                
                    else {
                        NSLog(@"YOU DIDN'T BEAT THE LEVEL!");
                    }
                    NSLog(@"Hit Fluffy!");
                }

            }
            
            //Sprite A = fluffy, Sprite B = ball
            else if ([spriteA isKindOfClass:[Fluffy class]] && spriteB.tag == 1) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end()) {
                    toDestroy.push_back(bodyB);

                    NSLog(@"Hit Fluffy!");
                    levelCompleted = [self checkLevelCompleted];
                
                    if (levelCompleted){
                        [[CCDirector sharedDirector] replaceScene: (CCScene*)[[OopsDNE alloc] init]];
                        counter = 1;
                    }
                
                    else {
                        NSLog(@"YOU DIDN'T BEAT THE LEVEL!");
                    }
                NSLog(@"Hit Fluffy!");
                }
            }
        }
    }
    
    std::vector<b2Body *>::iterator pos3;
    for (pos3 = toDestroy.begin(); pos3 != toDestroy.end(); ++pos3) {
        b2Body *body = *pos3;
        if (body->GetUserData() != NULL) {
            CCSprite *sprite = (__bridge CCSprite *) body->GetUserData();
            [self removeChild:sprite cleanup:YES];
        }
        world->DestroyBody(body);
    }
    //[self detectCollisions];
}


// convenience method to convert a CGPoint to a b2Vec2
-(b2Vec2) toMeters:(CGPoint)point
{
	return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}

// convenience method to convert a b2Vec2 to a CGPoint
-(CGPoint) toPixels:(b2Vec2)vec
{
	return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}

/*
 #if DEBUG
 -(void) draw
 {
 [super draw];
 
 if (debugDraw)
 {
 ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
 kmGLPushMatrix();
 world->DrawDebugData();
 kmGLPopMatrix();
 }
 }
 #endif
 */



-(void) draw
{
    //draw the cage
    ccColor4F buttonColor = ccc4f(0, 0.5, 0.5, 0.5);
    
    int x = cageLeft;
    int y = 0;
    //why can't I use winSize here?
    ccDrawSolidRect( ccp(x, y), ccp(x + 10, y+ 350) , buttonColor);
    
    int barx = 0;
    int bary = cageBottom;
    
    ccColor4F bottomColor = ccc4f(0, 0, 0, 1);
    ccDrawSolidRect( ccp(barx, bary), ccp(480, bary + 5), bottomColor);    
}

@end