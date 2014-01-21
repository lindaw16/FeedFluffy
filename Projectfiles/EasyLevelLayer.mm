//
//  EasyLevelLayer.m
//  TheRealFluffy
//
//  Created by Srinidhi Viswanathan on 1/18/14.
//
//

#import "EasyLevelLayer.h"
#import "StartMenuLayer.h"
#import "PhysicsLayer.h"
#import "LevelSelectLayer.h"



@implementation EasyLevelLayer

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	StartMenuLayer *layer = [StartMenuLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

-(id) init{
    //    instanceOfMyClass = self;
    if ((self = [super init])){
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // background
        CCSprite *bg = [CCSprite spriteWithFile:@"bg.png"];
        bg.position = ccp(size.width / 2, size.height / 2);
        [self addChild:bg];
        
        
        
        
        //Create first level green button
        CCMenuItem *itemSprite1 = [CCMenuItemImage
                                   itemFromNormalImage:@"button.png" selectedImage:@"button.png"
                                   target:self selector:@selector(level1Tapped:)];
        itemSprite1.position = ccp(-110, 15);
        //CCMenu *starMenu = [CCMenu menuWithItems:itemSprite1, nil];
        //[self addChild:starMenu];
        
        
        
        //Check whether level is locked, or released and change display accordingly.
        if (!level1Locked){
            Label1 = [CCMenuItemImage
                           itemFromNormalImage:@"1.png" selectedImage:@"1.png"
                           target:self selector:@selector(level1Tapped:)];
            Label1.position = ccp(-110,15);
            
            //level1Label.anchorPoint = ccp(-110,15);

            
            level1Items = [CCMenu menuWithItems:itemSprite1, Label1, nil];
        }
        else {
            
            lockSprite1 = [CCMenuItemImage
                           itemFromNormalImage:@"lock.png" selectedImage:@"lock.png"
                           target:self selector:@selector(level1Tapped:)];
            lockSprite1.position = ccp(-110, 15);
            
            //[self addChild:lockSprite1];
            level1Items = [CCMenu menuWithItems:itemSprite1,lockSprite1, nil];
            
        }
        [self addChild:level1Items];
        
        
        //  CCMenuItem *level1Items = [CCMenu menuWithItems:itemSprite1,lockSprite1, nil];
        
        //Create second level green button
        CCMenuItem *itemSprite2 = [CCMenuItemImage
                                   itemFromNormalImage:@"button.png" selectedImage:@"button.png"
                                   target:self selector:@selector(level2Tapped:)];
        //itemSprite2.anchorPoint = ccp(0.3f,0.5f);
        itemSprite2.position = ccp(-40, 15);
        //CCMenu *level2Menu = [CCMenu menuWithItems:itemSprite2, nil];
        
        
        //[self addChild:level2Menu];
        
        
        
        //Check whether level is locked, or released and change display accordingly.
        if (level2Locked){
            level2Label = [CCLabelTTF labelWithString:@"1" fontName:@"Helvetica" fontSize:24];
            level2Label.position = ccp(0.1,0.1);
            [self addChild:level2Label];
            level2Items = [CCMenu menuWithItems:itemSprite2,nil];
        }
        else {
            
            lockSprite2 = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"lock.png"] selectedSprite:[CCSprite spriteWithFile:@"lock.png"] block:^(id sender){
                infoLabel.string = @"(ItemSprite Tapped)";
            }];
            lockSprite2.position = ccp(-40, 15);
            //[self addChild:lockSprite2];
            level2Items = [CCMenu menuWithItems:itemSprite2,lockSprite2, nil];
        }
        [self addChild:level2Items];
        //CCMenu *finalMenu = [CCMenu menuWithItems:level1Items, level2Items, nil];
        //[finalMenu alignItemsHorizontally];
        //[self setUpMenus];

        
        
        //Create third level green button
        CCMenuItem *itemSprite3 = [CCMenuItemImage
                                   itemFromNormalImage:@"button.png" selectedImage:@"button.png"
                                   target:self selector:@selector(level3Tapped:)];
        //itemSprite2.anchorPoint = ccp(0.3f,0.5f);
        itemSprite3.position = ccp(30, 15);
        //CCMenu *level2Menu = [CCMenu menuWithItems:itemSprite2, nil];
        
        
        //[self addChild:level2Menu];
        
        
        
        //Check whether level is locked, or released and change display accordingly.
        if (level3Locked){
            level3Label = [CCLabelTTF labelWithString:@"1" fontName:@"Helvetica" fontSize:24];
            level3Label.position = ccp(0.1,0.1);
            [self addChild:level3Label];
            level3Items = [CCMenu menuWithItems:itemSprite3,nil];
        }
        else {
            
            lockSprite3 = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"lock.png"] selectedSprite:[CCSprite spriteWithFile:@"lock.png"] block:^(id sender){
                infoLabel.string = @"(ItemSprite Tapped)";
            }];
            lockSprite3.position = ccp(30, 15);
            //[self addChild:lockSprite2];
            level3Items = [CCMenu menuWithItems:itemSprite3,lockSprite3, nil];
        }
        [self addChild:level3Items];
        //CCMenu *finalMenu = [CCMenu menuWithItems:level1Items, level2Items, nil];
        //[finalMenu alignItemsHorizontally];
        //[self setUpMenus];

        
        //Create third level green button
        CCMenuItem *itemSprite4 = [CCMenuItemImage
                                   itemFromNormalImage:@"button.png" selectedImage:@"button.png"
                                   target:self selector:@selector(level4Tapped:)];
        //itemSprite2.anchorPoint = ccp(0.3f,0.5f);
        itemSprite4.position = ccp(100, 15);
        //CCMenu *level2Menu = [CCMenu menuWithItems:itemSprite2, nil];
        
        
        //[self addChild:level2Menu];
        
        
        
        //Check whether level is locked, or released and change display accordingly.
        if (level4Locked){
            level4Label = [CCLabelTTF labelWithString:@"1" fontName:@"Helvetica" fontSize:24];
            level4Label.position = ccp(0.1,0.1);
            [self addChild:level4Label];
            level4Items = [CCMenu menuWithItems:itemSprite4,nil];
        }
        else {
            
            lockSprite4 = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"lock.png"] selectedSprite:[CCSprite spriteWithFile:@"lock.png"] block:^(id sender){
                infoLabel.string = @"(ItemSprite Tapped)";
            }];
            lockSprite4.position = ccp(100, 15);
            //[self addChild:lockSprite2];
            level4Items = [CCMenu menuWithItems:itemSprite4,lockSprite4, nil];
        }
        [self addChild:level4Items];
        //CCMenu *finalMenu = [CCMenu menuWithItems:level1Items, level2Items, nil];
        //[finalMenu alignItemsHorizontally];
        //[self setUpMenus];
        
        
        
        
        
        [self scheduleUpdate];
        
    }

    return self;
}


- (void)level1Tapped:(id)sender {
    printf("Button 1 tapped!!!!!!\n");
}

- (void)level2Tapped:(id)sender {
    printf("Button 2 tapped!!!!!!\n");
}

- (void)level3Tapped:(id)sender {
    printf("Button 3 tapped!!!!!!\n");
}


- (void)level4Tapped:(id)sender {
    printf("Button 4 tapped!!!!!!\n");
}

@end
