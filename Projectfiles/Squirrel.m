//
//  Squirrel.m
//  TheRealFluffy
//
//  Created by Clare on 1/25/14.
//
//

#import "Squirrel.h"

@implementation Squirrel
-(id) initWithSquirrel: (NSString *) squirrel
{
    NSString *spriteName = [squirrel stringByAppendingString:@".png"];
    if ((self = [super initWithFile:spriteName])){
        
    }
    return self;
}

@end
