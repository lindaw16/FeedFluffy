//
//  HUDLayer.m
//  TheRealFluffy
//
//  Created by Srinidhi Viswanathan on 1/23/14.
//
//

#import "HUDLayer.h"
#import "PhysicsLayer.h"

@implementation HUDLayer
int levelCounter = 0;
-(id)init{

if ((self = [super init]))
{
    _levelLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Level: %d", levelCounter] fontName:@"Marker Felt" fontSize:24.0];
    CGSize size = [[CCDirector sharedDirector] winSize];
    _levelLabel.position = ccp(0,0);
    [self addChild: _levelLabel z:10];
}
    return self;
}


-(void) incrementLevel
{
    levelCounter++;
    _levelLabel.string = [NSString stringWithFormat:@"Level: %d", levelCounter];
}
@end
