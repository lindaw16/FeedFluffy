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
//	CCMenuItemImage * menuItem1 = [CCMenuItemImage itemWithNormalImage:@"playbutton.png"
//                                                         selectedImage: @"playbutton.png"
//                                                                target:self
//                                                              selector:@selector(goToLevel1:)];
    CCMenuItemImage * playButton = [CCMenuItemImage itemWithNormalImage:@"play.png"
                                                         selectedImage: @"play.png"
                                                                target:self
                                                              selector:@selector(goToLevelSelect:)];
    CCMenuItemImage * bonus = [CCMenuItemImage itemWithNormalImage:@"Bonus.png" selectedImage: @"Bonus.png" target:self selector:@selector(goToBonus:)];
    
    CCMenuItemImage * achievements = [CCMenuItemImage itemWithNormalImage:@"Achievements.png" selectedImage: @"Achievements.png" target:self selector:@selector(goToAchievements:)];
    
    //CCMenuItemImage * fluffy = [CCMenuItemImage itemWithNormalImage: @"fluffy1.png" selectedImage: @"fluffy1.png"];
    
    
    
    
    //Initialize fluffy with the first frame from the spritesheet, fluffy1
    
    CCSprite * fluffy = [CCSprite spriteWithSpriteFrameName:@"fluffy1.png"];
    fluffy.anchorPoint = CGPointZero;
    //fluffy.position = CGPointMake(190.0f, 60.0f);
    fluffy.position = CGPointMake(250.0f, 60.0f);
    
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
	CCMenu * myMenu = [CCMenu menuWithItems:playButton, bonus,achievements, nil];
    
	// Arrange the menu items vertically
	//[myMenu alignItemsVertically];
    //menuItem1.position = ccp(240,95);
    //playButton.position = ccp(400,250);
    //bonus.position = ccp(100, 80);
    //achievements.position = ccp(375, 80);
    
    playButton.position = ccp(480,250);
    bonus.position = ccp(120, 80);
    achievements.position = ccp(420, 80);
    //fluffy.position = ccp(200, 80);
    myMenu.position = ccp(0,0);
    
	// add the menu to your scene
	[self addChild:myMenu];
}


-(id) init{
    //    instanceOfMyClass = self;
    if ((self = [super init])){
        //[self scheduleUpdate];
        
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat: @"the quick brown fox jumps over"]
                                               fontName:@"Yuanti SC"
                                               fontSize:20];
        CCLabelTTF *label2 = [CCLabelTTF labelWithString:[NSString stringWithFormat: @"the lazy dog 1 2 3 4 5 6 7 8 9 0"]
                                               fontName:@"Yuppy TC"
                                               fontSize:20];
        label.position = ccp(250, 280);
        label2.position = ccp(250, 250);
        [self addChild: label z:3];
        [self addChild: label2 z:3];
        
        
        
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

@end
