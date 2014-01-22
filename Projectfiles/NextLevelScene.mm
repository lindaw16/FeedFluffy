//
//  NextLevelScene.m
//  TheRealFluffy
//
//  Created by Clare on 1/22/14.
//
//

#import "NextLevelScene.h"
#import "PhysicsLayer.h"
#import "StartMenuLayer.h"
#import "LevelSelectLayer.h"

@implementation NextLevelScene

+(id) sceneWithLevel:(int)level
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
    NextLevelScene *layer = [[NextLevelScene alloc] initWithLevel:level];
	[scene addChild: layer];
	return scene;
}

-(id)initWithLevel: (int) level{
    if( (self=[super init] )) {
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Level Completed"
                                               fontName:@"Courier New"
                                               fontSize:30];
        label.position = ccp(240,250);
        [self addChild: label];
        [CCMenuItemFont setFontName:@"Courier New"];
        [CCMenuItemFont setFontSize:20];
        
        CCMenuItemImage *Resume= [CCMenuItemImage itemWithNormalImage:@"apple.png"
                                                        selectedImage: @"apple.png" target:self
                                                             selector:@selector(NextLevel:)];
        Resume.tag = level;
        
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
    
    //[[CCDirector sharedDirector] sendCleanupToScene];
    //[[CCDirector sharedDirector] popScene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade
                                               transitionWithDuration:1
                                               scene:[StartMenuLayer node]]
     ];
}

-(void) GoToLevels: (id) sender {
    
    //[[CCDirector sharedDirector] sendCleanupToScene];
    //[[CCDirector sharedDirector] popScene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade
                                               transitionWithDuration:1
                                               scene:[LevelSelectLayer node]]
     ];
}


-(void) Restart: (CCMenuItem*) sender {
    
    //[[CCDirector sharedDirector] sendCleanupToScene];
    //[[CCDirector sharedDirector] popScene];
    int level = sender.tag;
    //[[CCDirector sharedDirector] replaceScene: (CCScene*)[PhysicsLayer sceneWithLevel:level]];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1 scene:[PhysicsLayer sceneWithLevel:level]]];
    
}

-(void) NextLevel: (CCMenuItem*) sender {
    
    //[[CCDirector sharedDirector] sendCleanupToScene];
    //[[CCDirector sharedDirector] popScene];
    int level = sender.tag;
    int nextLevel = level + 1;
    NSLog(@"The level is: %d", level);
    //[[CCDirector sharedDirector] replaceScene: (CCScene*)[PhysicsLayer sceneWithLevel:level]];
    [[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration:1 scene:[PhysicsLayer sceneWithLevel:nextLevel]]];
    
}

@end
