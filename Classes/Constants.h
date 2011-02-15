#ifndef __CONSTANTS
#define __CONSTANTS

enum {
  FIXTURE_DEFAULT = 0,
  GROUND = 1,
  PLAYER = 2
};


enum {
  STATE_DEFAULT = 0,
  NEW_GAME = 1,
  COUNT_DOWN = 2,
  PRE_PLAY = 3,
  PLAY = 4,
  ROUND_OVER = 5,
  GAME_OVER = 6
};

enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};

struct BodyData {
  
  int m_type;
  
};

#endif
