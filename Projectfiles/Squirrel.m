//
//  Squirrel.m
//  TheRealFluffy
//
//  Created by Clare on 1/25/14.
//
//
//
//#import "Squirrel.h"
//
//@implementation Squirrel
//-(id) initWithSquirrel: (CCSprite *) squirrel
//{
//    NSString *spriteName = [squirrel stringByAppendingString:@".png"];
//    if ((self = [super initWithFile:spriteName])){
//        
//    
////    if ((self = [super init]))
////    {
////    
////        squirrel = [CCSprite spriteWithSpriteFrameName:@"squirrelUp1.png"];
////        squirrel.anchorPoint = CGPointZero;
////        squirrel.position = CGPointMake(0, 0);
////    }
//        
//    return self;
//}
//
//+(void) squirrelUp
//{
//    //NSLog(@"it's GOING UP!");
//    
//}
//
//+(void) squirrelDown
//{
//    //NSLog(@"it's GOING DOWN!");
//}
//
//@end


//
//  Squirrel.m
//  TheRealFluffy
//
//  Created by Clare on 1/25/14.
///Users/Linda/Kobold2D/Kobold2D-2.1.0/TheRealFluffy/Projectfiles/Squirrel.m
//

#import "Squirrel.h"

@implementation Squirrel
-(id) initWithSquirrel: (NSString *) squirrel : (CGPoint) location
{
    //Add a comment to this line
        //NSString *spriteName = [squirrel stringByAppendingString:@".png"];
        if ((self = [super init])){
            
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"squirrelUp.plist"];
            CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"squirrelUp.png"];
            
            [self addChild: spriteSheet];
            
            runUpFrames = [NSMutableArray array];
            
            for(int i = 1; i <= 2; ++i)
            {
                [runUpFrames addObject:
                 [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"SquirrelUp%d.png", i]]];
            }
            
            
            
            CCSprite * sprite = [CCSprite spriteWithSpriteFrameName:@"SquirrelUp1.png"];

            sprite.anchorPoint = CGPointZero;
            //sprite.position = ccp(100, 100);
            sprite.position = location;
            
            //Create an animation from the set of frames you created earlier
            
            CCAnimation *running = [CCAnimation animationWithSpriteFrames: runUpFrames delay:0.5f];
            
            
            runUp = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:running]];
            running.restoreOriginalFrame = NO;
            
            //tell the bear to run the taunting action
            [sprite runAction:runUp];
            
            [self addChild:sprite];
            
            
            
        
            }
        return self;
    }

@end