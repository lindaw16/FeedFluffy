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
        
        CCMenuItemImage *nextlevel= [CCMenuItemImage itemWithNormalImage:@"next_level.png"
                                                        selectedImage: @"next_level2.png" target:self
                                                             selector:@selector(NextLevel:)];
        nextlevel.tag = level;
        
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
        
        CCMenu *menu= [CCMenu menuWithItems: nextlevel, replay, levels, quit, nil];
        menu.position = CGPointZero;
        nextlevel.position = ccp(200, 160);
        replay.position = ccp(320, 160);
        levels.position = ccp(200, 100);
        quit.position = ccp(320,100);
        //[menu alignItemsVerticallyWithPadding:12.5f];
        
        [self addChild:menu];
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString *levelString = [@"level" stringByAppendingFormat:@"%d", level];
        NSMutableDictionary *levelDict = [[NSMutableDictionary alloc] init];
        levelDict = [defaults objectForKey:levelString];
        int stars = [[levelDict objectForKey:@"last_stars"] intValue];
        NSLog(@"STARS: %d", stars);
        CCSprite *rank;
        if (stars == 3){
            rank = [CCSprite spriteWithFile:@"gold_star_big.png"];

        }
        else if (stars == 2){
            rank = [CCSprite spriteWithFile:@"silver_star_big.png"];
        }
        else if (stars == 1){
            rank = [CCSprite spriteWithFile:@"bronze_star_big.png"];
        }
        
        rank.position = ccp(240, 200);
        [self addChild: rank z:3];


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
