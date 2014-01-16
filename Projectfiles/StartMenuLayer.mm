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
    
	// Create a menu and add your menu items to it
	CCMenu * myMenu = [CCMenu menuWithItems:playButton, bonus,achievements, nil];
    
	// Arrange the menu items vertically
	//[myMenu alignItemsVertically];
    //menuItem1.position = ccp(240,95);
    playButton.position = ccp(400,250);
    bonus.position = ccp(100, 80);
    achievements.position = ccp(375, 80);
    myMenu.position = ccp(0,0);
    
	// add the menu to your scene
	[self addChild:myMenu];
}


-(id) init{
    //    instanceOfMyClass = self;
    if ((self = [super init])){
        //[self scheduleUpdate];
        
        //CCSprite *sprite = [CCSprite spriteWithFile:@"eevee.png"];
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
