//
//  HUDLayer.h
//  TheRealFluffy
//
//  Created by Srinidhi Viswanathan on 1/23/14.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface HUDLayer : CCLayer
{
    CCLabelTTF *_levelLabel;
}


-(void) incrementLevel:(NSString *) string;
@end
