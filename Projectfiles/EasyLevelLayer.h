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
    CCLabelTTF *level3Label;
    CCLabelTTF *level4Label;
    
    
    CCMenuItem *lockSprite1;
    CCMenuItem *Label1;
    CCMenuItem *Label2;
    CCMenuItem *Label3;
    CCMenuItem *Label4;
    CCMenuItem *lockSprite2;
    
    CCMenuItem *lockSprite3;
    CCMenuItem *lockSprite4;
    CCMenuItem *level1Items;
    CCMenuItem *level2Items;
    CCMenuItem *level3Items;
    CCMenuItem *level4Items;
    
    bool level1Locked;
    bool level2Locked;
    bool level3Locked;
    bool level4Locked;
}
@end
