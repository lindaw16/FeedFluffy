//
//  LevelSelectLayer.h
//  TheRealFluffy
//
//  Created by Linda Wang on 1/14/14.
//
//

#import "CCLayer.h"

@interface LevelSelectLayer : CCLayer
{
    CCSprite * background;
    CCSprite * selSprite;
    NSMutableArray * movableSprites;
    
}

-(void) update:(ccTime)delta;
@end
