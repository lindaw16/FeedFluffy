//
//  OopsDNE.m
//  TheRealFluffy
//
//  Created by Linda Wang on 1/15/14.
//
//

#import "OopsDNE.h"
#import "StartMenuLayer.h"

@implementation OopsDNE

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	OopsDNE *layer = [OopsDNE node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

// set up the Menus
-(void) setUpMenus
{

    CCMenuItemImage * apple = [CCMenuItemImage itemWithNormalImage:@"apple.png"
                                                          selectedImage: @"apple.png"
                                                                 target:self
                                                               selector:@selector(goToStart:)];
    
	// Create a menu and add your menu items to it
	CCMenu * myMenu = [CCMenu menuWithItems:apple, nil];
    
	// Arrange the menu items vertically
	[myMenu alignItemsVertically];
    //menuItem1.position = ccp(240,95);
    apple.position = ccp(300,30);
    myMenu.position = ccp(0,0);
    
	// add the menu to your scene
	[self addChild:myMenu];
}


-(id) init{
    //    instanceOfMyClass = self;
    if ((self = [super init])){
        //[self scheduleUpdate];
        
        //CCSprite *sprite = [CCSprite spriteWithFile:@"eevee.png"];
        CCSprite *sprite = [CCSprite spriteWithFile:@"OopsDNE.png"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        [self setUpMenus];
        
    }
    return self;
}

- (void) goToStart: (CCMenuItem  *) menuItem
{
	//NSLog(@"The first menu was called");
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[StartMenuLayer alloc] init]];
}


@end
