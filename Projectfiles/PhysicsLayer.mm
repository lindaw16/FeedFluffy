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
#import "PauseScene.h"
#import "NextLevelScene.h"
#import "HUDLayer.h"
#import "StartMenuLayer.h"
//#import "cocos2d.m"


/*
 * Sprite Tags
 * 1: 
 * 2:
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
int bulletCounter;
int gold;
int silver;
int bronze;
int cannonRadius = 5.0/PTM_RATIO;
bool ButtonTapped = false;
int currentLevel;
int ballsUsed;



//for dialog boxes
CCSprite *message;
CCMenuItemImage *tapHere;
CCMenu * myTut;
int showDialog = 1;


float angleRadians;
float angleInDegrees;
float realMoveDuration;
b2BodyDef ballBodyDef;
b2Body *_body;
CGPoint realDest;
BOOL levelCompleted;

        CCLabelTTF *ballCountLabel;
//CGSize winSize;

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
    
    
    HUDLayer *hud = [HUDLayer node];
    [scene addChild:hud z:2];
	// 'layer' is an autorelease object.
    PhysicsLayer *layer = [[PhysicsLayer alloc] initWithLevel:level];
    //NSLog(@"THE LEVEL IS %d", currentLevel);
	[scene addChild: layer];
    //NSLog(@"Successfully added first layer!!!!\n");
    
	return scene;
}


-(void) setUpMenus
{
//we should probably put the pause button and star button here??
    
    CCSprite * thesnores = [CCSprite spriteWithSpriteFrameName:@"snore1.png"];
    thesnores.anchorPoint = CGPointZero;
    thesnores.position = CGPointMake(380.0f, 120.0f);
    
    //Create an animation from the set of frames
    
    //CCAnimation *wagging = [CCAnimation animationWithFrames: waggingFrames delay:0.1f];
    CCAnimation *snoring = [CCAnimation animationWithSpriteFrames: snoringFrames delay:0.9f];
    
    //Create an action with the animation that can then be assigned to a sprite
    
    //wag = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:wagging restoreOriginalFrame:NO]];
    snore = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:snoring]];
    snoring.restoreOriginalFrame = NO;
    
    
    //tell the bear to run the taunting action
    [thesnores runAction:snore];
    
    [self addChild:thesnores z:2];

}



- (id)initWithLevel: (int) level {
    
    if ((self = [super initWithColor:ccc4(255,255,255,255)])) {
        HUDLayer *hud;
        _hud = hud;
        angleInDegrees = 0;
        //CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello Levels!!" fontName:@"Marker Felt" fontSize:48.0];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        //label.position = ccp(size.width/2, size.height/2);
        
        //[self addChild:	label];
        
        
        ballsUsed = 0;
        [self stopAllActions];
            currentLevel = level;
           // NSLog(@"THE LEVELLLLL IS %d", currentLevel);

        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString *levelString = [@"level" stringByAppendingFormat:@"%d", currentLevel];
        NSMutableDictionary *levelDict = [[NSMutableDictionary alloc] init];
        levelDict = [defaults objectForKey:levelString];
        levelCompleted = [[levelDict objectForKey:@"completed"] intValue];
        
        
        
        NSLog(@"Before Game: best stars is %d and last star was %d", [[levelDict objectForKey:@"best_stars"] intValue],[[levelDict objectForKey:@"last_stars"] intValue]);
        
        
        //NSString *levelString =[@"level" stringByAppendingFormat:@"%d", currentLevel];
        //NSLog(@"LEVEL COMPLETED? %d", [[defaults objectForKey:levelString] intValue]);

        
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
        
        groundBox.Set(b2Vec2(0, cageBottom/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, cageBottom/PTM_RATIO));
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
        [self addChild:cannonHead z:1];
        
//        CCSprite *cage = [CCSprite spriteWithFile: @"cage.png"];
//        cage.position = ccp(470, cageBottom + (winSize.height - cageBottom)/2);
//        [self addChild: cage z:1];
        
//        CCSprite *temp = [CCSprite spriteWithFile: @"snore3.png"];
//        temp.position = ccp(430, cage.position.y - 30);
//        [self addChild: temp z:3];
        
        
        
        
        
        //Load the plist which tells Kobold2D how to properly parse your spritesheet. If on a retina device Kobold2D will automatically use bearframes-hd.plist
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"snoringframes.plist"];
        
        //Load in the spritesheet, if retina Kobold2D will automatically use bearframes-hd.png
        
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"snoringframes.png"];
        
        [self addChild:spriteSheet];
        
        
        //When it comes time to get art for your own original game, makegameswith.us will give you spritesheets that follow this convention, <spritename>1 <spritename>2 <spritename>3 etc...
        
        snoringFrames = [NSMutableArray array];
        
        for(int i = 1; i <= 4; ++i)
        {
            [snoringFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"snore%d.png", i]]];
        }
        
        //Adding the display for the number of projectiles remaingin
        

        
        //NSLog(@"Update Lives is being called!!!\n");
        
        //ballCountLabel = [CCLabelTTF labelWithString:@"level" fontName:@"Marker Felt" fontSize:18.0];

        // Create contact listener
        _contactListener = new MyContactListener();
        world->SetContactListener(_contactListener);
        
        
        
        //Adding "Launch" button so player can click on it to launch bullet/projectile
        
        // Standard method to create a button
        CCMenuItem *starMenuItem = [CCMenuItemImage
                                    itemWithNormalImage:@"launch_button_bigger.png" selectedImage:@"launch_button_bigger.png"
                                    target:self selector:@selector(starButtonTapped:)];
        starMenuItem.position = ccp(starMenuItem.contentSize.width/PTM_RATIO/2+40, starMenuItem.contentSize.height/PTM_RATIO/2+30);
        //starMenuItem.position = ccp(50,30);
        CCMenu *starMenu = [CCMenu menuWithItems:starMenuItem, nil];
        starMenu.position = CGPointZero;
        [self addChild:starMenu z:2];
        
        CCSprite *meep = [CCSprite spriteWithFile:@"gameBackground.png"];
        meep.anchorPoint = CGPointZero;
        [self addChild:meep z:-1];
        
//        CCSprite *bar = [CCSprite spriteWithFile: @"gameBar.png"];
//        bar.position = ccp(winSize.width / 2, 20);
//        [self addChild:bar z:1];
        
        // pause menu
        
        CCMenuItem *Pause = [CCMenuItemImage itemWithNormalImage:@"pause.png"
                                                   selectedImage: @"pause.png"
                                                          target:self
                                                        selector:@selector(pause:)];
        CCMenu *PauseButton = [CCMenu menuWithItems: Pause, nil];
        //Pause.tag = level;
        PauseButton.position = ccp(460, 295);
        //Pause.position = ccp(460, 295);
        [self schedule:@selector(tick:) interval:1.0f/60.0f];
        [self addChild:PauseButton z:7];
        
        
//        if (level == 1 && showDialog == 1)
//        {
//            message = [CCSprite spriteWithFile:@"dialog1.png"];
//            message.position = ccp(220, 140);
//            [self addChild:message z:1];
//        
//            tapHere = [CCMenuItemImage itemWithNormalImage:@"ok1.png" selectedImage: @"ok1" target:self selector:@selector(cannonx:)];
//            //tapHere = [CCSprite spriteWithFile:@"cannonx.png"];
//            myTut = [CCMenu menuWithItems: tapHere, nil];
//            //tapHere.position = ccp(100, 80);
//            tapHere.position = ccp(250, 100);
//            myTut.position = CGPointZero;
//            [self addChild:myTut z:3];
//        }
        
        //if (currentLevel == 1 || currentLevel == 2 || currentLevel == 3) // add a list of tutorial levels :P
        if ( (level == 1 || level == 2 || level == 3 ) && levelCompleted == 0)
        //if ([tutorialLevels containsObject: currentLevel])
        {
           // NSLog(@"this is the currenet level %d", currentLevel);
            //message = [CCSprite spriteWithFile:@"tutorial1.png"];
            //message = [CCSprite spriteWithFile:[NSString stringWithFormat:@"tutorial%d.png", currentLevel]];
            message = [CCSprite spriteWithFile:[NSString stringWithFormat:@"tutorial%d.png", level]];
            message.position = ccp(220, 140);
            [self addChild:message z:1];
        }
       // NSLog(@"this is the currenet level %d but i'm not inside the if statement", currentLevel);
        
        
        // plist level creation stuff
        
        NSString* levelString2 = [NSString stringWithFormat:@"%i", level];
        NSString *levelName = [@"level" stringByAppendingString:levelString2];
        NSString *path = [[NSBundle mainBundle] pathForResource:levelName ofType:@"plist"];
        NSDictionary *level = [NSDictionary dictionaryWithContentsOfFile:path];
        
        bulletCounter = [[level objectForKey:@"Balls"] intValue];
        gold = [[level objectForKey:@"Gold"] intValue];
        silver = [[level objectForKey:@"Silver"] intValue];
        bronze = [[level objectForKey:@"Bronze"] intValue];
        
        goal = [level objectForKey:@"Goal"];
        
        // create new dictionary that keeps track of the level progress
        
        for (NSString *key in goal){
            [goalProgress setObject:@0 forKey:key];
        }
        
        // this is the resolution we designed for, all positions are relative to this resolution
        CGSize reference = CGSizeMake(480, 320);
        
        // the current device resolution, on iPad this will be 1024x768
        //CGSize winSize = [CCDirector sharedDirector].winSize;
        
        // calculate the scale factor for the current device by dividing with the reference resolution
        // on iPad, the resulting scale will be: 2.13x1.6
        CGPoint scale = CGPointMake(winSize.width / reference.width, winSize.height / reference.height);
        float scaleX = winSize.width / reference.width;
        float scaleY = winSize.height / reference.height;
        
        ///NSLog(@"ScaleX : %f", scaleX);
        NSDictionary *fluffy = [level objectForKey:@"Fluffy"];
        Fluffy *fluffy2 = [[Fluffy alloc] initWithFluffyImage];
        NSNumber *x = [fluffy objectForKey:@"x"];
        NSNumber *y = [fluffy objectForKey:@"y"];
        //fluffy2.position = CGPointMake([x floatValue] * scaleX, [y floatValue] * scaleY);
                fluffy2.position = CGPointMake(560, 190);

        //fluffy2.position = ccpMult(fluffy2.position, scale);
        fluffy2.tag = 3;
        //NSLog(@"Scale = %d", [scale.x floatValue]);
        [self addChild:fluffy2 z:1];
       //NSLog(@"adf: %f", fluffy2.position.x);
        
        // Create block body
        b2BodyDef fluffyBodyDef;
        fluffyBodyDef.type = b2_dynamicBody;
        fluffyBodyDef.position.Set([x floatValue] * scaleX/PTM_RATIO, [y floatValue]*scaleY/PTM_RATIO);
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
                obstacle2.position = CGPointMake([x floatValue] * scaleX, [y floatValue] * scaleY);
                obstacle2.tag = 4;
            
                [self addChild:obstacle2 z:1];
            
                // Create block body
                b2BodyDef obstacleBodyDef;
                obstacleBodyDef.type = b2_staticBody;
                obstacleBodyDef.position.Set([x floatValue]*scaleX/PTM_RATIO, [y floatValue]*scaleY/PTM_RATIO);
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
            
            fruit2.position = CGPointMake([x floatValue] * scaleX, [y floatValue] * scaleY);
            [self addChild:fruit2 z:0];
            
            // Create block body
            b2BodyDef fruitBodyDef;
            fruitBodyDef.type = b2_dynamicBody;
            fruitBodyDef.position.Set([x floatValue]*scaleX/PTM_RATIO, [y floatValue]*scaleY/PTM_RATIO);
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

        ballCountLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@" X %d", bulletCounter]fontName:@"Marker Felt" fontSize:18.0];
        ballCountLabel.position = ccp(ballCountLabel.contentSize.width/PTM_RATIO/2+150, ballCountLabel.contentSize.height/PTM_RATIO/2+30);
        
        CCSprite * menuBall = [CCSprite spriteWithFile:@"bullet.png"];
        menuBall.position = ccp(menuBall.contentSize.width/PTM_RATIO/2+175, menuBall.contentSize.height/PTM_RATIO/2+30);
        
        ballCountLabel.string = [NSString stringWithFormat:@" X %d", bulletCounter];
        [self addChild: ballCountLabel z:10];
        [self addChild:menuBall z:10];
        
        [self setUpMenus];
        
        
        [self schedule:@selector(tick:)];
        //[self schedule:@selector(kick) interval:5.0];
        [self setTouchEnabled:YES];
        //[self setAccelerometerEnabled:NO];
        
        [self scheduleUpdate];
    }
    return self;
}

// DETECT COLLISIONS BETWEEN BALL AND FOOD!
- (void)updateLevel {
    //NSLog(@"Update Lives is being called!!!\n");
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCLabelTTF *levelLabel = [CCLabelTTF labelWithString:@"level" fontName:@"Marker Felt" fontSize:18.0];
    levelLabel.position = ccp(levelLabel.contentSize.width +10, 295);

    [self addChild: levelLabel z:10];
    levelLabel.string = [NSString stringWithFormat:@"Level: %d", currentLevel];
    
    
    //[_hud incrementLevel:[NSString stringWithFormat:@"Lives: %d", currentLevel]];
}

- (void)updateBallCount {
    CCLabelTTF *ballCountLabel;
    
    //NSLog(@"Update Lives is being called!!!\n");
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    ballCountLabel = [CCLabelTTF labelWithString:@"level" fontName:@"Marker Felt" fontSize:18.0];
    ballCountLabel.position = ccp(ballCountLabel.contentSize.width/PTM_RATIO/2+150, ballCountLabel.contentSize.height/PTM_RATIO/2+30);
    
    CCSprite * menuBall = [CCSprite spriteWithFile:@"bullet.png"];
    menuBall.position = ccp(menuBall.contentSize.width/PTM_RATIO/2+175, menuBall.contentSize.height/PTM_RATIO/2+30);
    

    [self addChild:menuBall z:10];



        ballCountLabel.string = [NSString stringWithFormat:@"X: %d", bulletCounter];
        [self addChild: ballCountLabel z:10];
    
    //[_hud incrementLevel:[NSString stringWithFormat:@"Lives: %d", currentLevel]];
}

- (void)starButtonTapped:(id)sender {
   // NSLog(@"Button tapped!!!!!!\n");
    ballsUsed++;
    _nextProjectile = [CCSprite spriteWithFile:@"bullet.png"];
    _nextProjectile.tag = 1;
    
    _nextProjectile.position = _player.position;

    // Create ball body and shape
    
    ballBodyDef.type = b2_dynamicBody;
    //            ballBodyDef.position.Set(100/PTM_RATIO, 100/PTM_RATIO);
   // NSLog(@"in Position.SET\n");
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
    [ballCountLabel setString:[NSString stringWithFormat:@" X %d", bulletCounter]];

    //angleInDegrees = 0;
    ButtonTapped = false;
}

-(void) pause: (CCMenuItem *) sender{
    //int level = sender.tag;
    //[[CCDirector sharedDirector] pushScene:[PauseScene node]];
    //NSLog(@"LEVELLLL %d", level);
    [[CCDirector sharedDirector] pushScene: (CCScene*)[PauseScene sceneWithLevel: currentLevel]];
}

-(BOOL) checkLevelCompleted {
    //NSLog(@"CHECKING IF LEVEL IS COMPLETED");
    

    for (NSString *key in goal){
        int goalValue = [[goal objectForKey:key] intValue];
        int goalProgressValue = [[goalProgress objectForKey:key] intValue];
        //NSLog(@"BALLS USED: %d", ballsUsed);
        //NSLog(@"%d", goalValue);
        if (goalProgressValue < goalValue) {
            return NO;
        }
    }
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *levelString = [@"level" stringByAppendingFormat:@"%d", currentLevel];
    //NSMutableDictionary *levelDict = [[NSMutableDictionary alloc] init];
    //levelDict = [[NSMutableDictionary alloc]init];
    
    NSMutableDictionary *levelDict = [[defaults objectForKey:levelString] mutableCopy];
    [levelDict setObject:@YES forKey:@"completed"];

    [levelDict setObject:[NSNumber numberWithInteger:ballsUsed] forKey:@"last_balls"];
    int bestBalls = [[levelDict objectForKey:@"best_balls"] intValue];
    int bestStars = [[levelDict objectForKey:@"best_stars"] intValue];
    //NSLog(@"best_balls: %d", bestBalls);
   // NSLog(@"best_stars: %d", bestStars);
    
    NSLog(@"After Game before calculation: best stars is %d and last star was %d", [[levelDict objectForKey:@"best_stars"] intValue],[[levelDict objectForKey:@"last_stars"] intValue]);
    
    
    int stars;
    if (ballsUsed < bestBalls){
        [levelDict setObject:[NSNumber numberWithInt:ballsUsed] forKey:@"best_balls"];
        int bestBalls = [[levelDict objectForKey:@"best_balls"] intValue];
        NSLog(@"best_balls: %d", bestBalls);
    }
    if (ballsUsed <= gold){
        stars = 3;
    }
    else if (ballsUsed <= silver){
        stars = 2;
    }
    else {
        stars = 1;
    }
    
    [levelDict setObject:[NSNumber numberWithInt: stars] forKey:@"last_stars"];
    if (stars > bestStars){
       // NSLog(@"HELLO!!!!!");
        bestStars = stars;

        //int bestStars = [[levelDict objectForKey:@"best_stars"] intValue];
        //NSLog(@"best_stars: %d", bestStars);
    }
    [levelDict setObject:[NSNumber numberWithInt: bestStars] forKey:@"best_stars"];
    
    //[defaults setObject: levelDict forKey:levelString];
    [defaults removeObjectForKey:levelString];
    [defaults setObject:levelDict forKey: levelString];
    [defaults synchronize];
    
    
    NSLog(@"After Game: best stars is %d and last star was %d", [[levelDict objectForKey:@"best_stars"] intValue],[[levelDict objectForKey:@"last_stars"] intValue]);
    
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
    [self updateLevel];
    //[self updateBallCount];
    int x = pos.x;
    int y = pos.y;
    
    CGPoint location;
   // CGSize winSize;
    if (input.anyTouchBeganThisFrame) //someone's touching the screen!! :O
    {
        
        //printf("ANY-TOUCH-BEGAN-THIS-FRAME");
        
        
        //Checking if 3 bullets have already been used - if so, then no more bullet are thrown.
        if  (bulletCounter<=0) return;
        
        _MoveableSpriteTouch = FALSE;
        
        // Choose one of the touches to work with
                
        location = [self convertToNodeSpace:pos];
        //CGRect leftBorder = CGRectMake(cageLeft, 0, cageLeft+10, 350);
    }
    
    else if (input.anyTouchEndedThisFrame)
    {
        //printf("ended frame..........\n");
        if (currentLevel == 1 || currentLevel == 2 || currentLevel == 3) // add a list for later
        {
            [self removeChild: message];
        }

    }
    
    
    else if (input.touchesAvailable)
    {
        //pos.x <= cageLeft
        if (CGRectContainsPoint(_player.boundingBox, pos))
        {
            //make sure the cannon does not move offscreen
            if (pos.y < 280 && pos.y > cageBottom + 20)
            {
                //NSLog(@"CANNON BEING MOVEDDDD>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n");
                
                _player.position = ccp(_player.position.x, y+5);
                _nextProjectile.position = _player.position;
                cannonHead.position = ccp(cannonHead.position.x, y);
            }
            
            
        }
        
        
        if (pos.x>=cageLeft+5 and pos.x <=80 )
        {

            
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
                    //NSLog(fruitName);
                    int num = [[goal objectForKey:fruitName] intValue];
                    //NSLog(@"%d", num);
                    int fruitNum = [[goalProgress objectForKey:fruitName] intValue];
                    //NSLog(@"%d", fruitNum);
                    fruitNum++;
                    [goalProgress setObject:[NSNumber numberWithInt: fruitNum] forKey:fruitName];
                    int fruitNum2 = [[goalProgress objectForKey:fruitName] intValue];
                    //NSLog(@"Hit Fruit");
                }
            }
            
            //Sprite A = fruit, Sprite B = ball
            else if ([spriteA isKindOfClass:[Fruit class]] && spriteB.tag == 1) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end()) {
                    toDestroy.push_back(bodyA);
                    Fruit *fruit = (Fruit*) spriteA;
                    NSString *fruitName = fruit.fruitName;
                    //NSLog(fruitName);
                    int num = [[goal objectForKey:fruitName] intValue];
                    //NSLog(@"%d", num);
                    int fruitNum = [[goalProgress objectForKey:fruitName] intValue];
                   // NSLog(@"%d", fruitNum);
                    fruitNum++;
                    [goalProgress setObject:[NSNumber numberWithInt: fruitNum] forKey:fruitName];
                    int fruitNum2 = [[goalProgress objectForKey:fruitName] intValue];
                   // NSLog(@"Hit Fruit");
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
                        //NSLog(@"YOU DIDN'T BEAT THE LEVEL!");
                    }
                    //NSLog(@"Hit Fluffy!");
                }

            }
            
            //Sprite A = fluffy, Sprite B = ball
            else if ([spriteA isKindOfClass:[Fluffy class]] && spriteB.tag == 1) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end()) {
                    toDestroy.push_back(bodyB);

                    //NSLog(@"Hit Fluffy!");
                    levelCompleted = [self checkLevelCompleted];
                    //NSLog(@"THE CURRENT LEVEL IS: %d", currentLevel);
                    if (levelCompleted){
                        //[[CCDirector sharedDirector] replaceScene: (CCScene*)[[OopsDNE alloc] init]];
                        [[CCDirector sharedDirector] replaceScene: (CCScene*)[NextLevelScene sceneWithLevel: currentLevel]];
                        counter = 1;
                    }
                
                    else {
                       // NSLog(@"YOU DIDN'T BEAT THE LEVEL!");
                    }
               // NSLog(@"Hit Fluffy!");
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


-(void) cannonx: (CCMenuItemImage *) menuItem
{
    showDialog++;
    //[self removeChild:tapHere cleanup:YES];
    [self removeChild:message cleanup:YES];
    [self removeChild:myTut cleanup: YES];
    //[tapHere setIsEnabled:NO];
    
    if (showDialog == 2)
    {
        message = [CCSprite spriteWithFile:@"dialog2.png"];
        tapHere = [CCMenuItemImage itemWithNormalImage:@"ok2.png" selectedImage: @"ok2.png" target:self selector:@selector(cannonx:)];
        message.position = ccp(220, 130);
        tapHere.position = ccp(250, 110);
        //[tapHere setPosition: _player.position];
        myTut = [CCMenu menuWithItems: tapHere, nil];
        myTut.position = CGPointZero;
        [self addChild:message z:1];
        [self addChild:myTut z:1];
    }
    
    
    if (showDialog == 3)
    {
        message = [CCSprite spriteWithFile:@"dialog3.png"];
        tapHere = [CCMenuItemImage itemWithNormalImage:@"ok3.png" selectedImage: @"ok3.png" target:self selector:@selector(cannonx:)];
        message.position = ccp(230, 150);
        tapHere.position = ccp(230, 100);
        
        myTut = [CCMenu menuWithItems: tapHere, nil];
        myTut.position = CGPointZero;
        [self addChild:message z:1];
        [self addChild:myTut z:1];
    }
    
//    if (showDialog <= 3){
//        //message = [CCSprite spriteWithFile: [@"dialog" stringByAppendingFormat:@"%d", showDialog]];
//        
////        
////        message.position = ccp(200, 110);
////        myTut = [CCMenu menuWithItems: tapHere, nil];
////        myTut.position = CGPointZero;
////        //tapHere.position = ccp(220, 120);
////        [self addChild:message z:1];
////        [self addChild:myTut z:1];
//    }
    
    //NSLog(@"YEAAAAA");
}

//-(void) cannonheadx:(CCMenuItemImage *)menuItem
//{
//    [self removeChild:message cleanup:YES];
//    [self removeChild:myTut cleanup: YES];
//
//}


@end