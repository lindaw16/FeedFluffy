//
//  Bomb.m
//  TheRealFluffy
//
//  Created by Srinidhi Viswanathan on 1/23/14.
//
//
#import "Bomb.h"


@implementation Bomb






-(id) initWithBomb: (NSString *) mushroom
{
    NSString *spriteName = [mushroom stringByAppendingString:@".png"];
    if ((self = [super initWithFile:spriteName])){
        
    }
    return self;
}


@end
