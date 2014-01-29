//
//  Bomb.m
//  CutCutCut
//
//  Created by Allen Benson G Tan on 5/18/12.
//  Copyright 2012 WhiteWidget Inc. All rights reserved.
//

#import "Bomb.h"


@implementation Bomb




-(id)initWithWorld:(b2World *)world
{
    NSString *file = @"bomb.png";
    
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
//    CCParticleSystemQuad *bomb = [CCParticleSystemQuad ];
    
    if ((self = [super initWithFile:file]))
    {
        CCParticleSystemQuad* bomb = [CCParticleSystemQuad particleWithFile:@"bomb.png"];
        [self addChild:bomb z:1 tag:1];
        CCParticleSystem* particle_system = [CCParticleSystemQuad particleWithFile:@"explosion.plist"];
        //particle_system.splurt = [CCParticleSystemQuad particleWithFile:@"explosion.plist"];
        [self addChild:particle_system];
    }
    return self;
}

@end
