//
//  StartMenuLayer.m
//  TheRealFluffy
//
//  Created by Linda Wang on 1/12/14.
//
//

#import "StartMenuLayer.h"
#import "PhysicsLayer.h"
#import "LevelSelectLayer.h"
#import "OopsDNE.h"

int NUM_LEVELS = 20;
CCSprite * fluffy;

@implementation StartMenuLayer

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	StartMenuLayer *layer = [StartMenuLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

// set up the Menus
-(void) setUpMenus
{
    
	// Create some menu items
    CCMenuItemImage * playButton = [CCMenuItemImage itemWithNormalImage:@"play.png"
                                                         selectedImage: @"play.png"
                                                                target:self
                                                              selector:@selector(goToLevelSelect:)];
    //CCMenuItemImage * bonus = [CCMenuItemImage itemWithNormalImage:@"Bonus.png" selectedImage: @"Bonus.png" target:self selector:@selector(goToBonus:)];
    
    //CCMenuItemImage * achievements = [CCMenuItemImage itemWithNormalImage:@"Achievements.png" selectedImage: @"Achievements.png" target:self selector:@selector(goToAchievements:)];
    
    
    
    //Initialize fluffy with the first frame from the spritesheet, fluffy1
    
    fluffy = [CCSprite spriteWithSpriteFrameName:@"fluffy1.png"];
    fluffy.anchorPoint = CGPointZero;
    //fluffy.position = CGPointMake(190.0f, 60.0f);
    
    if (IsIphone5)
    {
        fluffy.position = CGPointMake(250.0f, 50.0f);
    }
    else {
        fluffy.position = CGPointMake(211.0f, 40.0f);
    }

    
    
    CCSprite *orange = [CCSprite spriteWithFile:@"orange.png"];
    CCSprite *strawberry = [CCSprite spriteWithFile:@"strawberry.png"];
CCSprite *apple = [CCSprite spriteWithFile:@"apple.png"];
    CCSprite *pear = [CCSprite spriteWithFile:@"pear.png"];
    CCSprite *lemon2 = [CCSprite spriteWithFile:@"lemon.png"];
    
    if (IsIphone5){
    orange.position = ccp(430,36);
    strawberry.position = ccp(470,40);
    apple.position = ccp(150,30);
    pear.position = ccp(220,30);
    lemon2.position = ccp(520, 25);
    }
    
    else{
        orange.position = ccp(380,30);
        strawberry.position = ccp(430,33);
        apple.position = ccp(140,30);
        pear.position = ccp(200,30);
        lemon2.position = ccp(520, 25);
    }
    apple.rotation = -15.0;
    lemon2.rotation = 15.0;
    orange.rotation = -10.0;
    strawberry.rotation = 13.0;

    
    
    
    
    [self addChild:orange];
    [self addChild:strawberry];
    [self addChild:apple];
    [self addChild:pear
     ];
    [self addChild:lemon2];
    
    //Create an animation from the set of frames
    
    //CCAnimation *wagging = [CCAnimation animationWithFrames: waggingFrames delay:0.1f];
    CCAnimation *wagging = [CCAnimation animationWithSpriteFrames: waggingFrames delay:0.2f];
    
    //Create an action with the animation that can then be assigned to a sprite
    
    //wag = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:wagging restoreOriginalFrame:NO]];
    wag = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:wagging]];
    wagging.restoreOriginalFrame = NO;
           
    
    //tell the bear to run the taunting action
    [fluffy runAction:wag];
    
    [self addChild:fluffy z:1];
    
    
    //Create an action with the animation that can then be assigned to a sprite
 
    
    
    
    
	// Create a menu and add your menu items to it
	//CCMenu * myMenu = [CCMenu menuWithItems:playButton, bonus,achievements, nil];
    CCMenu * myMenu = [CCMenu menuWithItems:playButton, nil];
    
	// Arrange the menu items vertically
	//[myMenu alignItemsVertically];
    //menuItem1.position = ccp(240,95);
    //playButton.position = ccp(400,250);
    //bonus.position = ccp(100, 80);
    //achievements.position = ccp(375, 80);
    
    if (IsIphone5){
    playButton.position = ccp(450,245);
    }
    else {
        playButton.position = ccp (388,230);
    }
    //bonus.position = ccp(120, 80);
    //achievements.position = ccp(420, 80);
    //fluffy.position = ccp(200, 80);
    myMenu.position = ccp(0,0);
    
	// add the menu to your scene
	[self addChild:myMenu];
}


-(id) init{
    //    instanceOfMyClass = self;
    if ((self = [super init])){
        //[self scheduleUpdate];
        
        
//        CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat: @"the quick brown fox jumps over"]
//                                               fontName:@"Yuanti SC"
//                                               fontSize:20];
//        CCLabelTTF *label2 = [CCLabelTTF labelWithString:[NSString stringWithFormat: @"the lazy dog 1 2 3 4 5 6 7 8 9 0"]
//                                               fontName:@"Yuppy TC"
//                                               fontSize:20];
//        label.position = ccp(250, 280);
//        label2.position = ccp(250, 250);
//        [self addChild: label z:3];
//        [self addChild: label2 z:3];
        
        
        CCSprite * squirrel = [CCSprite spriteWithFile:@"rightsquirrel.png"];
        squirrel.anchorPoint = CGPointZero;
        //fluffy.position = CGPointMake(190.0f, 60.0f);
        squirrel.position = CGPointMake(50.0f, 40.0f);
        
        [self addChild:squirrel];
        
        
        
        //Load the plist which tells Kobold2D how to properly parse your spritesheet. If on a retina device Kobold2D will automatically use bearframes-hd.plist
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"fluffyframes.plist"];
        
        //Load in the spritesheet, if retina Kobold2D will automatically use bearframes-hd.png
        
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"fluffyframes.png"];
        
        [self addChild:spriteSheet];
        
        //Define the frames based on the plist - note that for this to work, the original files must be in the format bear1, bear2, bear3 etc...
        
        //When it comes time to get art for your own original game, makegameswith.us will give you spritesheets that follow this convention, <spritename>1 <spritename>2 <spritename>3 etc...
        
        waggingFrames = [NSMutableArray array];
        
        for(int i = 1; i <= 6; ++i)
        {
            [waggingFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"fluffy%d.png", i]]];
        }
        
        
        // reset NSUserDefaults
        //NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
        //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
        
        // Get a pointer to the NSUserDefaults object
        NSUserDefaults * standardDefaults = [NSUserDefaults standardUserDefaults];
        for (int i = 0; i < NUM_LEVELS; i++){
            NSString *levelString = [@"level" stringByAppendingFormat:@"%d", i];
            // initialize all levels as not completed
            NSMutableDictionary *levelDict = [[NSMutableDictionary alloc] init];
            //levelDict = [[NSMutableDictionary alloc] init];
            [levelDict setObject:@NO forKey: @"completed"];
            [levelDict setObject:@0 forKey: @"last_stars"];
            [levelDict setObject:[NSNumber numberWithInt: 0] forKey: @"best_stars"];
            [levelDict setObject:@0 forKey: @"last_score"];
            [levelDict setObject:[NSNumber numberWithInt: 0] forKey: @"best_score"];
            [levelDict setObject:@0 forKey: @"last_balls"];
            [levelDict setObject:[NSNumber numberWithInt: 100] forKey: @"best_balls"];
            
            //[standardDefaults registerDefaults:@{levelString: @NO}];
            [standardDefaults registerDefaults:@{levelString: levelDict}];
            [standardDefaults synchronize];
        }
        
        //CCSprite *sprite = [CCSprite spriteWithFile:@"menuBackground.png"];
        CCSprite *sprite = [CCSprite spriteWithFile:@"menuBackground.png"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        //[self scheduleUpdate];
        [self setUpMenus];
        
    }
    return self;
}

- (void) goToLevelSelect: (CCMenuItem  *) menuItem
{
	//NSLog(@"The first menu was called");
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[LevelSelectLayer alloc] init]];
}


- (void) goToAchievements: (CCMenuItemImage *) menuItem
{
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[OopsDNE alloc] init]];
}

- (void) goToBonus: (CCMenuItemImage *) menuItem
{
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[OopsDNE alloc] init]];
}

-(void) onExit {
    //unschedule selectors to get dealloc to fire off
    [self unscheduleAllSelectors];
    //remove all textures to free up additional memory. Textures get retained even if the sprite gets released and it doesn't show as a leak. This was my big memory saver
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [super onExit];
}

//- (void) update:(ccTime)dt
//{
//    
//    //move fluffy only in the x direction by a fixed amount every frame
//    fluffy.position = ccp( fluffy.position.x + 100*dt, fluffy.position.y );
//    
//    if (fluffy.position.x > 480+32)
//    {
//        
//        //if fluffy reaches the edge of the screen, loop around
//        fluffy.position = ccp( -32, fluffy.position.y );
//        
//    }
//}



-(void) dealloc
{
#ifndef KK_ARC_ENABLED
	[super dealloc];
#endif
}

@end
