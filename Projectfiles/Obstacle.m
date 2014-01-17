//
//  Obstacle.m
//  TheRealFluffy
//
//  Created by Clare on 1/15/14.
//
//

#import "Obstacle.h"

@implementation Obstacle

-(id) initWithObstacle: (NSString *) obstacle
{
    NSString *spriteName = [obstacle stringByAppendingString:@".png"];
    if ((self = [super initWithFile:spriteName])){

    }
    return self;
}

@end
