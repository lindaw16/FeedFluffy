/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim.
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "cocos2d.h"
#import "Box2D.h"
//#import "Box2DDebugLayer.h"
#import "GLES-Render.h"

#import "ContactListener.h"

enum
{
	kTagBatchNode,
};

@interface PhysicsLayer : CCLayerColor
{
    
    
    
    b2Body *_paddleBody;
    b2Fixture *_bottomFixture;
    b2Body *_groundBody;
    b2Fixture *_paddleFixture;
	b2World* world;
    b2Body *_body;
    CCSprite *ball;
    //to help with cannon to rotate smoothly 
    CCSprite *_nextProjectile; //I'm replacing nextProjectile with "bullet"
//    CCSprite *_bullet;
    
   
	//ContactListener* contactListener;
	GLESDebugDraw* debugDraw;
    b2MouseJoint *_mouseJoint;
    CCSprite *_player;    //Also replacing _player with "cannon"
//    CCSprite *_cannon;
    
    
    //To keep track of selected sprite
    CCSprite *selSprite;
    NSMutableArray *movableSprites;
    CCSprite *meep;
    bool _MoveableSpriteTouch;
    
}


//TODO: fix this list
//Currently these are all public.. decide which ones we want public, private
//Also maybe change to a more sensical order
//+(id) scene;
+(id) sceneWithLevel:(int)level;
-(void) detectCollisions;
-(void)tick:(ccTime)dt;

-(void)launchBullet:(CGPoint)location;


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) dealloc;
-(void) enableBox2dDebugDrawing;
-(CCSprite*) addRandomSpriteAt:(CGPoint)pos;
-(void) bodyCreateFixture:(b2Body*)body;
-(void) addSomeJoinedBodies:(CGPoint)pos;
-(void) addNewSpriteAt:(CGPoint)pos;
-(void) update:(ccTime)delta;
-(b2Vec2) toMeters:(CGPoint)point;
-(CGPoint) toPixels:(b2Vec2)vec;
//-(void) draw;


@end
