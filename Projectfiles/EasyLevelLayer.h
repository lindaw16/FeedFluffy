//
//  EasyLevelLayer.h
//  TheRealFluffy
//
//  Created by Srinidhi Viswanathan on 1/18/14.
//
//

#import <Foundation/Foundation.h>

@interface EasyLevelLayer : CCLayer
{

CCLabelTTF *infoLabel;
CCLabelTTF *level1Label;
CCLabelTTF *level2Label;
    CCMenuItem *lockSprite1;
    CCMenuItem *lockSprite2;
    CCMenuItem *level1Items;
    CCMenuItem *level2Items;
    
    bool level1Locked;
    bool level2Locked;
}
@end
