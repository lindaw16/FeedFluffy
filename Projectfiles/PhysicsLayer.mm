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
#import "GameLayer.h"
#import "Fluffy.h"
#import "OopsDNE.h"

//#import "cocos2d.m"


/*
 * Sprite Tags
 * 1: hungry eevee
 * 2: hungry eevee mouth
 * 3: the cannon
 * 4: the bullet
 */

/* BUG LIST
 * you can drag the cannon off the screen!
 * the bullets dont bounce off the sides..
 *
 *
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
int bulletCounter = 300;

NSMutableArray *foodObjects = [[NSMutableArray alloc] init];
NSMutableArray *balls = [[NSMutableArray alloc] init];
CCSprite *ball;

CCSprite *food;
CGRect firstrect;
CGRect secondrect;


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
    //Used these variables when trying to drag cannon along y-axis - but unforunately didn't work :(
    CGPoint po;
    CGFloat poMinX;
    CGFloat poMaxX;
}

/*+(id) scene {
    CCScene *scene = [CCScene node];
    PhysicsLayer *layer = [PhysicsLayer node];
    [scene addChild:layer];
    return scene;
}*/

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
        
        UIRotationGestureRecognizer *rot = [[UIRotationGestureRecognizer alloc] initWithTarget:_player action:@selector(handleRotation:)];
        
        [rot setDelegate:(id)self];
        [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:rot];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        

        //no gravity -- Do we still need this then?
        b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
        world = new b2World(gravity);
        
        
        // Create edges around the entire screen except the one on the left
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0,0);
        _groundBody = world->CreateBody(&groundBodyDef);
        
        b2EdgeShape groundBox;
        b2FixtureDef groundBoxDef;
        groundBoxDef.shape = &groundBox;
        
        groundBox.Set(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO, 0));
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);
        
        groundBox.Set(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
        _groundBody->CreateFixture(&groundBoxDef);
        
        //adding this back in case we need it later
        //groundBox.Set(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
        //_groundBody->CreateFixture(&groundBoxDef);
        
        
        groundBox.Set(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
        _groundBody->CreateFixture(&groundBoxDef);
        
        groundBox.Set(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 0));
        _groundBody->CreateFixture(&groundBoxDef);

        
        
//okay player2 was kinda confusing. I'm going to change this to "cannon"
        _player = [CCSprite spriteWithFile:@"cannon2.png"];
        _player.position = ccp(_player.contentSize.width/2, winSize.height/2);
        
        
        [self addChild:_player];
        
        
        
//will be removing this later right? --edit: i removed it :P
        // Create the ball and add it to the layer
//        ball = [CCSprite spriteWithFile:@"projectile.png" rect:CGRectMake(0, 0, 52, 52)];
//        ball.position = ccp(0, 0);
//        [balls addObject:ball];
        
        CCSprite *meep = [CCSprite spriteWithFile:@"gameBackground.png"];
        meep.anchorPoint = CGPointZero;
        [self addChild:meep z:-1];

        movableSprites = [[NSMutableArray alloc] init];
        NSArray *images = [NSArray arrayWithObjects:@"hungryEevee.png", @"hungryEeveeMouth.png", @"dog.png", @"turtle.png", nil];
        
        
        //Create a hungry eevee and add it to layer
        /*CCSprite *hungryEevee = [CCSprite spriteWithFile: @"hungryEevee.png"];
        hungryEevee.position = ccp(winSize.width - 10, winSize.height/2);
        [self addChild:hungryEevee z:0 tag:2];
        
        //Create the hungry eevee mouth -- useful to detect collision
        
        CCSprite *hungryEeveeMouth = [CCSprite spriteWithFile: @"hungryEeveeMouth.png"];
        hungryEeveeMouth.position = ccp(450, 148);
        [self addChild:hungryEeveeMouth z:-1 tag:1];*/
        

        
        NSString* levelString = [NSString stringWithFormat:@"%i", level];
        NSString *levelName = [@"level" stringByAppendingString:levelString];
        NSString *path = [[NSBundle mainBundle] pathForResource:levelName ofType:@"plist"];
        NSDictionary *level = [NSDictionary dictionaryWithContentsOfFile:path];
        
        NSArray *fruits = [level objectForKey:@"Fruits"];
        
        NSDictionary *fluffy = [level objectForKey:@"Fluffy"];
        Fluffy *fluffy2 = [[Fluffy alloc] initWithFluffyImage];
        NSNumber *x = [fluffy objectForKey:@"x"];
        NSNumber *y = [fluffy objectForKey:@"y"];
        fluffy2.position = CGPointMake([x floatValue], [y floatValue]);
        [foodObjects addObject:fluffy2];
        [self addChild:fluffy2 z:0];
        
        
        for (NSDictionary *fruit in fruits){
            NSString *sName = [fruit objectForKey:@"spriteName"];
            NSString *spriteName = [sName stringByAppendingString:@".png"];
            NSNumber *x = [fruit objectForKey:@"x"];
            NSNumber *y = [fruit objectForKey:@"y"];

            CCSprite *sprite = [CCSprite spriteWithFile:spriteName];
            sprite.position = CGPointMake([x floatValue], [y floatValue]);
            [foodObjects addObject:sprite];
            [self addChild:sprite z:0];
        }

        
        // Create ball body and shape
        b2BodyDef ballBodyDef;
        ballBodyDef.userData = (__bridge void*)_nextProjectile;
        ballBodyDef.type = b2_dynamicBody;
        ballBodyDef.position.Set(100/PTM_RATIO, 100/PTM_RATIO);
        
        _body = world->CreateBody(&ballBodyDef);
        
        b2CircleShape circle;
        circle.m_radius = 26.0/PTM_RATIO;
        
        b2FixtureDef ballShapeDef;
        ballShapeDef.shape = &circle;
        ballShapeDef.density = 1.0f;
        ballShapeDef.friction = 0.f;
        ballShapeDef.restitution = 1.0f;
        _body->CreateFixture(&ballShapeDef);
        
       
        //this determines the speed of the ball projectile
        b2Vec2 force = b2Vec2(1,1);
        _body->ApplyLinearImpulse(force, ballBodyDef.position);
    
        
        [self schedule:@selector(tick:)];
        //[self schedule:@selector(kick) interval:5.0];
        [self setTouchEnabled:YES];
        //[self setAccelerometerEnabled:NO];
        
        [self scheduleUpdate];
    }
    return self;
}

// DETECT COLLISIONS BETWEEN BALL AND FOOD!


-(void) detectCollisions
{
//balls in this case is still the projectile, which we will be removing/replacing
    //NSLog(@"foodObjects Count");
    //NSLog(@"%d",[foodObjects count]);
    
    //First check if the ball hit a food
    for(int i = 0; i < [balls count]; i++)
    {
        for(int j = 0; j < [foodObjects count]; j++)
        {
            if([balls count]>0)
            {
                NSInteger ballIndex = i;
                NSInteger foodIndex = j;
                food = [foodObjects objectAtIndex:foodIndex];
                ball = [balls objectAtIndex:ballIndex];
                
                firstrect = [ball textureRect];
                secondrect = [food textureRect];
                //check if their x coordinates match
                //if(ball.position.x == food.position.x)
                if(ball.position.x < (food.position.x + 50.0f) && ball.position.x > (food.position.x - 50.0f))
                {

                    //check if their y coordinates are within the height of the block
                    if(ball.position.y < (food.position.y + 50.0f) && ball.position.y > food.position.y - 50.0f)
                    {
                        if([food isKindOfClass:[Fluffy class]]) {
                            NSLog(@"YOU BEAT THE LEVEL!");
                            [[CCDirector sharedDirector] replaceScene: (CCScene*)[[OopsDNE alloc] init]];
                        }
                        else {
                        NSLog(@"FOOD COLLECTED!");
                        [self removeChild:food cleanup:YES];
                        //[self removeChild:ball cleanup:YES];
                        [foodObjects removeObjectAtIndex:foodIndex];
                        //[bullets removeObjectAtIndex:first];
                        //[[SimpleAudioEngine sharedEngine] playEffect:@"explo2.wav"];
                        //}
                        }
                        
                    }
                }
            }
        }
    }
    
//add this back after I find where the projectile went
 
//    //check if the ball hit the target
//    CCSprite *mouth = [self getChildByTag:1];
//    
//    //check if their x coordinates are close enough
//    if(ball.position.x < (mouth.position.x + 10.0f) && ball.position.y < (mouth.position.x - 10.0f))
//    {
//        //check if their y coordinates are close enough
//        if(ball.position.y < (mouth.position.y + 10.0f) && ball.position.y > mouth.position.y - 10.0f)
//        {
//            [self removeChild:ball cleanup: YES];
//            //[[CCDirector sharedDirector] replaceScene: (CCScene*)[[GameLayer alloc] init]];
//        }
//    }

//}




/*-(void) detectCollisions
{
    //balls in this case is still the projectile, which we will be removing/replacing
    //NSLog(@"foodObjects Count");
    //NSLog(@"%d",[foodObjects count]);
    
    //First check if the ball hit a food
    for(int j = 0; j < [foodObjects count]; j++)
    {
        if(_nextProjectile != nil) //not sure if this is right :P
        {
            //NSLog(@"HIHIHI");
            NSInteger foodIndex = j;
            food = [foodObjects objectAtIndex:foodIndex];
            
            NSLog(@"foooooood %f", food.position.x);
            NSLog(@"food %f", food.position.y);
            firstrect = [_nextProjectile textureRect];
            secondrect = [food textureRect];
            //check if their x coordinates match
            //if(ball.position.x == food.position.x)
            if(_nextProjectile.position.x < (food.position.x + 50.0f) && _nextProjectile.position.x > (food.position.x - 50.0f))
            {
                //check if their y coordinates are within the height of the block
                if(_nextProjectile.position.y < (food.position.y + 50.0f) && _nextProjectile.position.y > food.position.y - 50.0f)
                {
                    NSLog(@"DOES IT EVER GO HERE HUHHHH!");
                    [self removeChild:food cleanup:YES];
                    //[self removeChild:ball cleanup:YES];
                    [foodObjects removeObjectAtIndex:foodIndex];
                    //[bullets removeObjectAtIndex:first];
                    //[[SimpleAudioEngine sharedEngine] playEffect:@"explo2.wav"];
                    //}
                    
                }
            }
        }
    }*/
    
    //add this back after I find where the projectile went
    
       //check if the ball hit the target
        CCSprite *mouth = [self getChildByTag:1];
    
        //check if their x coordinates are close enough
        if(_nextProjectile.position.x < (mouth.position.x + 10.0f) && _nextProjectile.position.y < (mouth.position.x - 10.0f))
      {
            //check if their y coordinates are close enough
            if(_nextProjectile.position.y < (mouth.position.y + 10.0f) && _nextProjectile.position.y > mouth.position.y - 10.0f)
           {
            [self removeChild:_nextProjectile cleanup: YES];
               //[[CCDirector sharedDirector] replaceScene: (CCScene*)[[GameLayer alloc] init]];
            }
       }
    
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



- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
// 
//    UITouch *touch = [touches anyObject];
//    CGPoint poBefore = [touch locationInView:[touch view]];
//    poBefore = [[CCDirector sharedDirector] convertToGL:poBefore];
//    
    //    // Fail when more than 1 finger detected.
    

//    
//    
//    if (CGRectContainsPoint(_player.boundingBox, poBefore))
//    {
//        _MoveableSpriteTouch = true;
//    }
}
CGFloat arrowRotation = 180;
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
//
//    
//    CGPoint point = [touch locationInView:[touch view]];
//    
//    point = [[CCDirector sharedDirector] convertToGL:point];
//
//    if(_MoveableSpriteTouch==TRUE){
//        
//        [_player setPosition:point];
//        
//    }
    
    //acquire the previous touch location
    
    CGPoint firstLocation = [touch previousLocationInView:[touch view]];
    CGPoint location = [touch locationInView:[touch view]];
    
    //preform all the same basic rig on both the current touch and previous touch
    CGPoint touchingPoint = [[CCDirector sharedDirector] convertToGL:location];
    CGPoint firstTouchingPoint = [[CCDirector sharedDirector] convertToGL:firstLocation];
    
    CGPoint firstVector = ccpSub(firstTouchingPoint, _player.position);
    CGFloat firstRotateAngle = -ccpToAngle(firstVector);
    CGFloat previousTouch = CC_RADIANS_TO_DEGREES(firstRotateAngle);
    
    CGPoint vector = ccpSub(touchingPoint, _player.position);
    CGFloat rotateAngle = -ccpToAngle(vector);
    CGFloat currentTouch = CC_RADIANS_TO_DEGREES(rotateAngle);
    
    printf("ccTouchesMoved");
    
    //keep adding the difference of the two angles to the dial rotation
    arrowRotation += currentTouch - previousTouch;
    if (arrowRotation >= 50) {
        printf("ARROW.........\n");
        arrowRotation = 50;
    }
    
    else if (arrowRotation <= 20) {
        printf("ARROW.........\n");
        arrowRotation = 20;
    }
    
//    //UITouch *touch = [touches anyObject];
//
//    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
//    
//    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
//    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
//    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
//    
//    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
//    CGPoint newPos = ccpAdd(_player.position, translation);
//    //_player.position = newPos;
//    _player.position = ccp(_player.position.x, newPos.y);

}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //Checking if 3 bullets have already been used - if so, then no more bullet are thrown.
    if (_nextProjectile != nil or bulletCounter<=0) return;

    _MoveableSpriteTouch=FALSE;
    
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    CGRect leftBorder = CGRectMake(cageLeft, 0, cageLeft+10, 350);
   
    
    if (CGRectContainsPoint(leftBorder, location)) {
        
    // Set up initial location of projectile
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    _nextProjectile = [CCSprite spriteWithFile:@"projectile2.png"];
    //_nextProjectile.position = ccp(20, winSize.height/2);
    //_nextProjectile.position = _player.position;
    _nextProjectile.position = ccp(_player.position.x, _player.position.y+12.5); //so that ball exits out of cannon arm and not center of wheel
    [balls addObject: _nextProjectile];
    
    // Determine offset of location to projectile
    CGPoint offset = ccpSub(location, _nextProjectile.position);
    // Bail out if you are shooting down or backwards
    if (offset.x <= 0) return;
 
    // Determine where you wish to shoot the projectile to
    int realX = winSize.width + (_nextProjectile.contentSize.width/2);
    float ratio = (float) offset.y / (float) offset.x;
    int realY = (realX * ratio) + _nextProjectile.position.y;
    CGPoint realDest = ccp(realX, realY);
    
    // Determine the length of how far you're shooting
    int offRealX = realX - _nextProjectile.position.x;
    int offRealY = realY - _nextProjectile.position.y;
    float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
    float velocity = 480/1; // 480pixels/1sec
    float realMoveDuration = length/velocity;
    // Determine angle to face
    float angleRadians = atanf((float)offRealY / (float)offRealX);
    float angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
    float cocosAngle = -1 * angleDegrees;
    float rotateDegreesPerSecond = 180 / 0.5; // Would take 0.5 seconds to rotate 180 degrees, or half a circle
    //_player.anchorPoint = ccp(0.5, 0.5);
    
    float degreesDiff = _player.rotation - cocosAngle;
    float rotateDuration = fabs(degreesDiff / rotateDegreesPerSecond);
         
        [_player runAction:
         [CCSequence actions:
          [CCRotateTo actionWithDuration:rotateDuration angle:cocosAngle],
          [CCCallBlock actionWithBlock:^{
             // OK to add now - rotation is finished!
             [self addChild:_nextProjectile];
             // Release
             _nextProjectile = nil;
         }],
          nil]];
    // Move projectile to actual endpoint
    [_nextProjectile runAction:
     [CCSequence actions:
      [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
      [CCCallBlockN actionWithBlock:^(CCNode *node) {
         [node removeFromParentAndCleanup:YES];
     }],
      nil]];
        bulletCounter--;
        
    _player.tag = 4;
    
}
    else{
    
        printf("FAILURE!!!!!!!!!!!!!\n");
    
    }
    }


-(void) dealloc
{
	delete world;
    
    _body = NULL;
    world = NULL;
    //delete contactListener;
    
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
    
    if (input.anyTouchBeganThisFrame) //someone's touching the screen!! :O
    {
        bool touchCannonBody = false;
        bool touchCannonHead = false;
        
        if( (pos.y < _player.position.y + 20) && (pos.y > _player.position.y - 20) ) //touch somewhere in the cannon
        {
            //check if touched cannon body
            if ( (pos.x < _player.position.x + 10) && (pos.x > _player.position.x - 30) )
            {
                //shoot cannon
                //codecodecodeee
                //[self launchBullet:pos];
                touchCannonBody = true;
            }
        
            //check if touched cannon head
            if ( (pos.x < _player.position.x + 20) && !touchCannonBody)
            {
                //rotate cannon
                //should probably break out of this and then find the rotate somewhere..
                touchCannonHead = true;
            }
        }
        
        //outside the cage, move the cannon
        if (pos.x < cageLeft && !touchCannonBody && !touchCannonHead)
        {
            printf("CANNON BEING MOVEDDDD>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n");
            _player.position = ccp(x, y);
        }
        
    }
    
    
    
    
 
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
    
    [self detectCollisions];
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

}




@end












