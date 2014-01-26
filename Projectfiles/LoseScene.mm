//
//  LoseScene.m
//  TheRealFluffy
//
//  Created by Clare on 1/25/14.
//
//

#import "LoseScene.h"
#import "PhysicsLayer.h"
#import "StartMenuLayer.h"
#import "LevelSelectLayer.h"

@implementation LoseScene

+(id) sceneWithLevel:(int)level
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
    LoseScene *layer = [[LoseScene alloc] initWithLevel:level];
	[scene addChild: layer];
	return scene;
}

-(id)initWithLevel: (int) level{
    if( (self=[super init] )) {
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"You didn't feed Fluffy!"
                                               fontName:@"Marker Felt"
                                               fontSize:30];
        label.position = ccp(240,250);
        [self addChild: label];
        [CCMenuItemFont setFontName:@"Courier New"];
        [CCMenuItemFont setFontSize:20];
        
        
        //CCMenuItem *Restart = [CCMenuItemFont itemFromString:@"Restart" target:self selector:@selector(Restart:)];
        CCMenuItemImage *replay = [CCMenuItemImage itemWithNormalImage: @"replay.png" selectedImage: @"replay2.png" target:self
                                                              selector:@selector(Restart:)];
        replay.tag = level;
        
        //CCMenuItem *Level = [CCMenuItemFont itemFromString:@"Level Select"
        //target:self selector:@selector(GoToLevels:)];
        CCMenuItemImage *levels = [CCMenuItemImage itemWithNormalImage: @"level_select.png" selectedImage: @"level_select2.png" target:self
                                                              selector:@selector(GoToLevels:)];
        
        //CCMenuItem *Quit = [CCMenuItemFont itemFromString:@"Main Menu"
        //target:self selector:@selector(GoToMainMenu:)];
        CCMenuItemImage *quit = [CCMenuItemImage itemWithNormalImage: @"main_menu.png" selectedImage: @"main_menu2.png" target:self
                                                            selector:@selector(GoToMainMenu:)];
        
        CCMenu *menu= [CCMenu menuWithItems: replay, levels, quit, nil];
        menu.position = CGPointZero;
        replay.position = ccp(320, 160);
        levels.position = ccp(200, 100);
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
