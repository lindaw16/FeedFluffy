//
//  derpymathlayer.m
//  TheRealFluffy
//
//  Created by Linda Wang on 1/22/14.
//
//

#import "derpymathlayer.h"
#import "PhysicsLayer.h"

int numLevels = 16;
int numCol = 4;
//int numRow;
const float PTM = 32.0f;

int leftMargin = 60;
int topMargin = 250;
CCSprite *level;

//CGSize winSize;


@implementation derpymathlayer
{}


-(void) setUpMenus
{
    
    CCMenu *myLevels = [CCMenu menuWithItems:nil];
    myLevels.position = ccp(0, 0);
    
    for (int i = 0; i < numLevels; i++)
    {
//        if (! [NSString stringWithFormat:@"level%dLocked", i])

        level = [CCMenuItemImage itemWithNormalImage:@"apple_level.png" selectedImage:@"apple_level.png" target:self selector: @selector(goToLevel:)];
        
//        [NSString stringWithFormat:@"level%d", i].tag = i;
//        [NSString stringWithFormat:@"level%d", i].position = (60 + 60*i, 150);
//        [myLevels addChild: [NSString stringWithFormat:@"level%d", i]];
        
        level.tag = i + 1;
        int x = leftMargin + 80 * (i % numCol);
        int y =  topMargin - (i/numCol)*60;
        level.position = ccp(x, y);
        //level.position = ccp(leftMargin + 80 * (i % numCol), topMargin - (i/ numCol) * 60);
        [myLevels addChild: level];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat: @"%d", level.tag]
                                               fontName:@"Verdana"
                                               fontSize:26];
        label.position = ccp(x,y-3);
        [self addChild: label z:3];
        

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

@end