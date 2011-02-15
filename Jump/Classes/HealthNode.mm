//
//  HealthNode.m
//  Base Jump
//
//  Created by Nicholas Kostelnik on 10/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HealthNode.h"


@implementation HealthNode

- (id) init {
  self = [super init];
  maxHealth = 100;
  health = maxHealth;
  return self;
}

- (void) draw {
  int lineHeight = 8;
  int lineX = 210;
  int lineY = 470;
  
  static int maxColor = 200;
  static int colorBuffer = 55;
  
  float percentage = ((float) health) / ((float) maxHealth);
  int amtRed = ((1.0f-percentage)*maxColor)+colorBuffer;
  int amtGreen = (percentage*maxColor)+colorBuffer;
  
  glEnable(GL_LINE_SMOOTH);
  
  glLineWidth(lineHeight);        
  glColor4ub(amtRed,amtGreen,0,255);
  
  ccDrawLine(ccp(lineX, lineY), ccp(lineX + (100 * percentage), lineY));      
}

- (void) setHealth:(int)h { 
  health = h; 
}

@end
