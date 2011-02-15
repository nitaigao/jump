#ifndef __FLOOR_CONTACT_LISTENER
#define __FLOOR_CONTACT_LISTENER

#include "Box2D.h"

#include "Constants.h"

#include "Player.h"
#include "GameState.h"

class FloorContactListener : public b2ContactListener
{

public:
  
  FloorContactListener(HelloWorld* state)
  : m_state(state) { };
  
  void BeginContact(b2Contact* contact)
  {
   
  }
  
  void EndContact(b2Contact* contact)
  {
  
  }
  
  void PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
  {

  }
  
  void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) 
  {
    b2Fixture* fixtureB = contact->GetFixtureB();
    Player* player = (Player*)fixtureB->GetUserData();
        
    if (![player landed]) {
      [player addLandingForce:contact->GetManifold()->points[0].normalImpulse];
      [player landed:true];
      [m_state playerLanded:player];
    }
    
  }
  
  void setState(HelloWorld* state) {
    m_state = state; 
  }
  
private:
  
  HelloWorld* m_state;

};

#endif
