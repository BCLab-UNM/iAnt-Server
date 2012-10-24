#import <Foundation/Foundation.h>

#define DISTR_RANDOM 0
#define DISTR_POWERLAW 1
#define DISTR_CLUSTERED 2

@class ABSSimulationColony;
@class ABSSimulationLocation;

@interface NSObject(ABSSimulationNotifications)
  -(void) didFinishGeneration;
@end

@interface ABSSimulation : NSObject {
  NSMutableArray* ants;
  NSMutableArray* colonies;
  
  //YO MAN WHERE DAT LEXICAL SCOPIN' AT
  int updateCount;
  
  int evaluationCount;
  int stepCount;
  float antTimeOutCost;
  
  int search_delay; //time steps between a searching ant's move.  0 is move on every time step.
  int return_delay; //time steps between a returning ant's move.  0 is move on every time step.
  int crossover_rate; //Percent chance for crossover.  50 is complete shuffling.  0 or 100 is no crossover
  
  int clumpradius;
  int n_food_red; //1 pile
  int n_food_orange; //2 piles
  int n_food_green; //4 piles
  int n_food_purple; //64 piles
  int n_food_blue; //random
  int num_each_clump;
  int n_food_background; //please...please kill me.. (take this out though, seriously).
  int count_food_red;
  int count_food_orange;
  int count_food_green;
  int count_food_blue;
  int grid_height; //each grid cell is 10x10 cm
  int grid_width; //3m is 53.  6m is 106.
  int nestx;
  int nesty;
  int count_food1;
  int count_food2;
  int pherminx;
  int phermaxx;
  int pherminy;
  int phermaxy;
  float deposit_rate_p2;
  float saturation_p1;
  float saturation_p2;
  int smell_range;
  float return_pheromone;
  
  int sumdx;
  int sumdy;
  
  ABSSimulationLocation* grid[768][768]; //Really?
  ABSSimulationLocation* gen_grid[768][768]; //Really?
  
  int col_count; //Really?
}

-(int) startSimulation;
-(void) stopSimulation;
-(void) run;
-(void) initColonies;
-(void) initDistribution; 

@property id delegate;

@property ABSSimulationColony* bestColony;

@property int colonyCount;
@property int generationCount;
@property int antCount;

@property BOOL usesPheromones;
@property BOOL usesSiteFidelity;

@property float distributionRandom;
@property float distributionPowerlaw;
@property float distributionClustered;
@property int numberOfSeeds;

@property BOOL started;

@end