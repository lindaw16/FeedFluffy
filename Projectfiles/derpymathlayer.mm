//
//  derpymathlayer.m
//  TheRealFluffy
//
//  Created by Linda Wang on 1/22/14.
//
//

#import "derpymathlayer.h"
#import "PhysicsLayer.h"

int numLevels = 5;
int numCol = 4;
int numRow;
const float PTM = 32.0f;

CCSprite *level;

//CGSize winSize;


@implementation derpymathlayer
{}


-(void) setUpMenus
{
    
    CCMenu *myLevels = [CCMenu menuWithItems:nil];
    myLevels.position = ccp(0, 0);
    
    for (int i = 1; i <= numLevels; i++)
    {
//        if (! [NSString stringWithFormat:@"level%dLocked", i])

        level = [CCMenuItemImage itemWithNormalImage:@"apple.png" selectedImage:@"apple.png" target:self selector: @selector(goToLevel:)];
        
//        [NSString stringWithFormat:@"level%d", i].tag = i;
//        [NSString stringWithFormat:@"level%d", i].position = (60 + 60*i, 150);
//        [myLevels addChild: [NSString stringWithFormat:@"level%d", i]];
        
        level.tag = i;
        level.position = ccp(60 + 60 * i, 150);
        [myLevels addChild: level];
        

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
        numRow = numLevels / numCol + 1;
        
        
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