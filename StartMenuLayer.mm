//
//  StartMenuLayer.m
//  TheRealFluffy
//
//  Created by Linda Wang on 1/12/14.
//
//

#import "StartMenuLayer.h"
#import "GameLayer.h"

@implementation StartMenuLayer

-(id) init{
    //    instanceOfMyClass = self;
    if ((self = [super init])){
        //[self scheduleUpdate];
        
    
        CCSprite *sprite = [CCSprite spriteWithFile:@"MITplaceholder.png"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:0];
        
        
        sprite = [CCSprite spriteWithFile:@"playbutton.png"];
        sprite.anchorPoint = CGPointZero;
        sprite.position = CGPointMake(80.0f, 0.0f);
        [self addChild:sprite z:0 tag:1];
        
        
        //[self addMenuItems];
    
        
    }
    return self;
}



@end
