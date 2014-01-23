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
        
        CCMenuItemImage *Resume= [CCMenuItemImage itemWithNormalImage:@"resume_button.png"
                                                        selectedImage: @"resume_button2.png" target:self
                                                  selector:@selector(resume:)];
        
        //CCMenuItem *Restart = [CCMenuItemFont itemFromString:@"Restart" target:self selector:@selector(Restart:)];
        CCMenuItemImage *Restart = [CCMenuItemImage itemWithNormalImage: @"restart_button.png" selectedImage: @"restart_button2.png" target:self
                                                              selector:@selector(Restart:)];
        Restart.tag = level;
    
        //CCMenuItem *Level = [CCMenuItemFont itemFromString:@"Level Select"
                                                   //target:self selector:@selector(GoToLevels:)];
        CCMenuItemImage *Level = [CCMenuItemImage itemWithNormalImage: @"level_select_button.png" selectedImage: @"level_select_button2.png" target:self
                                                            selector:@selector(GoToLevels:)];
        
        //CCMenuItem *Quit = [CCMenuItemFont itemFromString:@"Main Menu"
                                                   //target:self selector:@selector(GoToMainMenu:)];
        CCMenuItemImage *Quit = [CCMenuItemImage itemWithNormalImage: @"main_menu_button.png" selectedImage: @"main_menu_button2.png" target:self
                                                           selector:@selector(GoToMainMenu:)];
        
        CCMenu *menu= [CCMenu menuWithItems: Resume, Restart, Level, Quit, nil];
        menu.position = ccp(249, 131.67f);
        [menu alignItemsVerticallyWithPadding:12.5f];
        
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

@end
