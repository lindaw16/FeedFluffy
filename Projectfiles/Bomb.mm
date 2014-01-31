//
//  Bomb.m
//  TheRealFluffy
//
//  Created by Srinidhi Viswanathan on 1/23/14.
//
//
#import "Bomb.h"


@implementation Bomb






-(id) initWithBomb: (NSString *) bomb
{
    NSString *spriteName = [bomb stringByAppendingString:@".png"];
    if ((self = [super initWithFile:spriteName])){
        
    }
    return self;
}


@end
