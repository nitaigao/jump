//
//  Player.h
//  Base Jump
//
//  Created by Nicholas Kostelnik on 06/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "cocos2d.h"
#import "Box2D.h"

@interface Player : NSObject {
  CCSprite* sprite; 
  b2Body* body;
  b2World* world;
  CCNode* scene;
  CGPoint start;
  bool landed;
  bool chute;
  int state;
  float health;
}

- (id) initWithScene:(CCNode*)s world:(b2World*)w position:(CGPoint)p isPlayer:(bool)isPlayer;
- (void) jump;
- (void) chute;
- (bool) landed;
- (void) landed:(bool)l;
- (void) reset;
- (void) ai;
- (CGPoint) position;
- (void) addLandingForce:(float)force;
- (int) health;
- (bool) dead;
- (void) newGame;
@end
