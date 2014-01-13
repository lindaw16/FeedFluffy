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
	//ContactListener* contactListener;
	GLESDebugDraw* debugDraw;
    b2MouseJoint *_mouseJoint;
}

+(id) scene;
//-(void) draw;
-(void) detectCollisions;

@end
