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
int levelCount = 0;

-(id)init{

if ((self = [super init]))
{
//    _levelLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Level: %d", levelCount
//                                               ] fontName:@"Marker Felt" fontSize:24.0];
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    NSLog(@"Level Label in HUD\n");
    
//    //_levelLabel = [CCLabelTTF labelWithString:@"level" fontName:@"Marker Felt" fontSize:24.0];
//    _levelLabel.position = ccp(size.width/2, size.height/2);
//[self addChild: _levelLabel z:10];
    
}
    return self;
}

-(void) incrementLevel:(NSString *)string
{
    NSLog(@"Increment HUD level\n");
    //levelCounter++;
//    _levelLabel.string = [NSString stringWithFormat:@"Level: %d", levelCount];
    _levelLabel.string = string;
}

@end
