//
//  derpymathlayer.m
//  TheRealFluffy
//
//  Created by Linda Wang on 1/22/14.
//
//

#import "derpymathlayer.h"

int numLevels = 5;
int numCol = 4;
int numRow;
CGSize winSize;


@implementation derpymathlayer
{}


-(void) setUpMenus
{
    
    for (int i = 1; i <= numLevels; i++)
    {
//        if (! [NSString stringWithFormat:@"level%dLocked", i])
//        {
        CCMenuItem* level1 = [CCMenuItemImage:@"apple.png" selectedImage:@"apple.png" target:self selector: @selector(goToLevel:)];
        [NSString stringWithFormat:@"Label%d", i]
//        }
    }
    
    
    
}




-(id) init
{
    if ((self = [super init] ))
    {
        numRow = numLevels / numCol + 1;
        
        
        CCSprite *bg = [CCSprite spriteWithFile:@"bg.png"];
        bg.position = ccp(winSize.width / 2, winSize.height / 2);
        [self addChild:bg];
    
    }

    return self;

}

@end