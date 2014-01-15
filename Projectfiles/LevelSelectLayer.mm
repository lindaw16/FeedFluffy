//
//  LevelSelectLayer.m
//  TheRealFluffy
//
//  Created by Linda Wang on 1/14/14.
//
//

#import "LevelSelectLayer.h"
#import "PhysicsLayer.h"
#import "OopsDNE.h"

CCMenuItemImage * left;
CCMenuItemImage * right;
float priorX = 1000;
float priorY = 1000;

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
    

    CCMenuItemImage * tutorials = [CCMenuItemImage itemWithNormalImage:@"tutorials.png" selectedImage: @"tutorials.png" target:self selector:@selector(goToLevel1:)];

    CCMenuItemImage * level1 = [CCMenuItemImage itemWithNormalImage:@"level1.png" selectedImage: @"level1.png" target:self selector:@selector(goToLevel1:)];
    
    
    CCMenuItemImage * level2 = [CCMenuItemImage itemWithNormalImage:@"level2.png" selectedImage: @"level2.png" target:self selector:@selector(goToLevel2:)];
    
    
    CCMenuItemImage * easy = [CCMenuItemImage itemWithNormalImage:@"Easy.png" selectedImage: @"Easy.png" target:self selector:@selector(goToLevel4:)];
    
	// Create a menu and add your menu items to it
	CCMenu * myMenu = [CCMenu menuWithItems: left, right, tutorials, level1, level2, easy, nil];
    
	// Arrange the menu items vertically
	//[myMenu alignItemsVertically];
    //menuItem1.position = ccp(240,95);
    left.position = ccp(40, 30);
    right.position = ccp(440, 30);
    tutorials.position = ccp(170,170);
    level1.position = ccp(130, 150);
    level2.position = ccp(200, 150);
    easy.position = ccp(480, 170);

    
    
    myMenu.position = ccp(0,0);
    
	// add the menu to your scene
	[self addChild:myMenu];
}


-(id) init{
    //    instanceOfMyClass = self;
    if ((self = [super init])){
        //[self scheduleUpdate];
        
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
    self.position = ccp(self.position.x - 100, self.position.y);
    left.position = ccp(left.position.x + 100, left.position.y);
    right.position = ccp(right.position.x + 100, right.position.y);
}



- (void) goToLevel1: (CCMenuItem  *) menuItem
{
	//NSLog(@"The first menu was called");
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[PhysicsLayer alloc] init]];
}

-(void) goToLevel2: (CCMenuItem *) menuItem
{
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[OopsDNE alloc] init]];
}

-(void) goToLevel4: (CCMenuItem *) menuItem
{
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[OopsDNE alloc] init]];
}




/*
-(void) update:(ccTime)delta
{
    KKInput * input = [KKInput sharedInput];
    CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];

    float x1 = pos.x;
    float y1 = pos.y;
    
//    NSLog(@"HIIIIIIIIIIIIIIIIIII %f ", x1, @"%f", y1);
    
    if (input.anyTouchBeganThisFrame)
    {
        //derp
    }
    
    else if  (input.anyTouchEndedThisFrame)
    {
//        priorX = 1000;
//        priorY = 1000;
//        self.position = ccp(self.position.x - 1, self.position.y);
    }
    
    else if (input.touchesAvailable)
    {
//        float x2 = x1;
//        float y2 = y1;
//         NSLog(@"%f ", x2, @"%f", y2);
//        
//        if (priorX != 1000 && x2 < x1)
//        {
//            self.position = ccp(self.position.x - 1, self.position.y);
//        }
//        else if (priorX != 1000 && x2 > x1)
//        {
//            self.position = ccp(self.position.x + 1, self.position.y);
//        }
//        else
//        {
//            //um do nothing?
//        }
//        priorX = x2;
//        priorY = y2;
//        NSLog(@"new %f ", x2, @"%f", y2);
//    }
    
//    if (priorX != 1000 && priorY != 1000)
//    {
//        self.position = ccp(self.position.x - 1, self.position.y);
        
        if (y1 > 150)
        {
            self.position = ccp(self.position.x - 1, self.position.y);
        }
        else
        {
            self.position = ccp(self.position.x + 1, self.position.y);
        }
    }
}
*/


@end
