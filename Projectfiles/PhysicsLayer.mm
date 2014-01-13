/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim.
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "PhysicsLayer.h"
#import "Box2D.h"
#import "Box2DDebugLayer.h"
#import "cocos2d.h"
//#import "cocos2d.m"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
const float PTM_RATIO = 32.0f;

const int TILESIZE = 32;
const int TILESET_COLUMNS = 9;
const int TILESET_ROWS = 19;


@interface PhysicsLayer (PrivateMethods)
-(void) enableBox2dDebugDrawing;
-(void) addSomeJoinedBodies:(CGPoint)pos;
-(void) addNewSpriteAt:(CGPoint)p;
-(b2Vec2) toMeters:(CGPoint)point;
-(CGPoint) toPixels:(b2Vec2)vec;
-(CGSize) winSize;
@end

@implementation PhysicsLayer


+(id) scene {
    CCScene *scene = [CCScene node];
    PhysicsLayer *layer = [PhysicsLayer node];
    [scene addChild:layer];
    return scene;
}



- (id)init {
    
    if ((self = [super initWithColor:ccc4(255,255,255,255)])) {
        self.touchEnabled = YES;
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        // Create a world
        b2Vec2 gravity = b2Vec2(0.0f, -8.0f);
        world = new b2World(gravity);
        

        
        // Create sprite and add it to the layer
        ball = [CCSprite spriteWithFile:@"projectile-hd.png" rect:CGRectMake(0, 0, 52, 52)];
        ball.position = ccp(0, 0);
        [self addChild:ball];
        
        
        
        // Create paddle and add it to the layer
        CCSprite *paddle = [CCSprite spriteWithFile:@"longblock-hd.png"];
        paddle.position = ccp(winSize.width/2, 50);
        [self addChild:paddle];
        
        // Create paddle body
        b2BodyDef paddleBodyDef;
        paddleBodyDef.type = b2_dynamicBody;
        paddleBodyDef.position.Set(winSize.width/2/PTM_RATIO, 50/PTM_RATIO);
        paddleBodyDef.userData = (__bridge void*)paddle;
        _paddleBody = world->CreateBody(&paddleBodyDef);
        
        // Create paddle shape
        b2PolygonShape paddleShape;
        paddleShape.SetAsBox(paddle.contentSize.width/PTM_RATIO/2,
                             paddle.contentSize.height/PTM_RATIO/2);
        
        
        // Create shape definition and add to body
        b2FixtureDef paddleShapeDef;
        paddleShapeDef.shape = &paddleShape;
        paddleShapeDef.density = 10.0f;
        paddleShapeDef.friction = 0.4f;
        paddleShapeDef.restitution = 0.1f;
        _paddleFixture = _paddleBody->CreateFixture(&paddleShapeDef);
        
        // Create edges around the entire screen
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
        
        groundBox.Set(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO,
                                                                  winSize.height/PTM_RATIO));
        _groundBody->CreateFixture(&groundBoxDef);
        
        groundBox.Set(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO), 
                      b2Vec2(winSize.width/PTM_RATIO, 0));
        _groundBody->CreateFixture(&groundBoxDef);
        // Create ball body and shape
        b2BodyDef ballBodyDef;
        ballBodyDef.userData = (__bridge void*)ball;
        
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
//Make paddle horizontal plane
        b2PrismaticJointDef jointDef;
        b2Vec2 worldAxis(1.0f, 0.0f);
        jointDef.collideConnected = true;
        jointDef.Initialize(_paddleBody, _groundBody,
                            _paddleBody->GetWorldCenter(), worldAxis);
        world->CreateJoint(&jointDef);

        
        b2Vec2 force = b2Vec2(10, 10);
        _body->ApplyLinearImpulse(force, ballBodyDef.position);
        
        
        
        
        [self schedule:@selector(tick:)];
        //[self schedule:@selector(kick) interval:5.0];
        [self setTouchEnabled:YES];
        //[self setAccelerometerEnabled:NO];
    }
    return self;
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
                    }
    }
    
}
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_mouseJoint != NULL) return;
    
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    if (_paddleFixture->TestPoint(locationWorld)) {
        b2MouseJointDef md;
        md.bodyA = _groundBody;
        md.bodyB = _paddleBody;
        md.target = locationWorld;
        md.collideConnected = true;
        md.maxForce = 500.0f * _paddleBody->GetMass();
        
        _mouseJoint = (b2MouseJoint *)world->CreateJoint(&md);
        _paddleBody->SetAwake(true);
    }
    
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_mouseJoint == NULL) return;
    
    UITouch *myTouch = [touches anyObject];
    CGPoint location = [myTouch locationInView:[myTouch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
    _mouseJoint->SetTarget(locationWorld);
    
}
-(void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_mouseJoint) {
        world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_mouseJoint) {
        world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }
}

//- ( void ) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    locationTouchBegan = [touch locationInView: [touch view]];
//    //location is The Point Where The User Touched
//    locationTouchBegan = [[CCDirector sharedDirector] convertToGL:locationTouchBegan];
//    //Detect the Touch On Ball
//    if(CGRectContainsPoint([ball boundingBox], locationTouchBegan))
//    {
//        isBallTouched=YES;
//    }
//    
//}
//- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    // Choose one of the touches to work with
//    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInView:[touch view]];
//    location = [[CCDirector sharedDirector] convertToGL:location];
//    
//    //  Determine offset of location to projectile
//    int offX = location.x - ball.position.x;
//    int offY = location.y - ball.position.y;
//    
//    // Bail out if we are shooting down or backwards
//    if (offX <= 0)
//        return;
//    
//    // Determine where we wish to shoot the projectile to
//    int realX = winSize.width + (ball.contentSize.height/2);
//    float ratio = (float) offY / (float) offX;
//    int realY = (realX * ratio) + ball.position.y;
//    CGPoint realDest = ccp(realX, realY);
//    
//    if(realX>=320)
//        realX = 320;
//    if(realY>=480)
//        realY = 480;
//    
//    
//    //int good = goodBarrel.position.x;
//    //int bad = badBarrel.position.x;
//    
//    int destY = realDest.x;
//        
//    realDest.x = destY+10;
//    
//    // Determine the length of how far we're shooting
//    int offRealX = realX - ball.position.x;
//    int offRealY = realY - ball.position.y;
//    float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
//    float velocity = 480/1; // 480pixels/1sec
//    float realMoveDuration = length/velocity;
//    
//    // Move projectile to actual endpoint
//    [ball runAction:[CCSequence actions:
//                     [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
//                     [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
//                     nil]];
//    [ball runAction:[CCScaleTo actionWithDuration:realMoveDuration scale:0.4f]];
    //	if ((self = [super init]))
//	{
//		CCLOG(@"%@ init", NSStringFromClass([self class]));
//
//		glClearColor(0.1f, 0.0f, 0.2f, 1.0f);
//
//		// Construct a world object, which will hold and simulate the rigid bodies.
//		b2Vec2 gravity = b2Vec2(0.0f, -10.0f);
//		world = new b2World(gravity);
//		world->SetAllowSleeping(YES);
//		//world->SetContinuousPhysics(YES);
//
//		// uncomment this line to draw debug info
//		[self enableBox2dDebugDrawing];
//
//		contactListener = new ContactListener();
//		world->SetContactListener(contactListener);
//
//		// for the screenBorder body we'll need these values
//		CGSize screenSize = [CCDirector sharedDirector].winSize;
//		float widthInMeters = screenSize.width / PTM_RATIO;
//		float heightInMeters = screenSize.height / PTM_RATIO;
//		b2Vec2 lowerLeftCorner = b2Vec2(0, 0);
//		b2Vec2 lowerRightCorner = b2Vec2(widthInMeters, 0);
//		b2Vec2 upperLeftCorner = b2Vec2(0, heightInMeters);
//		b2Vec2 upperRightCorner = b2Vec2(widthInMeters, heightInMeters);
//
//		// Define the static container body, which will provide the collisions at screen borders.
//		b2BodyDef screenBorderDef;
//		screenBorderDef.position.Set(0, 0);
//		b2Body* screenBorderBody = world->CreateBody(&screenBorderDef);
//		b2EdgeShape screenBorderShape;
//
//		// Create fixtures for the four borders (the border shape is re-used)
//		screenBorderShape.Set(lowerLeftCorner, lowerRightCorner);
//		screenBorderBody->CreateFixture(&screenBorderShape, 0);
//		screenBorderShape.Set(lowerRightCorner, upperRightCorner);
//		screenBorderBody->CreateFixture(&screenBorderShape, 0);
//		screenBorderShape.Set(upperRightCorner, upperLeftCorner);
//		screenBorderBody->CreateFixture(&screenBorderShape, 0);
//		screenBorderShape.Set(upperLeftCorner, lowerLeftCorner);
//		screenBorderBody->CreateFixture(&screenBorderShape, 0);
//
//		NSString* message = @"Tap Screen For More Awesome!";
//		if ([CCDirector sharedDirector].currentPlatformIsMac)
//		{
//			message = @"Click Window For More Awesome!";
//		}
//
//		CCLabelTTF* label = [CCLabelTTF labelWithString:message fontName:@"Marker Felt" fontSize:32];
//		[self addChild:label];
//		[label setColor:ccc3(222, 222, 255)];
//		label.position = CGPointMake(screenSize.width / 2, screenSize.height - 50);
//
//		// Use the orthogonal tileset for the little boxes
//		CCSpriteBatchNode* batch = [CCSpriteBatchNode batchNodeWithFile:@"dg_grounds32.png" capacity:TILESET_ROWS * TILESET_COLUMNS];
//		[self addChild:batch z:0 tag:kTagBatchNode];
//
//		// Add a few objects initially
//		for (int i = 0; i < 9; i++)
//		{
//			[self addNewSpriteAt:CGPointMake(screenSize.width / 2, screenSize.height / 2)];
//		}
//
//		[self addSomeJoinedBodies:CGPointMake(screenSize.width / 4, screenSize.height - 50)];
//
//		[self scheduleUpdate];
//
//		[KKInput sharedInput].accelerometerActive = YES;
//	}
//
//	return self;



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
			[self addNewSpriteAt:[input locationOfAnyTouchInPhase:KKTouchPhaseEnded]];
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

@end
