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
        
        
        infoLabel = [CCLabelTTF labelWithString:@"(Tap an Item)" fontName:@"Helvetica" fontSize:24];
        infoLabel.position = ccp(size.width/2, 30);
        [self addChild:infoLabel];
        
        //Create first level green button
        CCMenuItem *itemSprite1 = [CCMenuItemImage
                                    itemFromNormalImage:@"button.png" selectedImage:@"button.png"
                                    target:self selector:@selector(level1Tapped:)];
        itemSprite1.position = ccp(0.0, 0.0);
        CCMenu *starMenu = [CCMenu menuWithItems:itemSprite1, nil];
        [self addChild:starMenu];
        
        
        //Check whether level is locked, or released and change display accordingly.
        if (level1Locked){
            level1Label = [CCLabelTTF labelWithString:@"1" fontName:@"Helvetica" fontSize:24];
            level1Label.position = ccp(size.width/2, size.height/2);
            [self addChild:level1Label];
            level1Items = [CCMenu menuWithItems:itemSprite1,level1Label, nil];
        }
        else {
            
            lockSprite1 = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"lock.png"] selectedSprite:[CCSprite spriteWithFile:@"lock.png"] block:^(id sender){
                infoLabel.string = @"(ItemSprite Tapped)";
            }];
            lockSprite1.position = ccp(size.width/2, size.height/2);
            [self addChild:lockSprite1];
            //level1Items = [CCMenu menuWithItems:itemSprite1,lockSprite1, nil];
            
        }
        //[self addChild:level1Items];
      //  CCMenuItem *level1Items = [CCMenu menuWithItems:itemSprite1,lockSprite1, nil];

        
        //Create second level green button
        CCMenuItem *itemSprite2 = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"button.png"] selectedSprite:[CCSprite spriteWithFile:@"button.png"] block:^(id sender){
            infoLabel.string = @"(Level 2 Tapped)";
        }];
        
                [self addChild:itemSprite2];
        //Check whether level is locked, or released and change display accordingly.
        if (level2Locked){
            level2Label = [CCLabelTTF labelWithString:@"1" fontName:@"Helvetica" fontSize:24];
            level2Label.position = ccp(0.7,0.7);
            [self addChild:level2Label];
            //level2Items = [CCMenu menuWithItems:itemSprite2,level1Label, nil];
        }
        else {
            
            lockSprite2 = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"lock.png"] selectedSprite:[CCSprite spriteWithFile:@"lock.png"] block:^(id sender){
                infoLabel.string = @"(ItemSprite Tapped)";
            }];
            lockSprite2.position = ccp(0.7, 0.7);
            [self addChild:lockSprite2];
            //level2Items = [CCMenu menuWithItems:itemSprite2,level2Label, nil];
        }
//                [self addChild:level2Items];
        //CCMenu *finalMenu = [CCMenu menuWithItems:level1Items, level2Items, nil];
        //[finalMenu alignItemsHorizontally];
        //[self setUpMenus];
        [self scheduleUpdate];
        
    }
    printf("here before");
    return self;
}


- (void)level1Tapped:(id)sender {
    printf("Button tapped!!!!!!\n");
}
@end
