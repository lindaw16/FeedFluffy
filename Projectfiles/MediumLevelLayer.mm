//
//  MediumLevelLayer.m
//  TheRealFluffy
//
//  Created by Srinidhi Viswanathan on 1/28/14.
//
//

#import "MediumLevelLayer.h"

#import "PhysicsLayer.h"
#import "LevelSelectLayer.h"


@implementation MediumLevelLayer


int numLevels2 = 12;
int numCol2 = 4;
//int numRow;
const float PTM = 32.0f;

int leftMargin2 = 120;
int topMargin2 = 240;
CCSprite *level2;


+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	MediumLevelLayer *layer = [MediumLevelLayer node];
    
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
    
    for (int i = 12; i < numLevels2+12; i++)
    {
        int levelCompleted;
        if (i >= 12){
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
            x = leftMargin2 + 110 * ((i - 12) % numCol2);
            
        }
        else{
            x = leftMargin2 + 80 * ((i - 12)% numCol2);
        }
        int y =  topMargin2 - ((i - 12)/numCol2)*75;
        
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
            level2 = [CCMenuItemImage itemWithNormalImage:@"apple_level.png" selectedImage:@"apple_level.png" target:self selector: @selector(goToLevel:)];
            level2.tag = i + 1;
            level2.position = ccp(x, y);
            CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat: @"%d", level2.tag]
                                                   fontName:@"Papyrus"
                                                   fontSize:26];
            label.position = ccp(x,y-3);
            [myLevels addChild: level2];
            [self addChild: label z:3];
        }
        else {
            level2 = [CCMenuItemImage itemWithNormalImage:@"apple_level.png" selectedImage:@"apple_level.png" target:self selector: @selector(doNothing:)];
            CCSprite *lock = [CCSprite spriteWithFile:@"lock.png"];
            lock.position = ccp(x,y-3);
            [self addChild: lock z:3];
            
            [myLevels addChild: level2];
            level2.position = ccp(x, y);
        }
        
    }

    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hard!"
                                           fontName:@"Marker Felt"
                                           fontSize:47];
    
    if (IsIphone5) { label.position = ccp(284,280);}
    else{label.position = ccp(240,270); }
    [self addChild: label];
    
    [self addChild: myLevels z:1];
    
    CCMenuItemImage *quit = [CCMenuItemImage itemWithNormalImage: @"level_select.png" selectedImage: @"level_select2.png" target:self selector:@selector(GoToMainMenu:)];
    
    if (IsIphone5) { quit.position = ccp(60, 290);}
    else{quit.position = ccp(60, 290);}
    
    [myLevels addChild: quit];
    
}



-(id) init
{
    if ((self = [super init] ))
    {
        //numRow = numLevel2 / numCol2 + 1;
        
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
