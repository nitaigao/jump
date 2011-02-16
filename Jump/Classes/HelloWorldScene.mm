//
//  HelloWorldScene.mm
//  Base Jump
//
//  Created by Nicholas Kostelnik on 06/02/2011.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldScene.h"
#import "PhysicsData.h"

#include "Constants.h"
#import "FloorContactListener.h"

#import "GUINode.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

// HelloWorld implementation
@implementation HelloWorld

static const int CASH_REWARD = 5;
static const int ROUNDS_PER_LEAGUE = 4;
static const int HEALTH_COST = 50;
static const int MAX_HEALTH = 100;

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void)scrollCamera:(CGPoint)point {
  [level.camera setCenterX:0 centerY:point.y centerZ:0];
  [level.camera setEyeX:0 eyeY:point.y eyeZ:1];  
}

- (void)updateCamera {
  CGSize screenSize = [CCDirector sharedDirector].winSize;
  
  if (player1.position.y < screenSize.height / 2) {
    [self scrollCamera:CGPointMake(0, 0)];
    return; 
  }
  
  if (player1.position.y < screenSize.height + (screenSize.height / 2)) {
    [self scrollCamera:CGPointMake(0, [player1 position].y - (screenSize.height / 2))];
  }  
}


- (void) setRound:(int)r {
  [gui setRound:r];
}

- (void) setLeague:(int)l {
  [gui setLeague:l];
  
  for (Player* player in players) {
    [player setAILeague:l];
  }
}

- (void) setCash:(int)c {
  [gui setCash:c];
}

- (void)start:(NSTimer*)timer {
  [startLabel setString:@"Go!"];
  state = PRE_PLAY;
}

- (void) runAI {
  for(Player* player in players) {
    if (player != player1) {
      [player ai];
    }
  }
}

- (void) setState:(NSInteger)s {
  state = s;
}

- (NSString*) positionText:(NSInteger)position {
  switch (position) {
    case 1:
      return @"1st!";
      break;
    case 2:
      return @"2nd";
      break;
    case 3:
      return @"3rd";
      break;
  }
  
  return @"Last";
}

- (void) endRound {
  [self addChild:endLabel];
  int position = 1;
  for (Player* player in landedPlayers) {
    if (player == player1) {
      break;
    }
    position++;
  }
  
  if ([player1 dead]) {
    [endLabel setString:@"Game Over!"];
    [self setState:GAME_OVER];
  } else {
    int cashMultiplier = [players count] - (position - 1);
    cash += CASH_REWARD * cashMultiplier;
    [self setCash:cash];
    [endLabel setString:[self positionText:position]];
    [self setState:ROUND_OVER]; 
  }  
}

- (void) updateHealth {
  [gui setHealth:[player1 health]];
}

- (void) updateCash {
  [gui setCash:cash];
}

- (void) playerLanded:(Player*)player { 
  [landedPlayers addObject:player];
  [self updateHealth];
  if ([players count] == [landedPlayers count]) {
    [self endRound]; 
  }
}

- (void)countdown:(NSTimer*)timer {
  switch (count--) {
    case 2:
      [startLabel setString:@"Ready!"];
      break;
    case 1:
      [startLabel setString:@"Set!"];
      break;
  }
  if (count > 0) {
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown:) userInfo:nil repeats:false]; 
  }
  else {
    int time = (arc4random() % 4) + 1;
    [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(start:) userInfo:nil repeats:false]; 
  }
}

- (void)resetScene { 
  CGSize screenSize = [CCDirector sharedDirector].winSize;
  
  [self scrollCamera:CGPointMake(0, screenSize.height)];
  
  state = NEW_GAME;
  
  for(Player* player in players) {
    [player reset]; 
  }
  
  [landedPlayers removeAllObjects];
  
  [self updateHealth];
  [startLabel setString:@"Tap to Start"];
  [endLabel setString:@""];
}

- (void) newGame {
  [player1 newGame];
  league = 1;
  [self setLeague:league];
  round = 1;
  [self setRound:round];
  cash = 0;
  [self resetScene];
}

- (void) newLeague {
  [self addChild:healthButton];
}

- (void) newRound {
  int new_round = ++round;
  if (round == ROUNDS_PER_LEAGUE + 1) {
    new_round = 1;
    round = 1;
    [self setLeague:++league];
    
  }
  
  [self setRound:new_round];
  [self resetScene];
}

// initialize your instance here
-(id) init
{
	if( (self=[super init])) {
		
    round = 1;
    league = 1;
    
		// enable touches
		self.isTouchEnabled = YES;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
    
    level = [[LevelNode alloc] init];
    [self addChild:level];
		
    CCSprite* background = [CCSprite spriteWithFile:@"background.png"];
    background.position = CGPointMake([background contentSize].width / 2, [background contentSize].height / 2);
    [level addChild:background];    
    
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, -10.0f);
		
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity, doSleep);
		
		world->SetContinuousPhysics(true);
    world->SetContactListener(new FloorContactListener(self));
		
		// Debug Draw functions
		m_debugDraw = new GLESDebugDraw(PTM_RATIO);
		world->SetDebugDraw(m_debugDraw);
		
		uint32 flags = 0;
//		flags += b2DebugDraw::e_shapeBit;
//		flags += b2DebugDraw::e_jointBit;
//		flags += b2DebugDraw::e_aabbBit;
//		flags += b2DebugDraw::e_pairBit;
//		flags += b2DebugDraw::e_centerOfMassBit;
		m_debugDraw->SetFlags(flags);		
    		
		// Define the ground body.
		b2BodyDef groundBodyDef;
		groundBodyDef.position.Set(0, 0); // bottom-left corner
    		
		// Call the body factory which allocates memory for the ground body
		// from a pool and creates the ground box shape (also from a pool).
		// The body is also added to the world.
		b2Body* groundBody = world->CreateBody(&groundBodyDef);
    		
		// Define the ground box shape.
		b2PolygonShape groundBox;		
    
    int groundHeight = 10;
		
		// bottom
		groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(screenSize.width/PTM_RATIO,0));
		groundBody->CreateFixture(&groundBox,0);
		
		// top
		groundBox.SetAsEdge(b2Vec2(0,groundHeight/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO, groundHeight/PTM_RATIO));
		groundBody->CreateFixture(&groundBox,0);
		
		// left
		groundBox.SetAsEdge(b2Vec2(0,groundHeight/PTM_RATIO), b2Vec2(0,0));
		groundBody->CreateFixture(&groundBox,0);
		
		// right
		groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,groundHeight/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
		groundBody->CreateFixture(&groundBox,0);
                
    CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:150];
		[level addChild:batch z:0 tag:kTagBatchNode];
    
    players = [[NSMutableArray alloc] init];
    landedPlayers = [[NSMutableArray alloc] init];
    
    static const int PLAYERS = 4;
    
    float x = ((screenSize.width / PLAYERS) * 0) + ((screenSize.width / PLAYERS) / 2);
    Player* player = [[Player alloc] initWithScene:level world:world position:ccp(x, (screenSize.height * 2) - 40) isPlayer:false];
    [players addObject:player];
    
    x = ((screenSize.width / PLAYERS) * 1) + ((screenSize.width / PLAYERS) / 2);
    player1 = [[Player alloc] initWithScene:level world:world position:ccp(x, (screenSize.height * 2) - 40) isPlayer:true];
    [players addObject:player1];
    
    x = ((screenSize.width / PLAYERS) * 2) + ((screenSize.width / PLAYERS) / 2);
    player = [[Player alloc] initWithScene:level world:world position:ccp(x, (screenSize.height * 2) - 40) isPlayer:false];
    [players addObject:player];
    
    x = ((screenSize.width / PLAYERS) * 3) + ((screenSize.width / PLAYERS) / 2);
    player = [[Player alloc] initWithScene:level world:world position:ccp(x, (screenSize.height * 2) - 40) isPlayer:false];
    [players addObject:player];
    
    startLabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:32];
    [level addChild:startLabel z:0];
    [startLabel setColor:ccc3(0, 0, 255)];
    startLabel.position = ccp( screenSize.width / 2, screenSize.height + (screenSize.height / 2));      
    
    endLabel = [[CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:32] retain];
    [endLabel setColor:ccc3(0, 0, 255)];
    endLabel.position = ccp(screenSize.width / 2, screenSize.height / 2);          
    
    gui = [[GUINode alloc] init];
    [self addChild:gui];
    
    healthButton = [[CCLabelTTF labelWithString:@"Buy Health" fontName:@"Marker Felt" fontSize:32] retain];
    healthButton.position = ccp(screenSize.width / 2, screenSize.height / 1.9);
    [healthButton setColor:ccc3(0, 0, 255)];
    
    continueButton = [[CCLabelTTF labelWithString:@"Continue" fontName:@"Marker Felt" fontSize:32] retain];
    continueButton.position = ccp(screenSize.width / 2, screenSize.height / 2.9);
    [continueButton setColor:ccc3(0, 0, 255)];
    
    [self resetScene];
		[self schedule: @selector(tick:)];
	}
	return self;
}

-(void) draw
{  
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

}

-(void) tick: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);

	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
  
  if (state == PLAY || state == PRE_PLAY) {
    [self runAI];
    [self updateCamera];
  }
}

- (void) offerHealth {
  [self setState:BUY_HEALTH];
  [self addChild:healthButton];
  [self addChild:continueButton];
}

- (void) buyHealth {
  if (cash > 50 && player1.health < 100) {
    cash -= 50;
    [player1 buyHealth];
    [self updateHealth];
    [self updateCash];
  }
}

- (void) continueGame {
  [self removeChild:healthButton cleanup:false];
  [self removeChild:continueButton cleanup:false];
  [self newRound]; 
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	for(UITouch *touch in touches) {    
    
    switch (state) {
      case NEW_GAME:
        state = COUNT_DOWN;
        count = 2;
        [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(countdown:) userInfo:nil repeats:false];        
        break;
        
      case PRE_PLAY:
        state = PLAY;
        [startLabel setString:@""];
        [player1 jump];        
        break;
        
      case PLAY:
        [player1 chute];         
        break;
        
      case ROUND_OVER:
        [self removeChild:endLabel cleanup:false];
        if (round == ROUNDS_PER_LEAGUE) {
          [self offerHealth];
        }
        else {
         [self newRound]; 
        }
        break;
        
      case BUY_HEALTH: {
        CGPoint rawLocation = [touch locationInView: [touch view]];
        CGPoint touchLocation = [[CCDirector sharedDirector] convertToGL:rawLocation];
        
        if (CGRectContainsPoint(CGRectMake(healthButton.position.x - (healthButton.contentSize.width / 2), healthButton.position.y - (healthButton.contentSize.height / 2), healthButton.contentSize.width, healthButton.contentSize.height), touchLocation)) {
          [self buyHealth];
        }
        
        if (CGRectContainsPoint(CGRectMake(continueButton.position.x - (continueButton.contentSize.width / 2), continueButton.position.y - (continueButton.contentSize.height), continueButton.contentSize.width, continueButton.contentSize.height), touchLocation)) {
          [self continueGame];
        }
        
        break;
      }
        
      case GAME_OVER:
        [self newGame];
        break;
    }
  }
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
	
	delete m_debugDraw;

	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
