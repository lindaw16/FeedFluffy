//
//  PauseScene.m
//  TheRealFluffy
//
//  Created by Clare on 1/18/14.
//
//

#import "PauseScene.h"
#import "StartMenuLayer.h"
#import "PhysicsLayer.h"
#import "LevelSelectLayer.h"
#import "EasyLevelLayer.h"
#import "MediumLevelLayer.h"

int thisLevel;

@implementation PauseScene

+(id) sceneWithLevel:(int)level
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
    PauseScene *layer = [[PauseScene alloc] initWithLevel:level];
	[scene addChild: layer];
	return scene;
}

-(id)initWithLevel: (int) level{
    thisLevel = level;
    if( (self=[super init] )) {
        if (IsIphone5)
        {
            CCSprite *bg = [CCSprite spriteWithFile:@"pause_background.png"];
            bg.anchorPoint = CGPointZero;
            [self addChild:bg z:-1];
        }
        else{
            CCSprite *bg = [CCSprite spriteWithFile:@"pause_background35.png"];
            bg.anchorPoint = CGPointZero;
            [self addChild:bg z:-1];
        }

        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Paused!"
                                               fontName:@"Marker Felt"
                                               fontSize:30];
       
        if (IsIphone5){
            label.position = ccp(284, 250);
        }
        else{
        label.position = ccp(240,250);
        }
        [self addChild: label];
        [CCMenuItemFont setFontName:@"Courier New"];
        [CCMenuItemFont setFontSize:20];
        
        CCMenuItemImage *resume= [CCMenuItemImage itemWithNormalImage:@"resume.png"
                                                        selectedImage: @"resume2.png" target:self
                                                             selector:@selector(resume:)];
        
        CCMenuItemImage *level = [CCMenuItemImage itemWithNormalImage: @"level_select.png" selectedImage: @"level_select2.png" target:self
                                                            selector:@selector(GoToLevels:)];
        

        CCMenuItemImage *quit = [CCMenuItemImage itemWithNormalImage: @"main_menu.png" selectedImage: @"main_menu2.png" target:self selector:@selector(GoToMainMenu:)];
        
        CCMenu *menu= [CCMenu menuWithItems: resume, level, quit, nil];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        [menu alignItemsVerticallyWithPadding:12.5f];
        menu.position =  ccp(winSize.width/2, winSize.height/2);
        [self addChild:menu];
        
    }
    return self;
}

-(void) resume: (id) sender {
    
    [[CCDirector sharedDirector] popScene];
}

-(void) GoToMainMenu: (id) sender {
    
    [[CCDirector sharedDirector] sendCleanupToScene];
    [[CCDirector sharedDirector] popScene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade
                                               transitionWithDuration:1
                                               scene:[StartMenuLayer node]]
     ];
}

-(void) GoToLevels: (id) sender {
    
    [[CCDirector sharedDirector] sendCleanupToScene];
    [[CCDirector sharedDirector] popScene];
    
    if (thisLevel < 13){
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade
                                               transitionWithDuration:1
                                               scene:[EasyLevelLayer node]]
     ];
    }
    else {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade
                                                   transitionWithDuration:1
                                                   scene:[MediumLevelLayer node]]
         ];
    }
}

-(void) onExit {
    //unschedule selectors to get dealloc to fire off
    [self unscheduleAllSelectors];
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [super onExit];
}

-(void) dealloc
{
#ifndef KK_ARC_ENABLED
	[super dealloc];
#endif
}

@end
