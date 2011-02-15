//
//  HealthNode.h
//  Base Jump
//
//  Created by Nicholas Kostelnik on 10/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface HealthNode : CCNode {

  int health;
  int maxHealth;
  
}

- (void) setHealth:(int)h;

@end
