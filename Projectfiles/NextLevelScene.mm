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
#import "EasyLevelLayer.h"


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
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"fluffyframes.plist"];
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"fluffyframes.png"];
        [self addChild:spriteSheet];
        waggingFrames = [NSMutableArray array];
        for(int i = 1; i <= 6; ++i)
        {
            [waggingFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"fluffy%d.png", i]]];
        }
        
        
        
        CCSprite *bg = [CCSprite spriteWithFile:@"pause_background.png"];
        bg.anchorPoint = CGPointZero;
        [self addChild:bg];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Level Completed!"
                                               fontName:@"Marker Felt"
                                               fontSize:30];
    
        
        

        
        CCSprite *fluffy = [CCSprite spriteWithSpriteFrameName:@"fluffy1.png"];
        fluffy.anchorPoint = CGPointZero;
        fluffy.scaleX = 0.7;
        fluffy.scaleY = 0.7;
        
        
        CCAnimation *wagging = [CCAnimation animationWithSpriteFrames: waggingFrames delay:0.2f];
        wag = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:wagging]];
        wagging.restoreOriginalFrame = NO;
        [fluffy runAction:wag];
        [self addChild:fluffy z:1];
        
        
        if (IsIphone5)
        {
            label.position = ccp(284,260);
            fluffy.position = ccp(350, 170);
        }
        else{
            label.position = ccp(240,270);
            fluffy.position = ccp(420, 135);
        }
        
        
    
        
        
        [self addChild: label];
        CCLabelTTF *feedingFluffy = [CCLabelTTF labelWithString:@"Feeding Fluffy: 50"
                                               fontName:@"Marker Felt"
                                               fontSize:18];
        feedingFluffy.position = ccp(200,180);
        
        CCLabelTTF *timeBonus= [CCLabelTTF labelWithString:@"Time Bonus: 50"
                                                       fontName:@"Marker Felt"
                                                       fontSize:18];
        timeBonus.position = ccp(200,120);
        
        [self addChild:feedingFluffy];
        [self addChild: timeBonus];
        
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
        
        if (IsIphone5)
        {
        menu.position = CGPointZero;
        nextlevel.position = ccp(155, 50);
        replay.position = ccp(295, 50);
        levels.position = ccp(435, 50);
        //quit.position = ccp(345,90);
        }
        
        else{
            menu.position = CGPointZero;
            nextlevel.position = ccp(120, 60);
            replay.position = ccp(220, 60);
            levels.position = ccp(320, 60);
            //quit.position = ccp(305,90);
        }
        

        
        
        
        //[menu alignItemsVerticallyWithPadding:12.5f];
        
        [self addChild:menu];
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString *levelString = [@"level" stringByAppendingFormat:@"%d", level];
        NSMutableDictionary *levelDict = [[NSMutableDictionary alloc] init];
        levelDict = [defaults objectForKey:levelString];
        int time = [[levelDict objectForKey:@"last_time"] intValue];
        int bestTime = [[levelDict objectForKey:@"best_time"] intValue];
        
        NSString *timeString = [@"Time: " stringByAppendingFormat: @"%d", time];
        CCLabelTTF *timeLabel = [CCLabelTTF labelWithString:timeString
                                               fontName:@"Marker Felt"
                                               fontSize:30];
        NSString *bestTimeString = [@"Your best time: " stringByAppendingFormat: @"%d", bestTime];
        CCLabelTTF *bestTimeLabel = [CCLabelTTF labelWithString:bestTimeString
                                                   fontName:@"Marker Felt"
                                                   fontSize:30];
        timeLabel.position = ccp(200, 70);
        bestTimeLabel.position = ccp(250, 50);
        [self addChild: timeLabel z:3];
        [self addChild: bestTimeLabel z:3];
        
        int stars = [[levelDict objectForKey:@"last_stars"] intValue];

        CCSprite *rank;
        if (stars == 3){
            rank = [CCSprite spriteWithFile:@"gold_star_big.png"];
            [rank setScaleX:0.8];
            [rank setScaleY:0.8];

        }
        else if (stars == 2){
            rank = [CCSprite spriteWithFile:@"silver_star_big.png"];
         
            [rank setScaleX:0.5];
            [rank setScaleY:0.5];

        }
        else if (stars == 1){
            rank = [CCSprite spriteWithFile:@"bronze_star.png"];
        }
        
        
        if (IsIphone5){
            rank.position = ccp(284,205);
        }
        else{
        rank.position = ccp(240, 210);
        }
        
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
                                               scene:[EasyLevelLayer node]]
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
