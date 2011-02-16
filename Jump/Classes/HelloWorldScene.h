//
//  HelloWorldScene.h
//  Base Jump
//
//  Created by Nicholas Kostelnik on 06/02/2011.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

#import "Player.h"
#import "LevelNode.h"
#import "GUINode.h"

// HelloWorld Layer

class FloorContactListener;

@interface HelloWorld : CCLayer
{
	b2World* world;
	GLESDebugDraw *m_debugDraw;
  
  LevelNode* level;
  GUINode* gui;
  
  CCLabelTTF* healthButton;
  CCLabelTTF* continueButton;
  
  NSMutableArray *players;
  NSMutableArray *landedPlayers;
  FloorContactListener* contactListener;
  Player* player1;
  int state;
  
  CCLabelTTF* startLabel;
  CCLabelTTF* endLabel;
  NSInteger count;
  int round;
  int league;
  int cash;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

// adds a new sprite at a given coordinate
- (void) playerLanded:(Player*)player;

@end
