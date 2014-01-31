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

@implementation PauseScene
/*+(id) scene{
    CCScene *scene=[CCScene node];
    PauseScene *layer = [PauseScene node];
    [scene addChild: layer];
    return scene;
}*/
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
        
    
        //CCMenuItem *Level = [CCMenuItemFont itemFromString:@"Level Select"
                                                   //target:self selector:@selector(GoToLevels:)];
        CCMenuItemImage *level = [CCMenuItemImage itemWithNormalImage: @"level_select.png" selectedImage: @"level_select2.png" target:self
                                                            selector:@selector(GoToLevels:)];
        
        //CCMenuItem *Quit = [CCMenuItemFont itemFromString:@"Main Menu"
                                                   //target:self selector:@selector(GoToMainMenu:)];
        CCMenuItemImage *quit = [CCMenuItemImage itemWithNormalImage: @"main_menu.png" selectedImage: @"main_menu2.png" target:self selector:@selector(GoToMainMenu:)];
        
        CCMenu *menu= [CCMenu menuWithItems: resume, level, quit, nil];
        
       /* if (IsIphone5)
        {
        menu.position = CGPointZero;
        resume.position = ccp(225, 160);
        restart.position = ccp(345, 160);
        level.position = ccp(225, 100);
        quit.position = ccp(345,100);
        }
        else {
            menu.position = CGPointZero;
            resume.position = ccp(185, 160);
            restart.position = ccp(305, 160);
            level.position = ccp(185, 100);
            quit.position = ccp(305,100);
        }*/
        //[menu alignItemsVerticallyWithPadding:12.5f];
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
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade
                                               transitionWithDuration:1
                                               scene:[EasyLevelLayer node]]
     ];
}


-(void) Restart: (CCMenuItem*) sender {
    
    [[CCDirector sharedDirector] sendCleanupToScene];
    [[CCDirector sharedDirector] popScene];
    int level = sender.tag;
    //[[CCDirector sharedDirector] replaceScene: (CCScene*)[PhysicsLayer sceneWithLevel:level]];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1 scene:[PhysicsLayer sceneWithLevel:level]]];

}

-(void) onExit {
    //unschedule selectors to get dealloc to fire off
    [self unscheduleAllSelectors];
    //remove all textures to free up additional memory. Textures get retained even if the sprite gets released and it doesn't show as a leak. This was my big memory saver
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
