//
//  GUINode.mm
//  Base Jump
//
//  Created by Nicholas Kostelnik on 09/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GUINode.h"


@implementation GUINode

- (id) init {
  [super init];
    
  CCSprite* background = [CCSprite spriteWithFile:@"gui_background.png"];
  background.position = ccp(320/2, 480);
  [self addChild:background];    

  CGSize screenSize = [CCDirector sharedDirector].winSize;
  
  roundLabel = [CCLabelTTF labelWithString:@"Round:1" fontName:@"Marker Felt" fontSize:18];
  roundLabel.position = ccp(30, screenSize.height - 10);   
  [self addChild:roundLabel];
  
  leagueLabel = [CCLabelTTF labelWithString:@"League:1" fontName:@"Marker Felt" fontSize:18];
  leagueLabel.position = ccp(100, screenSize.height - 10);   
  [self addChild:leagueLabel];
  
  healthNode = [[HealthNode alloc] init];
  [self addChild:healthNode];  
  
  return self;
}

- (void) setHealth:(int)h {
  [healthNode setHealth:h];
}

- (void) setRound:(int)r {
  [roundLabel setString:[[NSString alloc]initWithFormat:@"Round:%d", r]];
}

- (void) setLeague:(int)l {
  [leagueLabel setString:[[NSString alloc]initWithFormat:@"League:%d", l]];
}
@end
