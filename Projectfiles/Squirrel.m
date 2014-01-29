//
//  Squirrel.m
//  TheRealFluffy
//
//  Created by Clare on 1/25/14.
//
//

#import "Squirrel.h"

@implementation Squirrel
-(id) initWithSquirrel: (CCSprite *) squirrel
{
//    NSString *spriteName = [squirrel stringByAppendingString:@".png"];
//    if ((self = [super initWithFile:spriteName])){
//        
    
    if ((self = [super init]))
    {
    
        squirrel = [CCSprite spriteWithSpriteFrameName:@"squirrelUp1.png"];
        squirrel.anchorPoint = CGPointZero;
        squirrel.position = CGPointMake(0, 0);
    }
        
    return self;
}

+(void) squirrelUp
{
    //NSLog(@"it's GOING UP!");
    
}

+(void) squirrelDown
{
    //NSLog(@"it's GOING DOWN!");
}

@end
