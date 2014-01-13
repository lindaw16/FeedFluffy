//
//  StartMenuLayer.m
//  TheRealFluffy
//
//  Created by Linda Wang on 1/12/14.
//
//

#import "StartMenuLayer.h"
#import "GameLayer.h"
#import "PhysicsLayer.h"

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
	CCMenuItemImage * menuItem1 = [CCMenuItemImage itemWithNormalImage:@"playbutton.png"
                                                         selectedImage: @"playbutton.png"
                                                                target:self
                                                              selector:@selector(goToLevel1:)];
	// Create a menu and add your menu items to it
	CCMenu * myMenu = [CCMenu menuWithItems:menuItem1, nil];
    
	// Arrange the menu items vertically
	//[myMenu alignItemsVertically];
    menuItem1.position = ccp(240,95);
    myMenu.position = ccp(0,0);
    
	// add the menu to your scene
	[self addChild:myMenu];
}


-(id) init{
    //    instanceOfMyClass = self;
    if ((self = [super init])){
        //[self scheduleUpdate];
        
    
        /*CCSprite *sprite = [CCSprite spriteWithFile:@"MITplaceholder.png"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];*/
        
        /*sprite = [CCSprite spriteWithFile:@"playbutton.png"];
        sprite.anchorPoint = CGPointZero;
        sprite.position = CGPointMake(80.0f, 0.0f);
        [self addChild:sprite z:0 tag:1];*/
        
        
        [self setUpMenus];
    
        
    }
    return self;
}

- (void) goToLevel1: (CCMenuItem  *) menuItem
{
	NSLog(@"The first menu was called");
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[PhysicsLayer alloc] init]];
}


@end
