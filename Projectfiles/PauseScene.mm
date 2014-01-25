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
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Paused"
                                               fontName:@"Courier New"
                                               fontSize:30];
        label.position = ccp(240,250);
        [self addChild: label];
        [CCMenuItemFont setFontName:@"Courier New"];
        [CCMenuItemFont setFontSize:20];
        
        CCMenuItemImage *resume= [CCMenuItemImage itemWithNormalImage:@"resume.png"
                                                        selectedImage: @"resume2.png" target:self
                                                  selector:@selector(resume:)];
        
        //CCMenuItem *Restart = [CCMenuItemFont itemFromString:@"Restart" target:self selector:@selector(Restart:)];
        CCMenuItemImage *restart = [CCMenuItemImage itemWithNormalImage: @"restart.png" selectedImage: @"restart2.png" target:self
                                                              selector:@selector(Restart:)];
        restart.tag = level;
    
        //CCMenuItem *Level = [CCMenuItemFont itemFromString:@"Level Select"
                                                   //target:self selector:@selector(GoToLevels:)];
        CCMenuItemImage *level = [CCMenuItemImage itemWithNormalImage: @"level_select.png" selectedImage: @"level_select2.png" target:self
                                                            selector:@selector(GoToLevels:)];
        
        //CCMenuItem *Quit = [CCMenuItemFont itemFromString:@"Main Menu"
                                                   //target:self selector:@selector(GoToMainMenu:)];
        CCMenuItemImage *quit = [CCMenuItemImage itemWithNormalImage: @"main_menu.png" selectedImage: @"main_menu2.png" target:self
                                                           selector:@selector(GoToMainMenu:)];
        
        CCMenu *menu= [CCMenu menuWithItems: resume, restart, level, quit, nil];
        menu.position = CGPointZero;
        resume.position = ccp(200, 160);
        restart.position = ccp(320, 160);
        level.position = ccp(200, 100);
        quit.position = ccp(320,100);
        
        //[menu alignItemsVerticallyWithPadding:12.5f];
        
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
