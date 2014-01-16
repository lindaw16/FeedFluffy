//
//  Fruit.m
//  TheRealFluffy
//
//  Created by Clare on 1/15/14.
//
//

#import "Fruit.h"

@implementation Fruit
@synthesize fruitName;

-(id) initWithFruit: (NSString *) fruit
{
    NSString *spriteName = [fruit stringByAppendingString:@".png"];
    if ((self = [super initWithFile:spriteName])){
        fruitName = fruit;
    }
    return self;
}

@end
