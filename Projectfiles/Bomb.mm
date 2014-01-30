//
//  Bomb.m
//  CutCutCut
//
//  Created by Allen Benson G Tan on 5/18/12.
//  Copyright 2012 WhiteWidget Inc. All rights reserved.
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
