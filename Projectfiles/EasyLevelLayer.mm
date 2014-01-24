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

int numLevels = 16;
int numCol = 4;
//int numRow;
const float PTM = 32.0f;

int leftMargin = 60;
int topMargin = 250;
CCSprite *level;


@implementation EasyLevelLayer

//+(id) scene
//{
//	// 'scene' is an autorelease object.
//	CCScene *scene = [CCScene node];
//    
//	// 'layer' is an autorelease object.
//	StartMenuLayer *layer = [StartMenuLayer node];
//    
//	// add layer as a child to scene
//	[scene addChild: layer];
//    
//	// return the scene
//	return scene;
//}


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
        
        
        int x = leftMargin + 80 * (i % numCol);
        int y =  topMargin - (i/numCol)*60;
        
        //level.position = ccp(leftMargin + 80 * (i % numCol), topMargin - (i/ numCol) * 60);
        //[myLevels addChild: level];
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
            lock.position = ccp(x,y);
            [self addChild: lock z:3];
            
            [myLevels addChild: level];
            level.position = ccp(x, y);
        }
        
        //        [NSString stringWithFormat:@"level%d", i].tag = i;
        //        CCLabelTTF * [NSString stringWithFormat:@"Label%d", i]= [CCLabelTTF labelWithString:@"%d", i
        //                                               fontName:@"Verdana"
        //                                               fontSize:26];
        //        levelx.position = ccp(60 + 60*i, 150);
        //
        //        }
    }
    
    //CCMenu * myLevels = [CCMenu menuWithItems: level1, level2, level3, level4, level5, nil];
    
    [self addChild: myLevels z:1];
    
}



-(id) init
{
    if ((self = [super init] ))
    {
        //numRow = numLevels / numCol + 1;
        
        
        CCSprite *bg = [CCSprite spriteWithFile:@"bg.png"];
        
        //bg.anchorPoint = CGPointZero;
        bg.position = ccp(0, 0);
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



//-(id) init{
//    //    instanceOfMyClass = self;
//    if ((self = [super init])){
//        
//        CGSize size = [[CCDirector sharedDirector] winSize];
//        
//        // background
//        CCSprite *bg = [CCSprite spriteWithFile:@"bg.png"];
//        bg.position = ccp(size.width / 2, size.height / 2);
//        [self addChild:bg];
//        
//        
//        
//        
//        //Create first level green button
//        CCMenuItem *itemSprite1 = [CCMenuItemImage
//                                   itemWithNormalImage:@"button.png" selectedImage:@"button.png"
//                                   target:self selector:@selector(level1Tapped:)];
//        itemSprite1.position = ccp(133, size.height);
//        //CCMenu *starMenu = [CCMenu menuWithItems:itemSprite1, nil];
//        //[self addChild:starMenu];
//        
//        
//        
//        //Check whether level is locked, or released and change display accordingly.
//        if (!level1Locked){
//            Label1 = [CCMenuItemImage
//                      itemWithNormalImage:@"1.png" selectedImage:@"1.png"
//                      target:self selector:@selector(level1Tapped:)];
//            Label1.position = ccp(-110,15);
//            
//            //level1Label.anchorPoint = ccp(-110,15);
//            
//            
//            level1Items = [CCMenu menuWithItems:itemSprite1, Label1, nil];
//        }
//        else {
//            
//            lockSprite1 = [CCMenuItemImage
//                           itemWithNormalImage:@"lock.png" selectedImage:@"lock.png"
//                           target:self selector:@selector(level1Tapped:)];
//            lockSprite1.position = ccp(-110, 15);
//            
//            //[self addChild:lockSprite1];
//            level1Items = [CCMenu menuWithItems:itemSprite1,lockSprite1, nil];
//            
//        }
//        [self addChild:level1Items];
//        
//        
//        //  CCMenuItem *level1Items = [CCMenu menuWithItems:itemSprite1,lockSprite1, nil];
//        
//        //Create second level green button
//        CCMenuItem *itemSprite2 = [CCMenuItemImage
//                                   itemWithNormalImage:@"button.png" selectedImage:@"button.png"
//                                   target:self selector:@selector(level2Tapped:)];
//        //itemSprite2.anchorPoint = ccp(0.3f,0.5f);
//        itemSprite2.position = ccp(-40, 15);
//        //CCMenu *level2Menu = [CCMenu menuWithItems:itemSprite2, nil];
//        
//        
//        //[self addChild:level2Menu];
//        
//        
//        
//        //Check whether level is locked, or released and change display accordingly.
//        if (!level2Locked){
//            Label2 = [CCMenuItemImage
//                      itemWithNormalImage:@"2.png" selectedImage:@"2.png"
//                      target:self selector:@selector(level2Tapped:)];
//            Label2.position = ccp(-40,15);
//            
//            //level1Label.anchorPoint = ccp(-110,15);
//            
//            
//            level2Items = [CCMenu menuWithItems:itemSprite2, Label2, nil];
//        }
//        
//        else {
//            
//            lockSprite2 = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"lock.png"] selectedSprite:[CCSprite spriteWithFile:@"lock.png"] block:^(id sender){
//                infoLabel.string = @"(ItemSprite Tapped)";
//            }];
//            lockSprite2.position = ccp(-40, 15);
//            //[self addChild:lockSprite2];
//            level2Items = [CCMenu menuWithItems:itemSprite2,lockSprite2, nil];
//        }
//        [self addChild:level2Items];
//        
//        
//        //CCMenu *finalMenu = [CCMenu menuWithItems:level1Items, level2Items, nil];
//        //[finalMenu alignItemsHorizontally];
//        //[self setUpMenus];
//        
//        
//        
//        //Create third level green button
//        CCMenuItem *itemSprite3 = [CCMenuItemImage
//                                   itemWithNormalImage:@"button.png" selectedImage:@"button.png"
//                                   target:self selector:@selector(level3Tapped:)];
//        //itemSprite2.anchorPoint = ccp(0.3f,0.5f);
//        itemSprite3.position = ccp(30, 15);
//        //CCMenu *level2Menu = [CCMenu menuWithItems:itemSprite2, nil];
//        
//        
//        //[self addChild:level2Menu];
//        
//        
//        
//        //Check whether level is locked, or released and change display accordingly.
//        if (!level3Locked){
//            Label3 = [CCMenuItemImage
//                      itemWithNormalImage:@"3.png" selectedImage:@"3.png"
//                      target:self selector:@selector(level3Tapped:)];
//            Label3.position = ccp(30,15);
//            
//            //level1Label.anchorPoint = ccp(-110,15);
//            
//            
//            level3Items = [CCMenu menuWithItems:itemSprite3, Label3, nil];
//        }
//        
//        else {
//            
//            lockSprite3 = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"lock.png"] selectedSprite:[CCSprite spriteWithFile:@"lock.png"] block:^(id sender){
//                infoLabel.string = @"(ItemSprite Tapped)";
//            }];
//            lockSprite3.position = ccp(30, 15);
//            //[self addChild:lockSprite2];
//            level3Items = [CCMenu menuWithItems:itemSprite3,lockSprite3, nil];
//        }
//        [self addChild:level3Items];
//        //CCMenu *finalMenu = [CCMenu menuWithItems:level1Items, level2Items, nil];
//        //[finalMenu alignItemsHorizontally];
//        //[self setUpMenus];
//        
//        
//        //Create third level green button
//        CCMenuItem *itemSprite4 = [CCMenuItemImage
//                                   itemWithNormalImage:@"button.png" selectedImage:@"button.png"
//                                   target:self selector:@selector(level4Tapped:)];
//        //itemSprite2.anchorPoint = ccp(0.3f,0.5f);
//        itemSprite4.position = ccp(100, 15);
//        //CCMenu *level2Menu = [CCMenu menuWithItems:itemSprite2, nil];
//        
//        
//        //[self addChild:level2Menu];
//        
//        
//        
//        //Check whether level is locked, or released and change display accordingly.
//        if (level4Locked){
//            Label4 = [CCMenuItemImage
//                      itemWithNormalImage:@"4.png" selectedImage:@"4.png"
//                      target:self selector:@selector(level4Tapped:)];
//            Label4.position = ccp(100,15);
//            
//            //level1Label.anchorPoint = ccp(-110,15);
//            
//            
//            level4Items = [CCMenu menuWithItems:itemSprite4, Label4, nil];
//        }
//        
//        else {
//            
//            lockSprite4 = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"lock.png"] selectedSprite:[CCSprite spriteWithFile:@"lock.png"] block:^(id sender){
//                infoLabel.string = @"(ItemSprite Tapped)";
//            }];
//            lockSprite4.position = ccp(100, 15);
//            //[self addChild:lockSprite2];
//            level4Items = [CCMenu menuWithItems:itemSprite4,lockSprite4, nil];
//        }
//        [self addChild:level4Items];
//        //CCMenu *finalMenu = [CCMenu menuWithItems:level1Items, level2Items, nil];
//        //[finalMenu alignItemsHorizontally];
//        //[self setUpMenus];
//        
//        
//        
//        [self scheduleUpdate];
//        
//    }
//    
//    return self;
//}
//
//
//- (void)level1Tapped:(id)sender {
//    printf("Button 1 tapped!!!!!!\n");
//}
//
//- (void)level2Tapped:(id)sender {
//    printf("Button 2 tapped!!!!!!\n");
//}
//
//- (void)level3Tapped:(id)sender {
//    printf("Button 3 tapped!!!!!!\n");
//}
//
//
//- (void)level4Tapped:(id)sender {
//    printf("Button 4 tapped!!!!!!\n");
//}

@end
