//
//  GameLayer.m
//  TheRealFluffy
//
//  Created by Linda Wang on 1/12/14.
//
//

#import "GameLayer.h"

@implementation GameLayer

-(id) init{
    //    instanceOfMyClass = self;
    if ((self = [super init])){
        CCSprite *sprite = [CCSprite spriteWithFile:@"eevee.png"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        [self scheduleUpdate];
    }
    return self;
}

/*
 -(void) draw
 {
 ccColor4F buttonColor = ccc4f(0, 0.5, 0.5, 0.5);
 
 int x = 390;
 int y = 70;
 ccDrawSolidRect( ccp(x, y), ccp(x + 40, y + 40), buttonColor);
 }
 
*/

@end
