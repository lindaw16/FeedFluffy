//
//  EasyLevelLayer.m
//  TheRealFluffy
//
//  Created by Srinidhi Viswanathan on 1/18/14.
//
//

#import "EasyLevelLayer.h"
//#import "StartMenuLayer.h"
//#import "PhysicsLayer.h"
//#import "LevelSelectLayer.h"

#import "PhysicsLayer.h"
#import "LevelSelectLayer.h"



@implementation EasyLevelLayer

int numLevels = 12;
int numCol = 4;
//int numRow;
const float PTM = 32.0f;

int leftMargin = 120;
int topMargin = 220;
CCSprite *level;

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	EasyLevelLayer *layer = [EasyLevelLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}


-(void) setUpMenus
{
    
    CCMenu *myLevels = [CCMenu menuWithItems:nil];
    myLevels.position = ccp(0, 0);
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    for (int i = 0; i < numLevels; i++)
    {
        //        if (! [NSString stringWithFormat:@"level%dLocked", i])
        
        // level = [CCMenuItemImage itemWithNormalImage:@"apple_level.png" selectedImage:@"apple_level.png" target:self selector: @selector(goToLevel:)];
        
        //        [NSString stringWithFormat:@"level%d", i].tag = i;
        //        [NSString stringWithFormat:@"level%d", i].position = (60 + 60*i, 150);
        //        [myLevels addChild: [NSString stringWithFormat:@"level%d", i]];
        int levelCompleted;
        if (i >= 1){
            NSString *levelString = [@"level" stringByAppendingFormat:@"%d", i];
            NSMutableDictionary *levelDict = [[NSMutableDictionary alloc] init];
            levelDict = [defaults objectForKey:levelString];
            levelCompleted = [[levelDict objectForKey:@"completed"] intValue];
        }
        
        NSString *levelString = [@"level" stringByAppendingFormat:@"%d", i + 1];
        NSMutableDictionary *levelDict = [[NSMutableDictionary alloc] init];
        levelDict = [defaults objectForKey:levelString];
        int currentLevelCompleted = [[levelDict objectForKey:@"completed"] intValue];
        int x;
        if (IsIphone5){
        x = leftMargin + 110 * (i % numCol);
            
        }
        else{
        x = leftMargin + 80 * (i % numCol);
        }
        int y =  topMargin - (i/numCol)*75;
        
        //level.position = ccp(leftMargin + 80 * (i % numCol), topMargin - (i/ numCol) * 60);
        //[myLevels addChild: level];
        
        if (currentLevelCompleted == 1){
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            NSString *levelString = [@"level" stringByAppendingFormat:@"%d", i+1];
            NSMutableDictionary *levelDict = [[NSMutableDictionary alloc] init];
            levelDict = [defaults objectForKey:levelString];
            int stars1 = [[levelDict objectForKey:@"last_stars"] intValue];
            int stars = [[levelDict objectForKey:@"best_stars"] intValue];
            NSLog(@"STARS: %d", stars);
            NSLog(@"LAST_STARS: %d", stars1);
            
            if (stars == 3){
                CCSprite *gold = [CCSprite spriteWithFile:@"gold_star.png"];
                gold.position = ccp(x+15, y-20);
                [self addChild: gold z:3];
            }
            else if (stars == 2){
                CCSprite *gold = [CCSprite spriteWithFile:@"silver_star.png"];
                gold.position = ccp(x+15, y-20);
                [self addChild: gold z:3];
            }
            else if (stars == 1){
                CCSprite *gold = [CCSprite spriteWithFile:@"bronze_star.png"];
                gold.position = ccp(x+15, y-20);
                [self addChild: gold z:3];
            }

        }
        if (levelCompleted == 1 or i == 0){
            level = [CCMenuItemImage itemWithNormalImage:@"apple_level.png" selectedImage:@"apple_level.png" target:self selector: @selector(goToLevel:)];
            level.tag = i + 1;
            level.position = ccp(x, y);
            CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat: @"%d", level.tag]
                                                   fontName:@"Papyrus"
                                                   fontSize:26];
            label.position = ccp(x,y-3);
            [myLevels addChild: level];
            [self addChild: label z:3];
        }
        else {
            level = [CCMenuItemImage itemWithNormalImage:@"apple_level.png" selectedImage:@"apple_level.png" target:self selector: @selector(doNothing:)];
            CCSprite *lock = [CCSprite spriteWithFile:@"lock.png"];
            lock.position = ccp(x,y-3);
            [self addChild: lock z:3];
            
            [myLevels addChild: level];
            level.position = ccp(x, y);
        }
        
    }
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Easy!"
                                           fontName:@"Marker Felt"
                                           fontSize:47];
    
    if (IsIphone5) { label.position = ccp(284,280);}
    else{label.position = ccp(240,270); }
    [self addChild: label];
    
    CCMenuItemImage *quit = [CCMenuItemImage itemWithNormalImage: @"level_select.png" selectedImage: @"level_select2.png" target:self selector:@selector(GoToMainMenu:)];
    
    if (IsIphone5) { quit.position = ccp(60, 290);}
    else{quit.position = ccp(60, 290);}
    
    [myLevels addChild: quit];
    
    [self addChild: myLevels z:1];
    
}



-(id) init
{
    if ((self = [super init] ))
    {
        //numRow = numLevels / numCol + 1;
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        CCSprite *bg = [CCSprite spriteWithFile:@"bg.png"];
        
        //bg.anchorPoint = CGPointZero;
        if (IsIphone5){
            bg.position = ccp(284, 140);
            bg.scaleX = 1.2;
            bg.scaleY = 1.2;
        }
        else {
        bg.position = ccp(240, 140);
        }
        
        [self addChild:bg];
        [self setUpMenus];
    }
    
    return self;
    
}



- (void) goToLevel: (CCMenuItem *) menuItem  {
    
    int level = menuItem.tag;
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[PhysicsLayer sceneWithLevel:level]];
}

- (void) doNothing: (CCMenuItem *) menuItem  {
    
}

-(void) GoToMainMenu: (id) sender {

    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade
                                               
                                               transitionWithDuration:1
                                               
                                               scene:[LevelSelectLayer node]]
     
     ];
    
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
