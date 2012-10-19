#import <Foundation/Foundation.h>

@interface ABSSimulationAnt : NSObject {
  int x, y;
  int rfidX, rfidY; // ant's rfid reader's x and y coordinates -- rfid reader trails behind antbot as it searches
  int returnX, returnY; // coordinates of last seed found
  int prevX, prevY; // location ant moved from on previous search move.
  int searchTime; // time since ant began its search
  int searchTimeCounter,travelTimeCounter,returnTimeCounter;
  int antStatus; // 0 = no ant; 1 = ant following trail; 2 = ant carrying food; 3 = searching ant; 4 = traveling ant
  BOOL influenceable; // ant will be influenced by any pheromone trails at nest entrance? true = ants will follow pheromones if present instead of walk at random or return to patch
  int carrying; // food type ant is carrying: 0 = no food; # = foot item of distribution #
  int sinceMove; // time steps since a searching ant last moved.
  BOOL penDown; // false = ant not laying a trail; true = ant laying a trail
  float previousPheromone; // Amount of pheromone on previous cell as ant moved along trail.
  float previousPheromoneScent; // The out-going sum_pheromone an detected on the previous move by an ant following a trail.
  float direction; // direction an ant who detected no trail at nest is travelling.  value in degrees.
  float searchDirection; // direction in degrees that a searching ant moved in the previous time step (ideal direction, not grid direction)
}

@property int x,y;
@property int rfidX, rfidY;
@property int returnX, returnY;
@property int prevX, prevY;
@property int searchTime, searchTimeCounter, travelTimeCounter, returnTimeCounter;
@property int antStatus;
@property BOOL influenceable;
@property int carrying;
@property int sinceMove;
@property BOOL penDown;
@property float previousPheromone;
@property float previousPheromoneScent;
@property float direction;
@property float searchDirection;

@end
