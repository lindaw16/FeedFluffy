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

@implementation PauseScene
+(id) scene{
    CCScene *scene=[CCScene node];
    PauseScene *layer = [PauseScene node];
    [scene addChild: layer];
    return scene;
}

-(id)init{
    if( (self=[super init] )) {
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Paused"
                                               fontName:@"Courier New"
                                               fontSize:30];
        label.position = ccp(240,190);
        [self addChild: label];
        [CCMenuItemFont setFontName:@"Courier New"];
        [CCMenuItemFont setFontSize:20];
        
        CCMenuItem *Resume= [CCMenuItemFont itemFromString:@"Resume"
                                                    target:self
                                                  selector:@selector(resume:)];
        CCMenuItem *Quit = [CCMenuItemFont itemFromString:@"Quit Game"
                                                   target:self selector:@selector(GoToMainMenu:)];
        
        CCMenu *menu= [CCMenu menuWithItems: Resume, Quit, nil];
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

@end
