//
//  Squirrel.h
//  TheRealFluffy
//
//  Created by Clare on 1/25/14.
//
//

#import "CCSprite.h"

@interface Squirrel : CCSprite
{

    //Squirrels
    
    //run up
    CCAction *runUp;
    NSMutableArray *runUpFrames;
    
    //run down


}

-(id) initWithSquirrel: (NSString *) squirrel;
//+(void) squirrelUp;
//+(void) squirrelDown;

@end
