//
//  Player.m
//  Base Jump
//
//  Created by Nicholas Kostelnik on 06/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Player.h"
#import "PhysicsData.h"

#include "Constants.h"

#define PTM_RATIO 32
static const int HEALTH_INC = 35;


@implementation Player

@synthesize health;

enum {
  DEFAULT = 0,
  READY = 1,
  JUMPING = 2,
  LANDING = 3
};

- (id) initWithScene:(CCNode*)s world:(b2World*)w position:(CGPoint)p isPlayer:(bool)isPlayer {
  scene = s;
  world = w;
  start = p;
  
  
  sprite = [CCSprite spriteWithFile:(isPlayer) ? @"face_green.png" : @"face_red.png"];  
  [scene addChild:sprite];
  
  [self newGame];
  [self reset];
  return [super init];
}

- (void) newGame {
  health = 100;
}

- (void) reset {
  sprite.position = ccp(start.x, start.y);
  
  if (body != 0) {
    world->DestroyBody(body);
  }
  
  landed = false;
  chute = false;
  state = READY;
}

- (void) jump {
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
  
	bodyDef.position.Set(sprite.position.x/PTM_RATIO, sprite.position.y/PTM_RATIO);
	bodyDef.userData = sprite;
	body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f); //These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
  
  fixtureDef.userData = self;
  
	body->CreateFixture(&fixtureDef);
}

- (void) ai {
  switch (state) {      
    case READY: {
      state = JUMPING;
      float jumpInterval = ((arc4random() % 10) + 1) / 10.0f;
      [NSTimer scheduledTimerWithTimeInterval:jumpInterval target:self selector:@selector(jump) userInfo:nil repeats:false];
      break;
    }
      
    case JUMPING: {
      int maxHeight = 300;
      int minHeight = 70 - (aiLeague * 10);
      float chuteHeight = (arc4random() % (maxHeight - minHeight)) + minHeight;
      if (sprite.position.y < chuteHeight) {
        state = LANDING;
        [self chute]; 
      }
      break;
    }
  }
}

- (void) setAILeague:(int)l {
  aiLeague = l;
}

- (bool) landed { 
  return landed;
}

- (void) landed:(bool)l { 
  landed = l; 
}

- (void) chute {
  chute = true;
  body->SetLinearDamping(5.0f);
}

- (CGPoint) position {
  return sprite.position; 
}

- (void) addLandingForce:(float)force {
  if (!landed) {
    health = health - (force * 3);
    health = health < 0 ? 0 : health;
  }
}

- (bool) dead {
  return health == 0; 
}

- (void)dealloc {
    [super dealloc];
}

- (void) buyHealth {
  health += 35;
  health = health > 100 ? 100 : health;
}

@end
