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
  healthNode = [[HealthNode alloc] init];
  [self addChild:healthNode];  
  
  return self;
}

- (void) setHealth:(int)h {
  [healthNode setHealth:h];
}

@end
