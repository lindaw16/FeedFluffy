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
#import "LoseScene.h"
#import "Squirrel.h"
#import "Bomb.h"
#import "ModalAlert.h"
#import "SimpleAudioEngine.h"

//#import "cocos2d.m"


/*
 * Sprite Tags
 *
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
const int cageBottom = 260;
int gold;
int silver;
int bronze;
int cannonRadius = 5.0/PTM_RATIO;
bool ButtonTapped = false;
int currentLevel;
int ballsUsed;
int numFruitCollected;
int seconds;
BOOL orangeCollected;

int cannonCounter = 0;
CCSprite *ballData;

//for dialog boxes
CCSprite *message;
CCMenuItemImage *tapHere;
CCMenu * myTut;
int showDialog = 1;
int ExplosionCounter = 0;

float angleRadians;
float angleInDegrees;
float realMoveDuration;
b2BodyDef ballBodyDef;
b2Body *_body;
CGPoint realDest;
BOOL levelCompleted;

bool timeCounter = false;
CGPoint bombPos;
CCLabelTTF *ballCountLabel;
CCSprite * menuBall;
NSMutableDictionary *labels = [[NSMutableDictionary alloc] init];


NSDictionary *goal;
NSMutableDictionary *goalProgress;

NSMutableDictionary *levelDict;


//Timers:
CCLabelTTF          *mTimeLbl;
float               mTimeInSec;
int digit_min;

int digit_sec;

int min2;

int sec;



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
	[scene addChild: layer];
    
	return scene;
}

int tutorial1 = 0;
int tutorial4 = 0;
int tutorial13 = 0;


-(void) setUpMenus
{
    //we should probably put the pause button and star button here??
    if (currentLevel ==1 && tutorial1 ==0){
        mTimeInSec = 60.0;
        [ModalAlert Tell:@"You must send the orange to Fluffy\n"@"Or else he'll get all in a huff-y.\n"@" Collect more fruits with one ball, \n"@"Or better yet- collect them all, \n"@"And Fluffy will grow up big and buffy. \n\n"@"Drag the cannon or its head to change its position and angle. Press the launch button to go. Good luck!" onLayer:self okBlock:^{
            
        }];
        
        tutorial1 = 1;
                mTimeInSec = 60.0;
    }
    
    else if (currentLevel == 4  && tutorial4 == 0)
    {
            [ModalAlert Tell:@"Watch out for these boulders! You will bounce off of them." onLayer:self okBlock:^{
                
            }];
            
            tutorial4 = 1;
    }
    
    else if (currentLevel == 13 && tutorial13 == 0)
    {
        [ModalAlert Tell:@"The sneaky squirrels will eat Fluffy's food if they catch them!" onLayer:self okBlock:^{
            
        }];
        
        tutorial13 = 1;
    }
    

    CCSprite * thesnores = [CCSprite spriteWithSpriteFrameName:@"snore1.png"];
    thesnores.anchorPoint = CGPointZero;
    
    mTimeLbl = [CCLabelTTF labelWithString:[NSString stringWithFormat:@":%.2d",int(mTimeInSec) ] fontName:@"Marker Felt" fontSize:18.0];
    [self addChild:mTimeLbl];
    if (IsIphone5){
    thesnores.position = CGPointMake(478.0f, 120.0f);

    }
    else {
        thesnores.position = CGPointMake(405.0f, 120.0f);
    }
    //Create an animation from the set of frames
    
    CCAnimation *snoring = [CCAnimation animationWithSpriteFrames: snoringFrames delay:0.9f];
    
    //Create an action with the animation that can then be assigned to a sprite
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
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"levelMusic.mp3" loop:YES];

        numFruitCollected = 0;
        orangeCollected = NO;
        
        seconds = 0;
        ballsUsed = 0;
        currentLevel = level;
        goalProgress = [[NSMutableDictionary alloc] init];
        [self updateLevel];
        //[self displayFoodCollect];
        
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString *levelString = [@"level" stringByAppendingFormat:@"%d", currentLevel];
        levelDict = [[NSMutableDictionary alloc] init];
        levelDict = [defaults objectForKey:levelString];
        levelCompleted = [[levelDict objectForKey:@"completed"] intValue];
        
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
        
        
        groundBox.Set(b2Vec2(0, 0), b2Vec2(winSize.width/PTM_RATIO, 0));
        _groundBody->CreateFixture(&groundBoxDef);
        
        
        groundBox.Set(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
        _groundBody->CreateFixture(&groundBoxDef);
        
        groundBox.Set(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 0));
        _groundBody->CreateFixture(&groundBoxDef);
        
        _player = [CCSprite spriteWithFile:@"cannon-body2.png"];
        _player.position = ccp(_player.contentSize.width/2 - 4, winSize.height/2 -28);
        
        
        [self addChild:_player z:1];
        
        
        
        cannonHead = [CCSprite spriteWithFile:@"cannon-head-cropped.png"];
        cannonHead.position = ccp(_player.position.x + 20, _player.position.y - 0.5);
        [self addChild:cannonHead z:1];

        
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
        
        //ballCountLabel = [CCLabelTTF labelWithString:@"level" fontName:@"Marker Felt" fontSize:18.0];
        
        // Create contact listener
        _contactListener = new MyContactListener();
        world->SetContactListener(_contactListener);
        
        
        
        //Adding "Launch" button so player can click on it to launch bullet/projectile
        
        // Standard method to create a button
        CCMenuItem *starMenuItem = [CCMenuItemImage
                                    itemWithNormalImage:@"ShootButton.png" selectedImage:@"ShootButton.png"
                                    target:self selector:@selector(starButtonTapped:)];
        starMenuItem.position = ccp(starMenuItem.contentSize.width/PTM_RATIO/2+35, winSize.height - starMenuItem.contentSize.height/PTM_RATIO/ 2 - 30 );
        starMenuItem.scaleX = 0.8;
        starMenuItem.scaleY = 0.8;
        //starMenuItem.position = ccp(50,30);
        CCMenu *starMenu = [CCMenu menuWithItems:starMenuItem, nil];
        starMenu.position = CGPointZero;
        [self addChild:starMenu z:2];
        
        CCSprite *meep = [CCSprite spriteWithFile:@"gameBackground.png"];
        meep.anchorPoint = CGPointZero;
        [self addChild:meep z:-1];
        
        // pause menu
        
        CCMenuItem *Pause = [CCMenuItemImage itemWithNormalImage:@"pauseButton2.png"
                                                   selectedImage: @"pauseButton2.png"
                                                          target:self
                                                        selector:@selector(pause:)];
        CCMenuItem *Restart= [CCMenuItemImage itemWithNormalImage:@"restartButton.png"
                                                    selectedImage: @"restartButton.png"
                                                           target:self
                                                         selector:@selector(restart:)];
        CCMenu *PauseButton = [CCMenu menuWithItems: Pause, Restart, nil];
        //Pause.tag = level;
        
        if (IsIphone5)
        {
            Pause.scaleX = 0.7;
            Pause.scaleY = 0.7;
            
            Restart.scaleX = 0.3;
            Restart.scaleY = 0.3;
            
            Pause.position = ccp(480, 290);
            Restart.position = ccp(530, 290);
            
            //PauseButton.position = ccp(483, 292);
        }
        else{
            Pause.position = ccp(410, 290);
            Restart.position = ccp(455, 290);
            Pause.scaleX = 0.6;
            Pause.scaleY = 0.6;
            
            Restart.scaleX = 0.25;
            Restart.scaleY = 0.25;
        }

        PauseButton.position = CGPointZero;
       // Pause.position = ccp(460, 295);
        //Restart.position = ccp(500, 295);
        mTimeInSec = 60.0f;
        [self schedule:@selector(tick:)];
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
            
        {

        }
        
        // plist level creation stuff
        
        NSString* levelString2 = [NSString stringWithFormat:@"%i", level];
        NSString *levelName = [@"level" stringByAppendingString:levelString2];
        NSString *path = [[NSBundle mainBundle] pathForResource:levelName ofType:@"plist"];
        NSDictionary *level = [NSDictionary dictionaryWithContentsOfFile:path];
        
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
        //        NSNumber *x = [fluffy objectForKey:@"x"];
        //        NSNumber *y = [fluffy objectForKey:@"y"];
        //fluffy2.position = CGPointMake([x floatValue] * scaleX, [y floatValue] * scaleY);
        //fluffy2.position = CGPointMake(560, 190);
        
        
        fluffy2.position = ccp(winSize.width - 16, 130);
        //        float *x = fluffy2.position.x;
        //        float *y = fluffy2.position.y;
        
        
        //fluffy2.position = ccpMult(fluffy2.position, scale);
        fluffy2.tag = 3;
        //NSLog(@"Scale = %d", [scale.x floatValue]);
        [self addChild:fluffy2 z:1];
        //NSLog(@"adf: %f", fluffy2.position.x);
        
        // Create block body
        b2BodyDef fluffyBodyDef;
        fluffyBodyDef.type = b2_dynamicBody;
        fluffyBodyDef.position.Set(fluffy2.position.x /PTM_RATIO, fluffy2.position.y/PTM_RATIO);
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
        
        if ([level objectForKey:@"Squirrels"]){
            NSArray *obstacles= [level objectForKey:@"Squirrels"];
            for (NSDictionary *obstacle in obstacles){
                NSString *sName = [obstacle objectForKey:@"spriteName"];
                
                
                
                NSNumber *x = [obstacle objectForKey:@"x"];
                NSNumber *y = [obstacle objectForKey:@"y"];

                [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"squirrelUp.plist"];
                CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"squirrelUp.png"];
                [self addChild: spriteSheet];
                
                Squirrel *obstacle2 = [[Squirrel alloc] initWithSquirrel:sName];

                //CGPoint squirrelLoc = CGPointMake([x floatValue] * scaleX, [y floatValue] * scaleY);
                //Squirrel *obstacle2 = [[Squirrel alloc] initWithSquirrel: sName : squirrelLoc];



                //obstacle2.position = CGPointMake([x floatValue] * scaleX, [y floatValue] * scaleY);
                obstacle2.tag = 5;
                
                [self addChild:obstacle2 z:1];
                
                // Create block body
                b2BodyDef obstacleBodyDef;
                obstacleBodyDef.type = b2_kinematicBody;
                
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
                obstacleShapeDef.isSensor = true;
                obstacleBody->CreateFixture(&obstacleShapeDef);
                
                b2Vec2 force = b2Vec2(0, 3);
                obstacleBody->SetLinearVelocity(force);

            }
        }
        
        if ([level objectForKey:@"Bomb"]){
            NSLog(@"Entering bomb?\n");
            NSArray *bombs= [level objectForKey:@"Bomb"];
            for (NSDictionary *bomb in bombs){
                Bomb *bomb2 = [[Bomb alloc] initWithBomb:@"bomb"];
                NSNumber *x = [bomb objectForKey:@"x"];
                NSNumber *y = [bomb objectForKey:@"y"];
                bomb2.position = CGPointMake([x floatValue] * scaleX, [y floatValue] * scaleY);
                bombPos = bomb2.position;
                [self addChild:bomb2 z:1];
                // Create block body
                b2BodyDef obstacleBodyDef;
                obstacleBodyDef.type = b2_kinematicBody;
                
                obstacleBodyDef.position.Set([x floatValue]*scaleX/PTM_RATIO, [y floatValue]*scaleY/PTM_RATIO);
                obstacleBodyDef.userData = (__bridge void*)bomb2;
                b2Body *obstacleBody = world->CreateBody(&obstacleBodyDef);
                
                // Create block shape
                b2PolygonShape obstacleShape;
                obstacleShape.SetAsBox(bomb2.contentSize.width/PTM_RATIO/2,
                                       bomb2.contentSize.height/PTM_RATIO/2);
                
                // Create shape definition and add to body
                b2FixtureDef obstacleShapeDef;
                obstacleShapeDef.shape = &obstacleShape;
                obstacleShapeDef.density = 10.0;
                obstacleShapeDef.friction = 0.0;
                obstacleShapeDef.restitution = 0.1f;
                obstacleShapeDef.isSensor = true;
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
        
        menuBall = [CCSprite spriteWithFile:@"ball.png"];

        
        [self setUpMenus];
        
        
        [self schedule:@selector(tick:)];
        [self setTouchEnabled:YES];

        
        [self scheduleUpdate];
        
        // timer, call every second
        [self schedule:@selector(countSeconds:) interval:1.0];

    }
    return self;
}

- (void) countSeconds:(ccTime)dt{
    seconds++;
}

- (void)updateLevel {
    //NSLog(@"Update Lives is being called!!!\n");
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCLabelTTF *levelLabel = [CCLabelTTF labelWithString:@"level" fontName:@"Marker Felt" fontSize:18.0];
    if (IsIphone5)
    {
    levelLabel.position = ccp(levelLabel.contentSize.width +100, 290);
    }
    else{
    levelLabel.position = ccp(levelLabel.contentSize.width +75, 290);
    }
    [self addChild: levelLabel z:10];
    levelLabel.string = [NSString stringWithFormat:@"Level: %d", currentLevel];
    
    
    //[_hud incrementLevel:[NSString stringWithFormat:@"Lives: %d", currentLevel]];
}

- (void)displayFoodCollect {
    
    //NSLog(@"Update Lives is being called!!!\n");
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCLabelTTF *starLabel = [CCLabelTTF labelWithString:@"Food" fontName:@"Marker Felt" fontSize:18.0];
    starLabel.position = ccp(starLabel.contentSize.width/PTM_RATIO/2+400, starLabel.contentSize.height/PTM_RATIO/2+30);
    
    
    NSString* levelString2 = [NSString stringWithFormat:@"%i", currentLevel];
    NSString *levelName = [@"level" stringByAppendingString:levelString2];
    NSString *path = [[NSBundle mainBundle] pathForResource:levelName ofType:@"plist"];
    NSDictionary *level = [NSDictionary dictionaryWithContentsOfFile:path];
    
    goal = [level objectForKey:@"Goal"];
    int gapFruit = 0;
    int gapLabel = 0;
    int yOffset = 32;
    int layer = 10;
    NSArray *keys = [goal allKeys];
    int totalFruitCount = [goal count];
    for (int i =0; i< totalFruitCount; i++){
        NSString *fruit = [keys objectAtIndex: i];
        int numFruits = [[goal objectForKey:fruit] intValue];
        int goalProgressValue = [[goalProgress objectForKey:fruit] intValue];
        CCLabelTTF *label;
        
        Fruit *fruit2 = [[Fruit alloc] initWithFruit:fruit ];
        //fruit2.position = ccp(fruit2.contentSize.width/PTM_RATIO/2 + gapFruit,fruit2.contentSize.height/PTM_RATIO/2 + yOffset);
        if (IsIphone5){
            fruit2.position = ccp(230+gapFruit, 290);
        }
        else{
            fruit2.position = ccp(170+gapFruit, 290);
        }
        [self addChild: fruit2 z: 5];
        
        NSString *numFruitsDisplay = [NSString stringWithFormat: @"X %d", numFruits - goalProgressValue];
        label = [CCLabelTTF labelWithString:@"food"
                                   fontName:@"Marker Felt"
                                   fontSize:18.0];
        if (IsIphone5){
            label.position = ccp(265+gapLabel,290);
        }
        else{
            label.position = ccp(205+gapLabel,290);
        }
        label.string = [NSString stringWithFormat:@"X %d", numFruits - goalProgressValue];
        [self addChild: label z:10];

        [labels setObject: label forKey:fruit];
        gapFruit += 80;
        gapLabel +=80;
        
        
    }
}

- (void) updateFoodCollect {
    
    for (NSString *fruit in labels){
        int numFruits = [[goal objectForKey:fruit] intValue];
        int goalProgressValue = [[goalProgress objectForKey:fruit] intValue];
        CCLabelTTF *label = [labels objectForKey:fruit];
        label.string = [NSString stringWithFormat:@"X %d", numFruits - goalProgressValue];
    }
    
}



- (void)updateBallCount {
    CCLabelTTF *ballCountLabel;
    
    //NSLog(@"Update Lives is being called!!!\n");
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    ballCountLabel = [CCLabelTTF labelWithString:@"level" fontName:@"Marker Felt" fontSize:18.0];
    ballCountLabel.position = ccp(ballCountLabel.contentSize.width/PTM_RATIO/2+150, winSize.height - ballCountLabel.contentSize.height/PTM_RATIO/2+30);
    
    //CCSprite * menuBall = [CCSprite spriteWithFile:@"bullet.png"];
    CCSprite * menuBall = [CCSprite spriteWithFile:@"ball.png"];
    menuBall.position = ccp(menuBall.contentSize.width/PTM_RATIO/2+175, winSize.height - 30);
    
    
   // [self addChild:menuBall z:10];
    
    
    
   // ballCountLabel.string = [NSString stringWithFormat:@"X: %d", bulletCounter];
    //[self addChild: ballCountLabel z:10];
    
    //[_hud incrementLevel:[NSString stringWithFormat:@"Lives: %d", currentLevel]];
}

- (void)starButtonTapped:(id)sender {
    // NSLog(@"Button tapped!!!!!!\n");
    ballsUsed++;
    //_nextProjectile = [CCSprite spriteWithFile:@"bullet.png"];
    _nextProjectile = [CCSprite spriteWithFile:@"ball.png"];
    
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
    circle.m_radius = 15.0/PTM_RATIO;
    
    b2FixtureDef ballShapeDef;
    ballShapeDef.shape = &circle;
    ballShapeDef.density = 0.5f;
    ballShapeDef.friction = 0.0f;
    ballShapeDef.restitution = 1.0f;
    _body->CreateFixture(&ballShapeDef);

//    if (angleInDegrees > 52.0)
//    {
//        angleInDegrees = 49.0;
//    }
//    if (angleInDegrees < -52.0)
//    {
//        angleInDegrees = -50.0;
//    }
    float radianAngle = CC_DEGREES_TO_RADIANS(angleInDegrees);
    [_player runAction:[CCSequence actions:[CCCallBlock actionWithBlock:^{[self addChild:_nextProjectile];_nextProjectile = nil;}],nil]];
    //this determines the speed of the ball projectile
    b2Vec2 force = b2Vec2(2 * cos(radianAngle), 2 * sin(radianAngle));
    
    
    //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"drop_cannon.wav" loop:NO];
    _body->ApplyLinearImpulse(force, ballBodyDef.position);

}

-(void) pause: (CCMenuItem *) sender{
    [[CCDirector sharedDirector] pushScene: (CCScene*)[PauseScene sceneWithLevel: currentLevel]];
}

-(void) restart: (CCMenuItem *) sender{
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5 scene:[PhysicsLayer sceneWithLevel:currentLevel]]];
    //unschedule selectors to get dealloc to fire off
    [self unscheduleAllSelectors];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [super onExit];
}

-(void) autoRestart {
    
  
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:0.5 scene:[PhysicsLayer sceneWithLevel:currentLevel]]];
    [self unscheduleAllSelectors];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [super onExit];
}

-(BOOL) checkLevelCompleted {
    
    if (orangeCollected == 0){
        return NO;
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
    int bestTime = [[levelDict objectForKey:@"best_time"] intValue];
    int bestScore = [[levelDict objectForKey:@"best_score"] intValue];
    //NSLog(@"best_balls: %d", bestBalls);
    // NSLog(@"best_stars: %d", bestStars);
    //
    
    //NSLog(@"After Game before calculation: best stars is %d and last star was %d", [[levelDict objectForKey:@"best_stars"] intValue],[[levelDict objectForKey:@"last_stars"] intValue]);
    
    int stars;

    [levelDict setObject:[NSNumber numberWithInt:seconds] forKey:@"last_time"];
    if (seconds < bestTime){
        [levelDict setObject:[NSNumber numberWithInt:seconds] forKey:@"best_time"];
    }
    if (numFruitCollected >= gold){
        stars = 3;
    }
    else if (numFruitCollected >= silver) {
        stars = 2;
    }
    else if (numFruitCollected >= bronze) {
        stars = 1;
    }
    
    // formula for scoring: time left * number of stars + 50 for completing
    int score = (60 - seconds) * stars * 10 + 50;
    [levelDict setObject:[NSNumber numberWithInt:score] forKey:@"last_score"];
    
    if (score > bestScore){
        [levelDict setObject:[NSNumber numberWithInt:score] forKey:@"best_score"];
    }
    
    [levelDict setObject:[NSNumber numberWithInt: stars] forKey:@"last_stars"];
    if (stars > bestStars){
        bestStars = stars;
    }
    [levelDict setObject:[NSNumber numberWithInt: bestStars] forKey:@"best_stars"];
    
    //[defaults setObject: levelDict forKey:levelString];
    [defaults removeObjectForKey:levelString];
    [defaults setObject:levelDict forKey: levelString];
    [defaults synchronize];
    
    return YES;
}

int tickCounter = 0;
- (void)tick:(ccTime) dt {
    
    mTimeInSec -=dt;

    if ((int) mTimeInSec == 0)
    {
        mTimeInSec = 0.0;
    }
    digit_min = mTimeInSec/60.0f;
    
    digit_sec = ((int)mTimeInSec%60);
    
    min2 = 1;
    
    sec = (int)digit_sec;
    
    if (timeCounter == true)
    {
        [mTimeLbl setString: [NSString stringWithFormat:@":%.2d",int(mTimeInSec)]];
    }
    if (timeCounter == false)
    {
        [mTimeLbl setString: [NSString stringWithFormat:@"%.2d:%.2d",min2, int(mTimeInSec)]];
        timeCounter = true;
    }

    if (IsIphone5){
    mTimeLbl.position = ccp(500,50);
    }
    else{
    mTimeLbl.position = ccp(420,50);
    }
    world->Step(dt, 10, 10);
    std::vector<b2Body *>toDestroy;
    for(b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite *sprite = (__bridge CCSprite *) b->GetUserData();
            // sprite is a ball
            if (sprite.tag == 1){
                sprite.position = ccp(b->GetPosition().x * PTM_RATIO,
                                      b->GetPosition().y * PTM_RATIO);
                sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
                
                if (sprite.position.x <= 0){
                    toDestroy.push_back(b);
                    cannonCounter = 0;

                    [self autoRestart];
                    //}
                }
                // if ball is going too fast, turn on damping
                //we should do this!!
            }
            
            // sprite is a squirrel, set top boundary
            
            if (sprite.tag == 5)
            {
                if (sprite.position.y >= 230){
                
                    float velocity = b->GetLinearVelocity().y;
                    if (velocity > 0) {
                        velocity *= -1;
                        b2Vec2 force = b2Vec2(0, velocity);
                        b->SetLinearVelocity(force);
                    }
                }
                
                // sprite is a squirrel, set bottom boundary
                else if (sprite.position.y <= 30){
                    float velocity = b->GetLinearVelocity().y;
                    if (velocity < 0) {
                        velocity *= -1;
                        b2Vec2 force = b2Vec2(0, velocity);
                        b->SetLinearVelocity(force);
                    }
                }
            }
        }
    }
    
    std::vector<b2Body *>::iterator pos2;
    for (pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
        b2Body *body = *pos2;
        if (body->GetUserData() != NULL) {
            CCSprite *sprite = (__bridge CCSprite *) body->GetUserData();
            [self removeChild:sprite cleanup:YES];
        }
        world->DestroyBody(body);
    }
}




-(void) dealloc
{
	delete world;
    _launchLabel = nil;
    _groundBody = NULL;
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

    //Create an instance called input of Kobold2D's built-in super easy to use touch processor
    KKInput* input = [KKInput sharedInput];
    
    //Create a point, pos, by asking input, our touch processor, where there has been a touch
    CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
    int x = pos.x;
    int y = pos.y;
    
    CGPoint location;

    if (input.anyTouchBeganThisFrame) //someone's touching the screen!! :O
    {
        _MoveableSpriteTouch = FALSE;
        
        // Choose one of the touches to work with
        
        location = [self convertToNodeSpace:pos];
        //CGRect leftBorder = CGRectMake(cageLeft, 0, cageLeft+10, 350);
    }
    
    else if (input.anyTouchEndedThisFrame)
    {
        if (currentLevel == 1 || currentLevel == 2 || currentLevel == 3) // add a list for later
        {
            [self removeChild: message];
        }
        
    }
    
    
    else if (input.touchesAvailable)
    {
        if (CGRectContainsPoint(_player.boundingBox, pos))
        {
            //make sure the cannon does not move offscreen
            if (pos.y < 238 && pos.y > 20)
            {

                _player.position = ccp(_player.position.x, y+5);
                _nextProjectile.position = _player.position;
                cannonHead.position = ccp(cannonHead.position.x, y);
            }
            
            
        }
        
        
        if (pos.x>=cageLeft+5 && pos.x <=80 && pos.y > 20 && pos.y < 238)
        {

            if (cannonCounter ==0 && (pos.y > _player.position.y + 4.0 || pos.y < _player.position.y - 4.0)){}
            else{
            //Steps taken to
            if (cannonCounter ==0)
            {
                cannonHead.position = ccp(cannonHead.position.x - 4.0, y);
                cannonCounter = 1;
            }
            
            float deltaY = pos.y - _player.position.y;
            float deltaX = pos.x - _player.position.x;
            
                if (deltaY < 50.0 && deltaY > -55.0) {

            angleInDegrees = atan2(deltaY, deltaX) * 180 / M_PI;
            
            if ( angleInDegrees < 70 && angleInDegrees > -70)
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
    
    //check contacts
    std::vector<b2Body *>toDestroy;
    std::vector<MyContact>::iterator pos2;
    for (pos2=_contactListener->_contacts.begin();
         pos2 != _contactListener->_contacts.end(); ++pos2) {
        MyContact contact = *pos2;
        
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
            CCSprite *spriteA = (__bridge CCSprite *) bodyA->GetUserData();
            CCSprite *spriteB = (__bridge CCSprite *) bodyB->GetUserData();
            
            //Sprite A = ball, Sprite B = fruit
            if (spriteA.tag == 1 && [spriteB isKindOfClass:[Fruit class]]) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) == toDestroy.end()) {
                    toDestroy.push_back(bodyB);
                    
                    Fruit *fruit = (Fruit*) spriteB;
                    NSString *fruitName = fruit.fruitName;

                    if ([fruitName isEqualToString:@"orange"]){
                        orangeCollected = YES;
                    }
                    
                    numFruitCollected++;
                    
                    int num = [[goal objectForKey:fruitName] intValue];
                    int fruitNum = [[goalProgress objectForKey:fruitName] intValue];
                    fruitNum++;
                    [goalProgress setObject:[NSNumber numberWithInt: fruitNum] forKey:fruitName];
                    int fruitNum2 = [[goalProgress objectForKey:fruitName] intValue];

                }
            }
            
            //Sprite A = fruit, Sprite B = ball
            else if ([spriteA isKindOfClass:[Fruit class]] && spriteB.tag == 1 ) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end()) {
                    toDestroy.push_back(bodyA);
                    Fruit *fruit = (Fruit*) spriteA;
                    NSString *fruitName = fruit.fruitName;
                    numFruitCollected++;
                    
                    if ([fruitName isEqualToString:@"orange"]){
                        orangeCollected = YES;
                    }
                    
                    int num = [[goal objectForKey:fruitName] intValue];
                    int fruitNum = [[goalProgress objectForKey:fruitName] intValue];
                    fruitNum++;
                    [goalProgress setObject:[NSNumber numberWithInt: fruitNum] forKey:fruitName];
                    int fruitNum2 = [[goalProgress objectForKey:fruitName] intValue];
                    [self updateFoodCollect];
                }
            }
            
            //Sprite A = ball, Sprite B = fluffy
            else if (spriteA.tag == 1 && [spriteA isKindOfClass:[Fluffy class]] ) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) == toDestroy.end()) {
                    toDestroy.push_back(bodyA);
                    BOOL levelCompleted = [self checkLevelCompleted];
                    
                    if (levelCompleted){
                        [[CCDirector sharedDirector] replaceScene: (CCScene*)[NextLevelScene sceneWithLevel: currentLevel]];
                        counter = 1;
                        cannonCounter = 0;
                    }
                    
                    else {
                        [[CCDirector sharedDirector] replaceScene: (CCScene*)[LoseScene sceneWithLevel: currentLevel]];
                        cannonCounter = 0;
                    }
                }
                
            }
            
            //Sprite A = squirrel, Sprite B = ball
            else if ([spriteA isKindOfClass:[Squirrel class]] && spriteB.tag == 1 ) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end()) {
                    toDestroy.push_back(bodyB);
                    [self autoRestart];
                }
            }
            
            //Sprite A = ball, Sprite B = squirrel
            else if (spriteA.tag == 1 && [spriteA isKindOfClass:[Squirrel class]] ) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) == toDestroy.end()) {
                    toDestroy.push_back(bodyA);
                    [self autoRestart];
                }
                
            }
            
            //Sprite A = bomb, Sprite B = ball
            else if ([spriteA isKindOfClass:[Bomb class]] && spriteB.tag == 1 ) {
                BOOL lock = true;
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end()) {
                    toDestroy.push_back(bodyB);
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    NSArray *starsArray = [NSArray arrayWithObjects:@"explosion.plist", nil];
                    CCParticleSystemQuad *starsEffect;
                    for(NSString *stars in starsArray) {
                        starsEffect = [CCParticleSystemQuad particleWithFile:stars];
                        starsEffect.position = bombPos;
                        if (lock){
                        [self addChild:starsEffect z:1];
                            [starsEffect setLife:1.5];
                            lock = false;
                            [self performSelector:@selector(autoRestart) withObject:nil afterDelay:2.5f];

                        }
                       
                    }
                   
                }
                
            }
            
            //Sprite A = ball, Sprite B = bomb
            else if (spriteA.tag == 1 && [spriteA isKindOfClass:[Bomb class]] ) {
                BOOL lock = true;
                 CCParticleSystemQuad *starsEffect;
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) == toDestroy.end()) {
                    toDestroy.push_back(bodyA);
                   AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    NSArray *starsArray = [NSArray arrayWithObjects:@"explosion.plist", nil];
                    for(NSString *stars in starsArray) {
                        starsEffect = [CCParticleSystemQuad particleWithFile:stars];
                        starsEffect.position = ccp(400,140);
                        if (lock){
                            [self addChild:starsEffect z:1];
                            [starsEffect setLife:1.5];
                            lock = false;
                            [self performSelector:@selector(autoRestart) withObject:nil afterDelay:2.5f];
                        }
                        
                    }
            }
            }

            //Sprite A = fluffy, Sprite B = ball
            else if ([spriteA isKindOfClass:[Fluffy class]] && spriteB.tag == 1 ) {
                if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end()) {
                    toDestroy.push_back(bodyB);
                    
                    levelCompleted = [self checkLevelCompleted];
                    if (levelCompleted){
                        
                        [[CCDirector sharedDirector] replaceScene: (CCScene*)[NextLevelScene sceneWithLevel: currentLevel]];
                        counter = 1;
                        cannonCounter = 0;
                    }
                    
                    else {
                        [[CCDirector sharedDirector] replaceScene: (CCScene*)[LoseScene sceneWithLevel: currentLevel]];
                        cannonCounter = 0;
                    }
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

-(void) draw
{
    //draw the cage
    ccColor4F buttonColor = ccc4f(0, 0.5, 0.5, 0.5);
    
    int x = cageLeft;
    int y = 0;
    //why can't I use winSize here?
    ccDrawSolidRect( ccp(x, y), ccp(x + 10, y+ 260) , buttonColor);
    
    int barx = 0;
    int bary = cageBottom;
    
    ccColor4F bottomColor = ccc4f(0, 0, 0, 1);
    ccDrawSolidRect( ccp(barx, bary), ccp(568, bary + 5), bottomColor);
}


//-(void) cannonx: (CCMenuItemImage *) menuItem
//{
//    showDialog++;
//    //[self removeChild:tapHere cleanup:YES];
//    [self removeChild:message cleanup:YES];
//    [self removeChild:myTut cleanup: YES];
//    //[tapHere setIsEnabled:NO];
//    
//    if (showDialog == 2)
//    {
//        message = [CCSprite spriteWithFile:@"dialog2.png"];
//        tapHere = [CCMenuItemImage itemWithNormalImage:@"ok2.png" selectedImage: @"ok2.png" target:self selector:@selector(cannonx:)];
//        message.position = ccp(220, 130);
//        tapHere.position = ccp(250, 110);
//        //[tapHere setPosition: _player.position];
//        myTut = [CCMenu menuWithItems: tapHere, nil];
//        myTut.position = CGPointZero;
//        [self addChild:message z:1];
//        [self addChild:myTut z:1];
//    }
//    
//    
//    if (showDialog == 3)
//    {
//        message = [CCSprite spriteWithFile:@"dialog3.png"];
//        tapHere = [CCMenuItemImage itemWithNormalImage:@"ok3.png" selectedImage: @"ok3.png" target:self selector:@selector(cannonx:)];
//        message.position = ccp(230, 150);
//        tapHere.position = ccp(230, 100);
//        
//        myTut = [CCMenu menuWithItems: tapHere, nil];
//        myTut.position = CGPointZero;
//        [self addChild:message z:1];
//        [self addChild:myTut z:1];
//    }
//}

@end