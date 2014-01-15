//
//  LevelSelectLayer.m
//  TheRealFluffy
//
//  Created by Linda Wang on 1/14/14.
//
//

#import "LevelSelectLayer.h"
#import "PhysicsLayer.h"
#import "OopsDNE.h"

@implementation LevelSelectLayer

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	LevelSelectLayer *layer = [LevelSelectLayer node];
    
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
    CCMenuItemImage * tutorials = [CCMenuItemImage itemWithNormalImage:@"tutorials.png"
                                                          selectedImage: @"tutorials.png"
                                                                 target:self
                                                               selector:@selector(goToTutorials:)];
    
    CCMenuItemImage * easy = [CCMenuItemImage itemWithNormalImage:@"Easy.png" selectedImage: @"Easy.png" target:self selector:@selector(goToLevel4:)];
    
	// Create a menu and add your menu items to it
	CCMenu * myMenu = [CCMenu menuWithItems:tutorials, easy, nil];
    
	// Arrange the menu items vertically
	//[myMenu alignItemsVertically];
    //menuItem1.position = ccp(240,95);
    tutorials.position = ccp(180,150);
    easy.position = ccp(450, 150);
    
    myMenu.position = ccp(0,0);
    
	// add the menu to your scene
	[self addChild:myMenu];
}


-(id) init{
    //    instanceOfMyClass = self;
    if ((self = [super init])){
        //[self scheduleUpdate];
        
        //CCSprite *sprite = [CCSprite spriteWithFile:@"eevee.png"];
        CCSprite *sprite = [CCSprite spriteWithFile:@"levelSelectBackground.png"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        [self setUpMenus];
        
    }
    return self;
}

- (void) goToTutorials: (CCMenuItem  *) menuItem
{
	//NSLog(@"The first menu was called");
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[PhysicsLayer alloc] init]];
}

-(void) goToLevel4: (CCMenuItem *) menuItem
{
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[OopsDNE alloc] init]];
}

@end
