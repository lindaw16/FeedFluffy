//
//  LevelSelectLayer.m
//  TheRealFluffy
//
//  Created by Linda Wang on 1/14/14.
//


#import "LevelSelectLayer.h"
#import "PhysicsLayer.h"
#import "OopsDNE.h"
#import "EasyLevelLayer.h"

CCMenuItemImage * left;
CCMenuItemImage * right;
float priorX = 1000;
float priorY = 1000;
//CGSize winSize = [CCDirector sharedDirector].winSize;



@implementation LevelSelectLayer

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	LevelSelectLayer *layer = [LevelSelectLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

// set up the Menus
-(void) setUpMenus
{
    
	// Create some menu items
    //	CCMenuItemImage * menuItem1 = [CCMenuItemImage itemWithNormalImage:@"playbutton.png"
    //                                                         selectedImage: @"playbutton.png"
    //                                                                target:self
    //                                                              selector:@selector(goToLevel1:)];
    
    left = [CCMenuItemImage itemWithNormalImage:@"goLeft.png" selectedImage: @"goLeft.png" target:self selector:@selector(goLeft:)];
    
    right = [CCMenuItemImage itemWithNormalImage:@"goRight.png" selectedImage: @"goRight.png" target:self selector:@selector(goRight:)];
    

    CCMenuItemImage * easy = [CCMenuItemImage itemWithNormalImage:@"easyCage.png" selectedImage: @"easyCage.png" target:self selector:@selector(goToEasyLevelLayer:)];
    
    CCMenuItemImage * medium = [CCMenuItemImage itemWithNormalImage:@"easyCage.png" selectedImage: @"easyCage.png" target:self selector:@selector(goToEasyLevelLayer:)];
    
    CCMenuItemImage * hard = [CCMenuItemImage itemWithNormalImage: @"easyCage.png" selectedImage:@"easyCage.png" target:self selector:@selector(goToEasyLevelLayer:)];
    
//    // TEST
//    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
//    NSString *levelString = @"level1";
    
    CCMenu * myLevels = [CCMenu menuWithItems: left, right, easy, medium, hard, nil];
  
//	// Arrange the menu items vertically
	//[myMenu alignItemsVertically];
    //menuItem1.position = ccp(240,95);
    left.position = ccp(40, 30);
    right.position = ccp(528, 30);
    
    
    //NSLog(@"%f by %f", winSize.height, winSize.width);
    
    
//    //tutorials.position = ccp(170,170);
//    level1.position = ccp(120, 150);
//    level2.position = ccp(180, 150);
//    level3.position = ccp(240, 150);
//    level4.position = ccp(300, 150);
//    level5.position = ccp(360, 150);
    easy.position = ccp(180, 180);
    medium.position = ccp(460, 180);
    hard.position = ccp(740, 180);

//    
    //myBG.position = ccp(0, 0);
    myLevels.position = CGPointZero;
    
//	// add the menu to your scene
    //[self addChild: myBG z:0];
	[self addChild:myLevels z:1];
}


-(id) init{
 
    //    instanceOfMyClass = self;
    if ((self = [super init])){
        //[self scheduleUpdate];
        
        //CGSize size = [[CCDirector sharedDirector] winSize];
        
        
        //CCSprite *sprite = [CCSprite spriteWithFile:@"eevee.png"];
        CCSprite *sprite = [CCSprite spriteWithFile:@"levelSelectBackground.png"];
        sprite.anchorPoint = CGPointZero;

        
        [self addChild:sprite z:-1];
        
        [self setUpMenus];
        [self scheduleUpdate];
        
    }
    return self;
}



-(void) goLeft: (CCMenuItem *) menuItem
{
    if (left.position.x >= 45)
    {
        self.position = ccp(self.position.x + 100, self.position.y);
        left.position = ccp(left.position.x - 100, left.position.y);
        right.position = ccp(right.position.x - 100, right.position.y);
    }
}

-(void) goRight: (CCMenuItem *) menuItem
{
//TODO check to not go offscreen
    if (right.position.x <= 800)
    {
        self.position = ccp(self.position.x - 100, self.position.y);
        left.position = ccp(left.position.x + 100, left.position.y);
        right.position = ccp(right.position.x + 100, right.position.y);
    }
}



- (void) goToEasyLevelLayer: (CCMenuItem  *) menuItem
{
	//NSLog(@"The first menu was called");
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[EasyLevelLayer alloc] init]];
}

-(void) onExit {
    //unschedule selectors to get dealloc to fire off
    [self unscheduleAllSelectors];
    //remove all textures to free up additional memory. Textures get retained even if the sprite gets released and it doesn't show as a leak. This was my big memory saver
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [super onExit];
}

-(void) dealloc
{
#ifndef KK_ARC_ENABLED
	[super dealloc];
#endif
}


@end
