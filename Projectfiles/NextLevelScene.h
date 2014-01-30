//
//  NextLevelScene.h
//  TheRealFluffy
//
//  Created by Clare on 1/22/14.
//
//

#import "CCLayer.h"

@interface NextLevelScene : CCLayer
{
    CCAction *wag;
    NSMutableArray *waggingFrames;
}
+(id) sceneWithLevel: (int) level;
-(id) initWithLevel: (int) level;
-(void) draw;

@end
