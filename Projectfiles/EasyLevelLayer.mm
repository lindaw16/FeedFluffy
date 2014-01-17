//
//  EasyLevelLayer.m
//  TheRealFluffy
//
//  Created by Srinidhi Viswanathan on 1/18/14.
//
//

#import "EasyLevelLayer.h"
#import "StartMenuLayer.h"
#import "PhysicsLayer.h"
#import "LevelSelectLayer.h"

@implementation EasyLevelLayer

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

-(id) init{
    //    instanceOfMyClass = self;
    if ((self = [super init])){

        CGSize size = [[CCDirector sharedDirector] winSize];

        // background
        CCSprite *bg = [CCSprite spriteWithFile:@"bg.png"];
        bg.position = ccp(size.width / 2, size.height / 2);
        [self addChild:bg];
        
        
        //[self setUpMenus];
        [self scheduleUpdate];
        
    }
    return self;
}


@end
