#import <Cocoa/Cocoa.h>
#import "ABSSimulation.h"
#import "ABSSimulationColony.h"
#import "ABSSimulationAnt.h"
#import "ABSSimulationLocation.h"
#import "ABSWriter.h"

/*
 * Returns a random float between 0 and x.
 */
static inline float randomFloat(float x) {
  return (((float)arc4random())/0x100000000)*x;
}

@implementation ABSSimulation

@synthesize delegate;
@synthesize simulationTag;
@synthesize colonyCount, generationCount, antCount;
@synthesize usesPheromones, usesSiteFidelity;
@synthesize distributionRandom, distributionPowerlaw, distributionClustered, numberOfSeeds;
@synthesize bestColony;
@synthesize started;

/*
 * Starts the simulation run.
 *
 * Exit codes:
 *  0 -- all is well.
 *  1 -- tried to call start when already running.
 *  2 -- thread received cancel request.
 *
 */
-(int) startSimulation {

  if(started){return 1;} //No stopping and starting for now.
  
  started = YES;
  
  writer = [ABSWriter getInstance];
  filename = [NSString stringWithFormat:@"/Users/bjorn/Desktop/%@.csv",simulationTag];
  [writer openFilename:filename];

  bestColony = [[ABSSimulationColony alloc] init];
  ants = [[NSMutableArray alloc] init];
  for(int i = 0; i < antCount; i++) {
    [ants addObject:[[ABSSimulationAnt alloc] init]];
  }
  colonies = [[NSMutableArray alloc] init];
  
  [self initDistribution];
  
  //Set default values for non-configurable variables.
  updateCount = 0;
  evaluationCount = 1;
  stepCount = 13500 / 2; //13500 = 1 hour.
  antTimeOutCost = 0.f;
  search_delay = 4;
  return_delay = 0;
  crossover_rate = 10;
  clumpradius = 2;
  num_each_clump = 1;
  n_food_background = 0;
  count_food_red = 0;
  count_food_orange = 0;
  count_food_green = 0;
  count_food_blue = 0;
  grid_width = 90; //88.6 = 5m
  grid_height = 90;
  nestx = grid_width / 2;
  nesty = grid_height / 2;
  pherminx = nestx;
  phermaxx = nestx;
  pherminy = nesty;
  phermaxy = nesty;
  deposit_rate_p2 = 0.1;
  saturation_p1 = 1.0;
  saturation_p2 = 1.0;
  smell_range = 1;
  return_pheromone = 0.0;
  sumdx = 0;
  sumdy = 0;
  
  for(int i = 0; i < grid_height; i++) {
    for(int j = 0; j < grid_width; j++) {
      grid[i][j] = [[ABSSimulationLocation alloc] init];
      gen_grid[i][j] = [[ABSSimulationLocation alloc] init];
    }
  }

  //Initialize first generation of colonies
  [self initColonies];

  for(int gen_count = 0; gen_count < generationCount; gen_count++) {
    printf("gen%d\n",gen_count);
    if([[NSThread currentThread] isCancelled]){return 2;}
    
    for(int eval_count = 0; eval_count < evaluationCount; eval_count++) {
      //Clean up grid for new evalution
      for(int x = 0; x < grid_width; x++) {
        for(int y = 0; y < grid_width; y++) {
          gen_grid[x][y].p1 = 0;
          gen_grid[x][y].p2 = 0;
          gen_grid[x][y].ant_status = 0;
          gen_grid[x][y].carrying = 0;
          gen_grid[x][y].food = 0;
          gen_grid[x][y].nest = false;
          gen_grid[x][y].pen_down = false;
        }
      }
      
      //Place nest entrance
      gen_grid[nestx][nesty].nest = true;
      
      int locations[4 * num_each_clump][2];
      int food_count = 0;
      int tempradius = clumpradius;
      int rad_count = 0;
      for(int clump_count = 1; clump_count <= num_each_clump; clump_count++) {
        int clumpx;
        int clumpy;
        int overlap = 1;
        //Place red food -- one big pile
        while(overlap == 1) {
          clumpx =
          arc4random () % (grid_width - clumpradius * 2) + clumpradius;
          clumpy =
          arc4random () % (grid_height - clumpradius * 2) + clumpradius;
          overlap = 0;
          int clumpcheck = 0;
          while(clumpcheck < (4 * clump_count - 4)) {
            if(sqrt(pow(clumpx - locations[clumpcheck][0], 2) + pow(clumpy - locations[clumpcheck][1], 2)) < clumpradius * 2){overlap = 1;}
            clumpcheck++;
          }
        }
        locations[4 * clump_count - 4][0] = clumpx;
        locations[4 * clump_count - 4][1] = clumpy;
        food_count = 0;
        while(food_count < n_food_red) {
          if(rad_count > n_food_red * 4) {
            tempradius++;
            rad_count = 0;
          }
          int randx =
          arc4random () % (tempradius * 2) + clumpx - tempradius;
          int randy =
          arc4random () % (tempradius * 2) + clumpy - tempradius;
          float seeddist =
          sqrt (pow (clumpx - randx, 2) + pow (clumpy - randy, 2));
          if(randx < 0 || randx > grid_width || randy < 0
              || randy > grid_height) {
            continue;
          }
          else if((gen_grid[randx][randy].food == 0) &
                   (seeddist < tempradius)) {
            gen_grid[randx][randy].food = 1;
            food_count++;
          }
          rad_count++;
        }
        
        //Place orange food -- two piles
        for(int i = 0; i < 2; i++) {
          int overlap = 1;
          while(overlap == 1) {
            clumpx =
            arc4random () % (grid_width - clumpradius * 2) +
            clumpradius;
            clumpy =
            arc4random () % (grid_height - clumpradius * 2) +
            clumpradius;
            overlap = 0;
            int clumpcheck = 0;
            while(clumpcheck < (4 * clump_count - 3)) {
              if(sqrt
                  (pow (clumpx - locations[clumpcheck][0], 2) +
                   pow (clumpy - locations[clumpcheck][1],
                        2)) < clumpradius * 2)
                overlap = 1;
              clumpcheck++;
            }
          }
          locations[4 * clump_count - 3][0] = clumpx;
          locations[4 * clump_count - 3][1] = clumpy;
          food_count = 0;
          tempradius = clumpradius;
          rad_count = 0;
          while(food_count < n_food_orange / 2) {
            if(rad_count > n_food_orange * 4) {
              tempradius++;
              rad_count = 0;
            }
            int randx =
            arc4random () % (tempradius * 2) + clumpx - tempradius;
            int randy =
            arc4random () % (tempradius * 2) + clumpy - tempradius;
            float clumpdist =
            sqrt (pow (clumpx - randx, 2) +
                  pow (clumpy - randy, 2));
            if(randx < 0 || randx > grid_width || randy < 0
                || randy > grid_height) {
              continue;
            }
            else if((gen_grid[randx][randy].food == 0) &
                     (clumpdist < tempradius)) {
              gen_grid[randx][randy].food = 2;
              food_count++;
            }
            rad_count++;
          }
        }
        
        
        //Place green food -- four piles
        for(int i = 0; i < 4; i++) {
          int overlap = 1;
          while(overlap == 1) {
            clumpx =
            arc4random () % (grid_width - clumpradius * 2) +
            clumpradius;
            clumpy =
            arc4random () % (grid_height - clumpradius * 2) +
            clumpradius;
            overlap = 0;
            int clumpcheck = 0;
            while(clumpcheck < (4 * clump_count - 2)) {
              if(sqrt
                  (pow (clumpx - locations[clumpcheck][0], 2) +
                   pow (clumpy - locations[clumpcheck][1],
                        2)) < clumpradius * 2)
                overlap = 1;
              clumpcheck++;
            }
          }
          locations[4 * clump_count - 2][0] = clumpx;
          locations[4 * clump_count - 2][1] = clumpy;
          food_count = 0;
          tempradius = clumpradius;
          rad_count = 0;
          while(food_count < n_food_green / 4) {
            if(rad_count > n_food_green * 4) {
              tempradius++;
              rad_count = 0;
            }
            int randx =
            arc4random () % (tempradius * 2) + clumpx - tempradius;
            int randy =
            arc4random () % (tempradius * 2) + clumpy - tempradius;
            float clumpdist =
            sqrt (pow (clumpx - randx, 2) +
                  pow (clumpy - randy, 2));
            if(randx < 0 || randx > grid_width || randy < 0
                || randy > grid_height) {
              continue;
            }
            else if((gen_grid[randx][randy].food == 0) &
                     (clumpdist < tempradius)) {
              gen_grid[randx][randy].food = 3;
              food_count++;
            }
            rad_count++;
          }
        }
        
        
        //Place purple food
        for(int i = 0; i < 64; i++) {
          int overlap = 1;
          while(overlap == 1) {
            clumpx = arc4random () % (grid_width - clumpradius * 2) + clumpradius;
            clumpy = arc4random () % (grid_height - clumpradius * 2) + clumpradius;
            overlap = 0;
            int clumpcheck = 0;
            while(clumpcheck < (4 * clump_count - 1)) {
              if(sqrt
                  (pow (clumpx - locations[clumpcheck][0], 2) +
                   pow (clumpy - locations[clumpcheck][1],
                        2)) < clumpradius * 2)
                overlap = 1;
              clumpcheck++;
            }
          }
          locations[4 * clump_count - 1][0] = clumpx;
          locations[4 * clump_count - 1][1] = clumpy;
          food_count = 0;
          tempradius = clumpradius;
          rad_count = 0;
          while(food_count < n_food_purple / 64) {
            if(rad_count > n_food_purple * 4) {
              tempradius++;
              rad_count = 0;
            }
            int randx =
            arc4random () % (tempradius * 2) + clumpx - tempradius;
            int randy =
            arc4random () % (tempradius * 2) + clumpy - tempradius;
            float clumpdist =
            sqrt (pow (clumpx - randx, 2) +
                  pow (clumpy - randy, 2));
            if(randx < 0 || randx > grid_width || randy < 0
                || randy > grid_height) {
              continue;
            }
            else if((gen_grid[randx][randy].food == 0) &
                     (clumpdist < tempradius)) {
              gen_grid[randx][randy].food = 4;
              food_count++;
            }
            rad_count++;
          }
        }
        
        
        //Place blue food -- random scattering of food
        food_count = 0;
        while(food_count < n_food_blue) {
          int randx = arc4random () % grid_width;
          int randy = arc4random () % grid_height;
          if(gen_grid[randx][randy].food == 0) {
            gen_grid[randx][randy].food = 5;
            food_count++;
          }
        }
      }
      
      //Place background food
      food_count = 0;
      while(food_count <= n_food_background) {
        int randx = arc4random () % grid_width;
        int randy = arc4random () % grid_height;
        if(gen_grid[randx][randy].food == 0) {
          gen_grid[randx][randy].food = 5;
          food_count++;
        }
      }
      
      //Evaluation Loop
      for(col_count = 0; col_count < colonyCount; col_count++) {
        
        //Reset grid for next colony
        return_pheromone = 0.0;
        for(int x = 0; x < grid_width; x++) {
          for(int y = 0; y < grid_width; y++) {
            grid[x][y].p1 = gen_grid[x][y].p1;
            grid[x][y].p2 = gen_grid[x][y].p2;
            grid[x][y].ant_status = gen_grid[x][y].ant_status;
            grid[x][y].carrying = gen_grid[x][y].carrying;
            grid[x][y].food = gen_grid[x][y].food;
            grid[x][y].nest = gen_grid[x][y].nest;
            grid[x][y].pen_down = gen_grid[x][y].pen_down;
          }
        }
        
        //Clean up ants
        int n_active_ants = ceil (antCount * [[colonies objectAtIndex:col_count] activeProportion]); //6 * 
        for(int i = 0; i < antCount; i++) {
          [[ants objectAtIndex:i] setX:nestx];
          [[ants objectAtIndex:i] setY:nesty];
          [[ants objectAtIndex:i] setSearchTime:0];
          [[ants objectAtIndex:i] setPrevX:-1];
          [[ants objectAtIndex:i] setPrevY:-1];
          [[ants objectAtIndex:i] setAntStatus:4];
          [[ants objectAtIndex:i] setCarrying:0];
          [[ants objectAtIndex:i] setPenDown:NO];
          [[ants objectAtIndex:i] setPreviousPheromoneScent:0.f];
          [[ants objectAtIndex:i] setDirection:(arc4random () % 360)];
          if(i < n_active_ants){[[ants objectAtIndex:i] setAntStatus:4];}
          else{[[ants objectAtIndex:i] setAntStatus:0];}
        }
        
        //Run evalution for stepCount time steps
        updateCount = 0;
        while(updateCount < stepCount) {
          [self run];
          if([[NSThread currentThread] isCancelled]){return 2;}
        }
      }
    }
    
    //Populate next generation
    if(colonyCount>1) {
      ABSSimulationColony* new_colonies[colonyCount];
      for(int i = 0; i < colonyCount; i++) {
        new_colonies[i] = [[ABSSimulationColony alloc] init];
        int p1;
        int p2;
        int candidate1;
        int candidate2;
        
        //1st parent candidates
        candidate1 = arc4random () % colonyCount;
        candidate2 = arc4random () % colonyCount;
        while(candidate1 == candidate2){candidate2 = arc4random () % colonyCount;}
        if([[colonies objectAtIndex:candidate1] seedsCollected] > [[colonies objectAtIndex:candidate2] seedsCollected]){p1 = candidate1;}
        else{p1 = candidate2;}
        
        //2nd parent candidates
        candidate1 = arc4random () % colonyCount;
        candidate2 = arc4random () % colonyCount;
        while(candidate1 == candidate2){candidate2 = arc4random () % colonyCount;}
        if([[colonies objectAtIndex:candidate1] seedsCollected] > [[colonies objectAtIndex:candidate2] seedsCollected]){p2 = candidate1;}
        else{p2 = candidate2;}
        
        ABSSimulationColony* parent1 = [colonies objectAtIndex:p1];
        ABSSimulationColony* parent2 = [colonies objectAtIndex:p2];
        
        //Independent Assortment for each parameter.
        if(arc4random () % 100 < crossover_rate){new_colonies[i].decayRate = [parent1 decayRate];}
        else{new_colonies[i].decayRate = [parent2 decayRate];}
        
        if(arc4random () % 100 < crossover_rate){new_colonies[i].walkDropRate = [parent1 walkDropRate];}
        else{new_colonies[i].walkDropRate =[parent2 walkDropRate];}
        
        if(arc4random () % 100 < crossover_rate){new_colonies[i].searchGiveupRate = [parent1 searchGiveupRate];}
        else{new_colonies[i].searchGiveupRate =[parent2 searchGiveupRate];}
        
        if(arc4random () % 100 < crossover_rate){new_colonies[i].trailDropRate = [parent1 trailDropRate];}
        else{new_colonies[i].trailDropRate = [parent2 trailDropRate];}
        
        if(arc4random () % 100 < crossover_rate){new_colonies[i].dirDevConst = [parent1 dirDevConst];}
        else{new_colonies[i].dirDevConst = [parent2 dirDevConst];}
        
        if(arc4random () % 100 < crossover_rate){new_colonies[i].dirDevCoeff1 = [parent1 dirDevCoeff1];}
        else{new_colonies[i].dirDevCoeff1 = [parent2 dirDevCoeff1];}
        
        if(arc4random () % 100 < crossover_rate){new_colonies[i].dirTimePow1 = [parent1 dirTimePow1];}
        else{new_colonies[i].dirTimePow1 = [parent2 dirTimePow1];}
        
        if(arc4random () % 100 < crossover_rate){new_colonies[i].dirDevCoeff2 = [parent1 dirDevCoeff2];}
        else{new_colonies[i].dirDevCoeff2 = [parent2 dirDevCoeff2];}
        
        if(arc4random () % 100 < crossover_rate){new_colonies[i].dirTimePow2 = [parent1 dirTimePow2];}
        else{new_colonies[i].dirTimePow2 = [parent2 dirTimePow2];}
        
        if(arc4random () % 100 < crossover_rate){new_colonies[i].densitySensitivity = [parent1 densitySensitivity];}
        else{new_colonies[i].densitySensitivity = [parent2 densitySensitivity];}
        
        if(arc4random () % 100 < crossover_rate){new_colonies[i].densityThreshold = [parent1 densityThreshold];}
        else{new_colonies[i].densityThreshold = [parent2 densityThreshold];}
        
        if(arc4random () % 100 < crossover_rate){new_colonies[i].densityConstant = [parent1 densityConstant];}
        else{new_colonies[i].densityConstant = [parent2 densityConstant];}
        
        if(arc4random () % 100 < crossover_rate){new_colonies[i].densityPatchConstant = [parent1 densityPatchConstant];}
        else{new_colonies[i].densityPatchConstant =[parent2 densityPatchConstant];}
        
        if(arc4random () % 100 < crossover_rate){new_colonies[i].densityPatchThreshold = [parent1 densityPatchThreshold];}
        else{new_colonies[i].densityPatchThreshold = [parent2 densityPatchThreshold];}
        
        if(arc4random () % 100 < crossover_rate){new_colonies[i].densityInfluenceConstant = [parent1 densityInfluenceConstant];}
        else{new_colonies[i].densityInfluenceConstant = [parent2 densityInfluenceConstant];}
        
        if(arc4random () % 100 < crossover_rate){new_colonies[i].densityInfluenceThreshold = [parent1 densityInfluenceThreshold];}
        else{new_colonies[i].densityInfluenceThreshold = [parent2 densityInfluenceThreshold];}
        
        if(arc4random () % 100 < crossover_rate){new_colonies[i].activeProportion = [parent1 activeProportion];}
        else{new_colonies[i].activeProportion = [parent2 activeProportion];}
        
        if(arc4random () % 100 < crossover_rate){new_colonies[i].activationSensitivity = [parent1 activationSensitivity];}
        else{new_colonies[i].activationSensitivity = [parent2 activationSensitivity];}
        
        if(arc4random () % 100 < crossover_rate){new_colonies[i].decayRateReturn = [parent1 decayRateReturn];}
        else{new_colonies[i].decayRateReturn = [parent2 decayRateReturn];}
        
        //Random mutation
        if(arc4random () % 10 == 0)
        {
          new_colonies[i].decayRate +=
          randomFloat(new_colonies[i].decayRate * 0.05);
          if(new_colonies[i].decayRate < 0.0f)
            new_colonies[i].decayRate = 0;
          if(new_colonies[i].decayRate > 1.0f)
            new_colonies[i].decayRate = 1.0f;
        }
        //Random mutation
        if(arc4random () % 10 == 0)
        {
          new_colonies[i].walkDropRate +=
          randomFloat(new_colonies[i].walkDropRate * 0.05);
          if(new_colonies[i].walkDropRate < 0.0f)
            new_colonies[i].walkDropRate = 0;
          if(new_colonies[i].walkDropRate > 1.0f)
            new_colonies[i].walkDropRate = 1.0f;
        }
        //Random mutation
        if(arc4random () % 10 == 0)
        {
          new_colonies[i].searchGiveupRate +=
          randomFloat(new_colonies[i].searchGiveupRate * 0.05);
          if(new_colonies[i].searchGiveupRate < 0.0f)
            new_colonies[i].searchGiveupRate = 0;
          if(new_colonies[i].searchGiveupRate > 1.0f)
            new_colonies[i].searchGiveupRate = 1.0f;
        }
        //Random mutation
        if(arc4random () % 10 == 0)
        {
          new_colonies[i].trailDropRate +=
          randomFloat(new_colonies[i].trailDropRate * .05);
          if(new_colonies[i].trailDropRate < 0.0f)
            new_colonies[i].trailDropRate = 0;
          if(new_colonies[i].trailDropRate > 1.0f)
            new_colonies[i].trailDropRate = 1.0f;
        }
        //Random mutation
        if(arc4random () % 10 == 0)
        {
          new_colonies[i].dirDevConst +=
          randomFloat(
                      0.001 +
                      fabs (new_colonies[i].dirDevConst * .05));
          if(new_colonies[i].dirDevConst < 0.0f)
            new_colonies[i].dirDevConst = 0;
        }
        //Random mutation
        if(arc4random () % 10 == 0)
        {
          new_colonies[i].dirDevCoeff2 +=
          randomFloat(
                      0.001 +
                      fabs (new_colonies[i].dirDevCoeff2 * .05));
          if(new_colonies[i].dirDevCoeff2 < 0.0f)
            new_colonies[i].dirDevCoeff2 = 0;
        }
        //Random mutation
        if(arc4random () % 10 == 0)
        {
          new_colonies[i].dirTimePow2 +=
          randomFloat(
                      0.001 +
                      fabs (new_colonies[i].dirTimePow2 * .05));
          if(new_colonies[i].dirTimePow2 < 0.0f)
            new_colonies[i].dirTimePow2 = 0;
        }
        //Random mutation
        if(usesPheromones)
        {
          if(arc4random () % 10 == 0)
          {
            new_colonies[i].densityThreshold +=
            randomFloat(
                        0.001 +
                        fabs (new_colonies[i].densityThreshold * .05));
          }
          if(arc4random () % 10 == 0)
          {
            new_colonies[i].densityConstant +=
            randomFloat(
                        0.001 +
                        fabs (new_colonies[i].densityConstant * .05));
          }
        }
        if(usesSiteFidelity)
        {
          if(arc4random () % 10 == 0)
          {
            new_colonies[i].densityPatchConstant +=
            randomFloat(
                        0.001 +
                        fabs (new_colonies[i].densityPatchConstant *
                              .05));
          }
          if(arc4random () % 10 == 0)
          {
            new_colonies[i].densityPatchThreshold +=
            randomFloat(
                        0.001 +
                        fabs (new_colonies[i].densityPatchThreshold *
                              .05));
          }
        }
        if(arc4random () % 10 == 0)
        {
          new_colonies[i].densityInfluenceConstant +=
          randomFloat(
                      0.001 +
                      fabs (new_colonies[i].densityInfluenceConstant *
                            .05));
        }
        if(arc4random () % 10 == 0)
        {
          new_colonies[i].densityInfluenceThreshold +=
          randomFloat(
                      0.001 +
                      fabs (new_colonies[i].densityInfluenceThreshold *
                            .05));
        }
        if(arc4random () % 10 == 0)
        {
          new_colonies[i].activationSensitivity +=
          randomFloat(
                      0.001 +
                      fabs (new_colonies[i].activationSensitivity *
                            .05));
          if(new_colonies[i].activationSensitivity < 0.0f)
            new_colonies[i].activationSensitivity = 0.0;
        }
        if(arc4random () % 10 == 0)
        {
          new_colonies[i].decayRateReturn +=
          randomFloat(
                      0.001 +
                      fabs (new_colonies[i].decayRateReturn * .05));
          if(new_colonies[i].decayRateReturn < 0.0f)
            new_colonies[i].decayRateReturn = 0.0;
          if(new_colonies[i].decayRateReturn > 1.0f)
            new_colonies[i].decayRateReturn = 1.0;
        }
        
      }
      
      //Set next generation of colonies, and average together colony parameters.
      float decayRateSum = 0.f,
      walkDropRateSum = 0.f,
      trailDropRateSum = 0.f,
      dirDevConstSum = 0.f,
      dirDevCoeff2Sum = 0.f,
      dirTimePow2Sum = 0.f,
      densityThresholdSum = 0.f,
      densityConstantSum = 0.f,
      densityPatchThresholdSum = 0.f,
      densityPatchConstantSum = 0.f,
      densityInfluenceThresholdSum = 0.f,
      densityInfluenceConstantSum = 0.f,
      activeProportionSum = 0.f,
      activationSensitivitySum = 0.f,
      decayRateReturnSum = 0.f;

      for(int i = 0; i < colonyCount; i++) {
        ABSSimulationColony* c = [colonies objectAtIndex:i];
        decayRateSum += [c decayRate];
        walkDropRateSum += [c walkDropRate];
        trailDropRateSum += [c trailDropRate];
        dirDevConstSum += [c dirDevConst];
        dirDevCoeff2Sum += [c dirDevCoeff2];
        dirTimePow2Sum += [c dirTimePow2];
        densityThresholdSum += [c densityThreshold];
        densityConstantSum += [c densityConstant];
        densityPatchThresholdSum += [c densityPatchThreshold];
        densityPatchConstantSum += [c densityPatchConstant];
        densityInfluenceThresholdSum += [c densityInfluenceThreshold];
        densityInfluenceConstantSum += [c densityInfluenceConstant];
        activeProportionSum += [c activeProportion];
        activationSensitivitySum += [c activationSensitivity];
        decayRateReturnSum += [c decayRateReturn];
        
        [c setDecayRate:new_colonies[i].decayRate];
        [c setWalkDropRate:new_colonies[i].walkDropRate];
        [c setSearchGiveupRate:new_colonies[i].searchGiveupRate];
        [c setTrailDropRate:new_colonies[i].trailDropRate];
        [c setDirDevConst:new_colonies[i].dirDevConst];
        [c setDirDevCoeff1:new_colonies[i].dirDevCoeff1];
        [c setDirTimePow1:new_colonies[i].dirTimePow1];
        [c setDirDevCoeff2:new_colonies[i].dirDevCoeff2];
        [c setDirTimePow2:new_colonies[i].dirTimePow2];
        [c setDensitySensitivity:new_colonies[i].densitySensitivity];
        [c setDensityThreshold:new_colonies[i].densityThreshold];
        [c setDensityConstant:new_colonies[i].densityConstant];
        [c setDensityPatchThreshold:new_colonies[i].densityPatchThreshold];
        [c setDensityPatchConstant:new_colonies[i].densityPatchConstant];
        [c setDensityInfluenceThreshold:new_colonies[i].densityInfluenceThreshold];
        [c setDensityInfluenceConstant:new_colonies[i].densityInfluenceConstant];
        [c setActiveProportion:new_colonies[i].activeProportion];
        [c setActivationSensitivity:new_colonies[i].activationSensitivity];
        [c setDecayRateReturn:new_colonies[i].decayRateReturn];
        [c setSeedsCollected:0];
        
        new_colonies[i].decayRate = 0;
        new_colonies[i].dirDevConst = 0;
      }
      
      bestColony.decayRate = decayRateSum/colonyCount;
      bestColony.walkDropRate = walkDropRateSum/colonyCount;
      bestColony.trailDropRate = trailDropRateSum/colonyCount;
      bestColony.dirDevConst = dirDevConstSum/colonyCount;
      bestColony.dirDevCoeff2 = dirDevCoeff2Sum/colonyCount;
      bestColony.dirTimePow2 = dirTimePow2Sum/colonyCount;
      bestColony.densityThreshold = densityThresholdSum/colonyCount;
      bestColony.densityConstant = densityConstantSum/colonyCount;
      bestColony.densityPatchThreshold = densityPatchThresholdSum/colonyCount;
      bestColony.densityPatchConstant = densityPatchConstantSum/colonyCount;
      bestColony.densityInfluenceThreshold = densityInfluenceThresholdSum/colonyCount;
      bestColony.densityInfluenceConstant = densityInfluenceConstantSum/colonyCount;
      bestColony.activeProportion = activeProportionSum/colonyCount;
      bestColony.activationSensitivity = activationSensitivitySum/colonyCount;
      bestColony.decayRateReturn = decayRateReturnSum/colonyCount;
    }
  }
  
  return 0;
}

-(void) run {
  updateCount++;
  
  //decay return_pheromone
  return_pheromone *= (1 - [[colonies objectAtIndex:col_count] decayRateReturn]);
  
  //Update ants
  for(int ant_count = 0; ant_count < antCount; ant_count++)
  {
    ABSSimulationAnt* ant = [ants objectAtIndex:ant_count];
    if([ant antStatus] != 0) {
      [[colonies objectAtIndex:col_count] setAntTimeOut:[[colonies objectAtIndex:col_count] antTimeOut]+1];
    }
    
    //Update pheromones
    if([ant penDown] == true) {
      grid[[ant x]][[ant y]].p2 =
      grid[[ant x]][[ant y]].p2 + deposit_rate_p2;
      grid[[ant x]][[ant y]].p2_time_updated = updateCount;
    }
    //Searching ants pick up food
    if([ant rfidX] >= 0 && [ant rfidX] < grid_width
        && [ant rfidY] >= 0
        && [ant rfidY] < grid_height)
    {
      if(([ant antStatus] == 3)
          && grid[[ant rfidX]][[ant rfidY]].food > 0)
      {
        grid[[ant x]][[ant y]].ant_status = 2;
        [ant setAntStatus:2];
        [ant setPrevX:-1];
        [ant setPrevY:-1];
        [ant setSearchTime:-1];
        [ant setSinceMove:0];
        [ant setCarrying:grid[[ant rfidX]][[ant rfidY]].food];
        grid[[ant rfidX]][[ant rfidY]].food = 0;
        grid[[ant rfidX]][[ant rfidY]].ant_status = 0;
        [ant setRfidX:-1];
        [ant setRfidY:-1];
        
        int density_count = 0;
        //Scan for seeds in the neighborhood
        for(int k = -smell_range; k <= smell_range; k++)
        {
          if([ant x] + k < 0
              || [ant x] + k >= grid_width)
            continue;
          for(int l = -smell_range; l <= smell_range; l++)
          {
            if([ant y] + l < 0
                || [ant y] + l >= grid_height)
            {
              continue;
            }
            if(grid[[ant x] + k][[ant y] + l].
                food > 0)
            {
              density_count++;
            }
          }
        }
        
        //Log all seed collections to a file.
        @autoreleasepool {
          [writer writeString:[NSString stringWithFormat:@"%@,%d,%d,%d,%d\n",simulationTag,updateCount,[ant x],[ant y],density_count] toFile:filename];
        }
        //End logging.
        
        if(arc4random () % 100 / 100.0f <=
            (density_count / [[colonies objectAtIndex:col_count] densityThreshold] +
             [[colonies objectAtIndex:col_count] densityConstant]))
        {		//Lay a trail
          [ant setPenDown:YES];
          grid[[ant x]][[ant y]].p1 += 20;
        }
        if(arc4random () % 100 / 100.0f >=
            (density_count /
             [[colonies objectAtIndex:col_count] densityInfluenceThreshold] +
             [[colonies objectAtIndex:col_count] densityInfluenceConstant]))
        {		//Will follow pheromone trails from the nest if any exist
          [ant setInfluenceable:YES];
        }
        if(arc4random () % 100 / 100.0f <= (density_count / [[colonies objectAtIndex:col_count] densityPatchThreshold] + [[colonies objectAtIndex:col_count] densityPatchConstant])) {		//Return to the patch if not following a trail
          [ant setReturnX:[ant x]];
          [ant setReturnY:[ant y]];
        }
        else { //Just go back to nest and pick a random direction to walk if not following a trail
          [ant setReturnX:-1];
          [ant setReturnY:-1];
        }
        
        /* SIMPLIFIED DECISION TREE -- non-GA-selected
         if((usesPheromones == true) && (density_count >= 2))
         {  //Lay a trail
         [ant penDown] = true;
         grid[ants[ant_count].x][[ant y]].p1 += 20;
         }
         if((usesPheromones == true) && (density_count < 2))
         {  //Will follow pheromone trails from the nest if any exist
         [ant influenceable] = true;
         }
         if((patch == true) && (density_count >= 0)) //bots always return to patch if not following a trail!
         {  //Return to the patch
         [ant returnX] = ants[ant_count].x;
         [ant returnY] = [ant y];
         }
         else { //Just go back to nest and pick a random direction to walk, or follow a trail if any exist
         [ant returnX] = [ant returnY] = -1;
         }
         */
        
      }
    }
    //Arrive at nest
    if([ant antStatus] == 2
        && grid[[ant x]][[ant y]].nest == true)
    {
      [ant setPrevX:-1];
      [ant setPrevY:-1];
      if([ant carrying] > 0)
      {
        [[colonies objectAtIndex:col_count] setSeedsCollected:[[colonies objectAtIndex:col_count] seedsCollected]+1];
        
        //Activate ants in the nest proportional to return_pheromone at nest entrance
        //Pheromone trails present around nest?
        float sum_pheromone = 0.0f;
        for(int k = -1; k <= 1; k++)
        {
          int i_k = [ant x] + k;
          if(i_k < 0 || i_k >= grid_width)
            continue;
          for(int l = -1; l <= 1; l++)
          {
            //Skip ourselves
            if(l == 0 && k == 0)
              continue;
            int j_l = [ant y] + l;
            if(j_l < 0 || j_l >= grid_height)
              continue;
            if(sqrt
                (pow ([ant x] - nestx, 2) +
                 pow ([ant y] - nesty,
                      2)) - sqrt (pow (i_k - nestx,
                                       2) + pow (j_l - nesty,
                                                 2)) <= 0)
            {
              //Sum pheromones within 1 square of nest -- adjust pheromone strength as the square of distance from current location
              sum_pheromone +=
              grid[i_k][j_l].p2 /
              pow (sqrt
                   (pow ([ant x] - i_k, 2) +
                    pow ([ant y] - j_l, 2)), 2);
            }
          }
        }
        //but only if arriving ant is usesPheromonesing
        if([ant penDown] == true)
        {
          return_pheromone += 1;
          for(int n = 0; n < antCount; n++)
          {
            ABSSimulationAnt* ant2 =  [ants objectAtIndex:n];
            if(([ant2 antStatus] == 0)
                && (arc4random () % (1000) / (1000.0f) <
                    (return_pheromone *
                     [[colonies objectAtIndex:col_count] activationSensitivity]) /
                    (antCount)))
            {
              if(sum_pheromone > 0.0)
              {
                grid[[ant2 x]][[ant2 y]].ant_status = 1;
                [ant2 setAntStatus:1];	//Ant in nest sets out to follow a pheromone trail
              }
              else
              {
                grid[[ant2 x]][[ant2 y]].ant_status = 4;
                [ant2 setAntStatus:4];
                [ant2 setDirection:(arc4random () % 360)];
              }
            }
          }
        }
        
      }
      if([ant carrying] > 0)
      {
        switch ([ant carrying])
        {
          case 1:
            count_food_red++;
            break;
          case 2:
            count_food_orange++;
            break;
          case 3:
            count_food_green++;
            break;
          case 4:
            count_food_blue++;
            break;
        }
        
      }
      
      //Pheromone trails present around nest?
      float sum_pheromone = 0.0f;
      for(int k = -1; k <= 1; k++)
      {
        int i_k = [ant x] + k;
        if(i_k < 0 || i_k >= grid_width)
          continue;
        for(int l = -1; l <= 1; l++)
        {
          //Skip ourselves
          if(l == 0 && k == 0)
            continue;
          int j_l = [ant y] + l;
          if(j_l < 0 || j_l >= grid_height)
            continue;
          if(sqrt
              (pow ([ant x] - nestx, 2) +
               pow ([ant y] - nesty,
                    2)) - sqrt (pow (i_k - nestx,
                                     2) + pow (j_l - nesty, 2)) <= 0)
          {
            //Sum pheromones within 1 square of nest -- adjust pheromone strength as the square of distance from current location
            sum_pheromone +=
            grid[i_k][j_l].p2 /
            pow (sqrt
                 (pow ([ant x] - i_k, 2) +
                  pow ([ant y] - j_l, 2)), 2);
          }
        }
      }
      
      grid[[ant x]][[ant y]].ant_status = 1;
      [ant setAntStatus:1];
      
      if((sum_pheromone > 0) & ([ant influenceable] == true))
      {
        //Ant will follow a trail leading from nest
        grid[[ant x]][[ant y]].ant_status = 1;
        [ant setAntStatus:1];
      }
      else if(([ant returnX] != -1) &
               ([ant returnY] != -1))
      {
        //Ant will return to patch
        grid[[ant x]][[ant y]].ant_status = 5;
        [ant setAntStatus:5];
      }
      else
      {
        //Ants choose a direction to start walking
        grid[[ant x]][[ant y]].ant_status = 4;
        [ant setAntStatus:4];
        [ant setDirection:arc4random () % 360];
      }
      
      [ant setPenDown:false];
      [ant setInfluenceable:false];
      [ant setCarrying:0];
    }
    //Move ants
    //Ants following a trail
    if([ant antStatus] == 1)
    {
      bool move_accepted = false;
      //int reason = 0;
      //Follow trail if one exists
      //Find the out-bound cell with greatest pheromone and sum of pheromone weight on all such cells
      float back_pheromone = 0.0f;
      float sum_pheromone = 0.0f;
      float most_pheromone = 0.0f;
      for(int k = -1; k <= 1; k++)
      {
        int i_k = [ant x] + k;
        if(i_k < 0 || i_k >= grid_width)
          continue;
        
        for(int l = -1; l <= 1; l++)
        {
          //Skip ourselves
          if(l == 0 && k == 0)
            continue;
          int j_l = [ant y] + l;
          if(j_l < 0 || j_l >= grid_height)
            continue;
          
          if(sqrt
              (pow ([ant x] - nestx, 2) +
               pow ([ant y] - nesty,
                    2)) - sqrt (pow (i_k - nestx,
                                     2) + pow (j_l - nesty, 2)) <= 0)
          {
            
            if(grid[i_k][j_l].p2 > 0)
            {
              grid[i_k][j_l].p2 *=
              pow ((1 - [[colonies objectAtIndex:col_count] decayRate]),
                   (updateCount -
                    grid[i_k][j_l].p2_time_updated));
              grid[i_k][j_l].p2_time_updated = updateCount;
              
              if(grid[i_k][j_l].p2 < 0.001f)
              {
                grid[i_k][j_l].p2 = 0;
              }
            }
            
            //Sum pheromones within smell_range squares away from nest -- adjust pheromone strength as the square of distance from current location
            sum_pheromone += grid[i_k][j_l].p2;
            //Get highest pheromone on any adjacent out-bound square
            if(grid[i_k][j_l].p2 > most_pheromone
                && grid[i_k][j_l].p2 > 0.0f)
            {
              most_pheromone = grid[i_k][j_l].p2;
            }
          }
          else
          {
            //Sum pheromones within smell_range squares in direction of nest -- adjust pheromone strength as the square of distance from current location
            back_pheromone +=
            grid[i_k][j_l].p2 /
            pow (sqrt
                 (pow ([ant x] - i_k, 2) +
                  pow ([ant y] - j_l, 2)), 2);
          }
          
        }
      }
      
      
      //Drop off trail probabilistically in proportion to the degree of trail weakening in outbound moves as compared to backward moves
      //...but only if the ant isn't in the nest or within smelling range of it!
      //...and only if the ant is in a spot where a trail ends (i.e. p1 > 0.0)
      if((arc4random () % 1000 / 1000.0f >
           sum_pheromone /
           back_pheromone) & (sqrt (pow ([ant x] - nestx, 2) +
                                    pow ([ant y] - nesty,
                                         2)) > sqrt (2 * pow (smell_range,
                                                              2))) &
          (grid[[ant x]][[ant y]].p1 > 0.0))
      {
        //Traveling ant drops off the pheromone trail and begins searching
        grid[[ant x]][[ant y]].ant_status = 3;
        [ant setAntStatus:3];
        [ant setSearchTime:0];
        //reason = 1;
      }
      
      //Drop off the trail if no more pheromone on out-bound cells (trail has evaporated)
      else if(sum_pheromone <= 0.0f)
      {
        grid[[ant x]][[ant y]].ant_status = 3;
        [ant setAntStatus:3];
        [ant setSearchTime:-1];
        //reason = 2;
      }
      
      //ants have a small probability of dropping off the trail each time step
      else if(arc4random () % 10000 / 10000.0f <
               [[colonies objectAtIndex:col_count] trailDropRate])
      {
        //Traveling ant drops off the pheromone trail and begins searching
        grid[[ant x]][[ant y]].ant_status = 3;
        [ant setAntStatus:3];
        [ant setPrevX:-1];
        [ant setPrevY:-1];
        [ant setSearchTime:-1];
        //reason = 3;
      }
      
      else
      {
        //Random, accept a move with probability proportional to the ratio of the
        //pheromone on the square to be moved to and the adjacent square with the
        //highest amount of pheromone
        int new_x = -1, new_y = -1;
        while(!move_accepted)
        {
          
          new_x = [ant x] + arc4random () % 3 - 1;
          new_y = [ant y] + arc4random () % 3 - 1;
          if((new_x < 0) || (new_x >= grid_width) || (new_y < 0)
              || (new_y >= grid_height))
            continue;
          //Disregard possible moves that take out-bound ant closer to nest
          if(sqrt
              (pow ([ant x] - nestx, 2) +
               pow ([ant y] - nesty,
                    2)) - sqrt (pow (new_x - nestx,
                                     2) + pow (new_y - nesty, 2)) > 0)
            continue;
          if((most_pheromone <= 0.0f)
              || (arc4random () % 100 / 100.0f <
                  grid[new_x][new_y].p2 / most_pheromone))
          {
            move_accepted = true;
          }
        }
        
        grid[[ant x]][[ant y]].ant_status = 0;
        [ant setX:new_x];
        [ant setY:new_y];
        grid[new_x][new_y].ant_status = [ant antStatus];
        [ant setPreviousPheromoneScent:sum_pheromone];
      }
    }
    
    //Ants returning to last successful patch
    if([ant antStatus] == 5)
    {
      if(([ant returnX] == -1
           && [ant returnY] == -1)
          || ([ant x] == [ant returnX]
              && [ant y] == [ant returnY]))
      {
        [ant setAntStatus:3];
        [ant setSearchTime:0];
        [ant setSearchDirection:arc4random () % 360 - 180];
        int newdx = round (cos ([ant searchDirection]));
        int newdy = round (sin ([ant searchDirection]));
        if([ant x] + newdx >= 0
            && [ant x] + newdx < grid_width
            && [ant y] + newdy >= 0
            && [ant y] + newdy < grid_height)
        {
          [ant setRfidX:[ant x] + newdx];	//place rfid/qr reader in front of ant
          [ant setRfidY:[ant y] + newdy];
          grid[[ant rfidX]][[ant rfidY]].
          ant_status = 9;
        }
      }
      else
      {
        
        //Find the adjacent square that decreases euclidean distance to patch the most
        float most_distance = 0.0f;
        for(int k = -1; k < 2; k++)
        {
          int i_k = [ant x] + k;
          if(i_k < 0 || i_k >= grid_width)
            continue;
          
          for(int l = -1; l < 2; l++)
          {
            //Skip ourselves
            if(l == 0 && k == 0)
              continue;
            int j_l = [ant y] + l;
            if(j_l < 0 || j_l >= grid_height)
              continue;
            
            //Distance
            if(sqrt
                (pow
                 ([ant x] - [ant returnX],
                  2) + pow ([ant y] -
                            [ant returnY],
                            2)) - sqrt (pow (i_k -
                                             [ant returnX],
                                             2) + pow (j_l -
                                                       [ant returnY],
                                                       2)) >
                most_distance)
            {
              most_distance =
              sqrt (pow
                    ([ant x] -
                     [ant returnX],
                     2) + pow ([ant y] -
                               [ant returnY],
                               2)) - sqrt (pow (i_k -
                                                [ant returnX],
                                                2) + pow (j_l -
                                                          [ant returnY],
                                                          2));
              //
            }
          }
        }
        //Random, accept a move with probability proportional to the ratio of the
        //distance of the square to be moved to and the adjacent square with the
        //greatest decrease in distance from the patch
        int new_x = -1, new_y = -1;
        bool move_accepted = false;
        while(!move_accepted)
        {
          new_x = [ant x] + arc4random () % 3 - 1;
          new_y = [ant y] + arc4random () % 3 - 1;
          if((most_distance <= 0.0f)
              || arc4random () % 100 / 100.0f <
              (sqrt
               (pow ([ant x] - [ant returnX], 2)
                + pow ([ant y] - [ant returnY],
                       2)) - sqrt (pow (new_x -
                                        [ant returnX],
                                        2) + pow (new_y -
                                                  [ant returnY],
                                                  2))) /
              most_distance)
          {
            move_accepted = true;
          }
        }
        if(new_x < 0 || new_x >= grid_width || new_y < 0
            || new_y >= grid_height)
          continue;
        grid[[ant x]][[ant y]].ant_status = 0;
        grid[new_x][new_y].ant_status = [ant antStatus];
        [ant setX:new_x];
        [ant setY:new_y];
      }
      
    }
    
    //Traveling ants, out-bound from nest but not following a trail
    if([ant antStatus] == 4)
    {
      if((arc4random () % 10000 / 10000.0f <
           [[colonies objectAtIndex:col_count] walkDropRate]))
      {
        [ant setAntStatus:3];
        [ant setSearchTime:-1];
        [ant setSearchDirection:360.0];
        int newdx = round (cos ([ant searchDirection]));
        int newdy = round (sin ([ant searchDirection]));
        if([ant x] + newdx >= 0
            && [ant x] + newdx < grid_width
            && [ant y] + newdy >= 0
            && [ant y] + newdy < grid_height)
        {
          [ant setRfidX:[ant x] + newdx];	//place rfid reader behind ant
          [ant setRfidY:[ant y] + newdy];
          grid[[ant rfidX]][[ant rfidY]].ant_status = 9;
        }
        continue;
      }
      float idealx;		//Optimal X and Y move given the ant's chosen direction
      float idealy;		//Move may not be possible (i.e., not on the grid) but the ant will try to get as close as possible
      if(fabs (sin ([ant direction] * pi / 180)) >
          fabs (cos ([ant direction] * pi / 180)))
      {
        idealx =
        [ant x] +
        50 * (cos ([ant direction] * pi / 180) /
              fabs (sin ([ant direction] * pi / 180)));
        idealy =
        [ant y] +
        50 * (sin ([ant direction] * pi / 180) /
              fabs (sin ([ant direction] * pi / 180)));
      }
      else
      {
        idealx =
        [ant x] +
        50 * (cos ([ant direction] * pi / 180) /
              fabs (cos ([ant direction] * pi / 180)));
        idealy =
        [ant y] +
        50 * (sin ([ant direction] * pi / 180) /
              fabs (cos ([ant direction] * pi / 180)));
      }
      
      
      //Find the move that would decrease distance to the ideal move the most
      float most_distance = 0.0f;
      for(int k = -1; k < 2; k++)
      {
        int i_k = [ant x] + k;
        if(i_k < 0 || i_k >= grid_width)
          continue;
        
        for(int l = -1; l < 2; l++)
        {
          //Skip ourselves
          if(l == 0 && k == 0)
            continue;
          int j_l = [ant y] + l;
          if(j_l < 0 || j_l >= grid_height)
            continue;
          
          //Distance
          if(sqrt
              (pow ([ant x] - idealx, 2) +
               pow ([ant y] - idealy,
                    2)) - sqrt (pow (i_k - idealx,
                                     2) + pow (j_l - idealy,
                                               2)) > most_distance)
          {
            most_distance =
            sqrt (pow ([ant x] - idealx, 2) +
                  pow ([ant y] - idealy,
                       2)) - sqrt (pow (i_k - idealx,
                                        2) + pow (j_l - idealy,
                                                  2));
            
          }
        }
      }
      //Random, accept a move with probability proportional to the ratio of the
      //distance of the square to be moved to and the adjacent square with the
      //greatest decrease in distance from the ideal move
      int new_x = -1, new_y = -1;
      bool move_accepted = false;
      while(!move_accepted)
      {
        new_x = [ant x] + arc4random () % 3 - 1;
        new_y = [ant y] + arc4random () % 3 - 1;
        //Skip ourselves
        if((new_x == [ant x]) & (new_y == [ant y]))
          continue;
        if((most_distance <= 0.0f)
            || arc4random () % 100 / 100.0f <
            (sqrt
             (pow ([ant x] - idealx, 2) +
              pow ([ant y] - idealy,
                   2)) - sqrt (pow (new_x - idealx,
                                    2) + pow (new_y - idealy,
                                              2))) / most_distance)
        {
          move_accepted = true;
        }
      }
      if(new_x < 0 || new_x >= grid_width || new_y < 0
          || new_y >= grid_height)
      {
        [ant setAntStatus:3];
        [ant setSearchTime:-1];
        continue;
      }
      
      grid[[ant x]][[ant y]].ant_status = 0;
      grid[new_x][new_y].ant_status = [ant antStatus];
      [ant setX:new_x];
      [ant setY:new_y];
      
      
    }
    
    //Searching ants
    if([ant antStatus] == 3)
    {
      if([ant sinceMove] < search_delay)
        [ant setSinceMove:[ant sinceMove]+1];
      else
      {
        //Searching ants smell food in adjacent squares.  If an ant smells food in an adjacent square
        //where no other ant is present (the food is available for pickup) the ant will move to one of
        //these squares; otherwise selects a square at random.
        
        //CODE FOR ALLOWING SEARCHING ANTS TO SMELL AND MOVE TO FOOD IN ADJACENT SQUARES -- off for the AntBots
        int food_count = 0;
        /*		      for( int k = -1; k < 2; k++ )
         {
         for( int l = -1; l < 2; l++ )
         {
         if( [ant x]+k < grid_width && [ant x]+k >= 0 && [ant y]+l < grid_height && [ant y]+l >= 0 )
         {
         if( grid[[ant x]+k][[ant y]+l].food > 0 & grid[[ant x]+k][[ant y]+l].ant_status == 0 ) food_count++;
         }
         }
         }*/ 
        int new_x = -1, new_y = -1;
        int search_loop = 0;
        bool found_a_seed = false;
        bool move_accepted = false;
        float new_direction;
        while(!move_accepted && [ant antStatus] == 3)
        {
          search_loop++;
          if((([ant searchDirection] == 360.0))
              || ([ant x] == 0) || ([ant y] == 0)
              || ([ant x] == grid_width - 1)
              || ([ant y] == grid_height - 1)
              || (food_count > 0))
          {
            [ant setSearchDirection:(arc4random () % 360) - 180];
          }
          
          float d_theta;
          if([ant searchTime] >= 0.0)
          {
            d_theta =
            randomFloat(
                        (([[colonies objectAtIndex:col_count] dirDevCoeff1] *
                          pow ([ant searchTime],
                               [[colonies objectAtIndex:col_count]
                               dirTimePow1])) +
                         ([[colonies objectAtIndex:col_count] dirDevCoeff2] /
                          pow ([ant searchTime],
                               [[colonies objectAtIndex:col_count]
                               dirTimePow2])) +
                         [[colonies objectAtIndex:col_count] dirDevConst]));
          }
          else
            d_theta =
            randomFloat([[colonies objectAtIndex:col_count] dirDevConst]);
          if(updateCount % 3 == 0)
          {		//ants pick a new direction only every 30 cm, like the antbots.
            new_direction =
            [ant searchDirection] + d_theta;
            if([ant searchTime] >= 0.0)
              [ant setSearchTime:[ant searchTime]+1];
          }
          else
          {
            new_direction = [ant searchDirection];
          }
          int newdx = round (cos (new_direction));
          int newdy = round (sin (new_direction));
          new_x = [ant x] + newdx;
          new_y = [ant y] + newdy;
          
          if((new_x < 0) || (new_x >= grid_width) || (new_y < 0)
              || (new_y >= grid_height))
            continue;
          if((new_x == [ant x]) & (new_y ==
                                              [ant y]))
            continue;
          //CODE FOR MOVING TO FOOD IN ADJACENT SQUARE
          if(food_count > 0)
          {
            
            if(grid[new_x][new_y].food > 0
                && grid[new_x][new_y].ant_status == 0)
            {
              move_accepted = true;
            }
            else
              continue;
          }
          else
            if(arc4random () % 10000 / 10000.0f <
                [[colonies objectAtIndex:col_count] searchGiveupRate])
            {
              //Ants that do not smell food probabilistically give up searching and begin to return to the nest
              [ant setPrevX:-1];
              [ant setPrevY:-1];
              [ant setSearchDirection:360.0];
              [ant setAntStatus:2];
              if([ant rfidX] >= 0
                  && [ant rfidX] < grid_width
                  && [ant rfidY] >= 0
                  && [ant rfidY] < grid_height)
              {
                grid[[ant rfidX]][[ant rfidY]].
                ant_status = 0;
              }
              [ant setRfidX:-1];
              [ant setRfidY:-1];
              //Will pick a random spot to search if no pheromone trails at nest.
              [ant setAntStatus:4];
              //Will follow pheromone trails from the nest if any exist
              [ant setInfluenceable:true];
              continue;
            }
            else
            {
              move_accepted = true;
            }
          
        }
        if([ant antStatus] == 3)
        {
          //ant turns in the direction it intends to travel, RFID/QR reader rotates in front of it
          float rfid_direction = [ant searchDirection];
          int newdx = round (cos (rfid_direction));
          int newdy = round (sin (rfid_direction));
          if([ant x] + newdx >= 0
              && [ant x] + newdx < grid_width
              && [ant y] + newdy >= 0
              && [ant y] + newdy < grid_height)
          {
            if([ant rfidX] >= 0
                && [ant rfidX] < grid_width
                && [ant rfidY] >= 0
                && [ant rfidY] < grid_height)
            {
              grid[[ant rfidX]][[ant rfidY]].
              ant_status = 0;
            }
            [ant setRfidX:[ant x] + newdx];	//place rfid reader behind ant
            [ant setRfidY:[ant y] + newdy];
            if(grid[[ant rfidX]][[ant rfidY]].
                food > 0)
            {
              found_a_seed = true;
            }
          }
          
          //if the RFID reader has not passed over a seed then move the ant to its new location.
          if(found_a_seed == false)
          {
            sumdx += new_x - [ant x];
            sumdy += new_y - [ant y];
            grid[[ant x]][[ant y]].ant_status =
            0;
            if([ant rfidX] >= 0
                && [ant rfidX] < grid_width
                && [ant rfidY] >= 0
                && [ant rfidY] < grid_height)
            {
              grid[[ant rfidX]][[ant rfidY]].
              ant_status = 0;
            }
            [ant setX:new_x];
            [ant setY:new_y];
            [ant setSearchDirection:new_direction];
            
            [ant setRfidX:[ant x] + newdx];	//place rfid reader in front of ant again
            [ant setRfidY:[ant y] + newdy];
            if([ant rfidX] >= 0
                && [ant rfidX] < grid_width
                && [ant rfidY] >= 0
                && [ant rfidY] < grid_height)
            {
              grid[[ant rfidX]][[ant rfidY]].
              ant_status = 9;
            }
            grid[new_x][new_y].ant_status = [ant antStatus];
            
            [ant setSinceMove:0];
          }
        }
      }
    }
    //Return to the nest
    else if([ant antStatus] == 2)
    {
      //Find the adjacent square that decreases euclidean distance to nest the most
      if(([ant carrying] != 0)
          && ([ant sinceMove] < return_delay))
      {
        [ant setSinceMove:[ant sinceMove]+1];
      }
      else
      {
        
        float most_distance = 0.0f;
        for(int k = -1; k < 2; k++)
        {
          int i_k = [ant x] + k;
          if(i_k < 0 || i_k >= grid_width)
            continue;
          
          for(int l = -1; l < 2; l++)
          {
            //Skip ourselves
            if(l == 0 && k == 0)
              continue;
            int j_l = [ant y] + l;
            if(j_l < 0 || j_l >= grid_height)
              continue;
            
            //Distance
            if(sqrt
                (pow ([ant x] - nestx, 2) +
                 pow ([ant y] - nesty,
                      2)) - sqrt (pow (i_k - nestx,
                                       2) + pow (j_l - nesty,
                                                 2)) >
                most_distance)
            {
              most_distance =
              sqrt (pow ([ant x] - nestx, 2) +
                    pow ([ant y] - nesty,
                         2)) - sqrt (pow (i_k - nestx,
                                          2) + pow (j_l - nesty,
                                                    2));
              //
            }
          }
        }
        //Random, accept a move with probability proportional to the ratio of the
        //distance of the square to be moved to and the adjacent square with the
        //greatest decrease in distance from the nest
        int new_x = -1, new_y = -1;
        bool move_accepted = false;
        while(!move_accepted)
        {
          //cout << "...moving?" << endl;
          new_x = [ant x] + arc4random () % 3 - 1;
          new_y = [ant y] + arc4random () % 3 - 1;
          if(new_x < 0 || new_x >= grid_width || new_y < 0
              || new_y >= grid_height)
            continue;
          if((most_distance <= 0.0f)
              || arc4random () % 100 / 100.0f <
              (sqrt
               (pow ([ant x] - nestx, 2) +
                pow ([ant y] - nesty,
                     2)) - sqrt (pow (new_x - nestx,
                                      2) + pow (new_y - nesty,
                                                2))) / most_distance)
          {
            move_accepted = true;
          }
        }
        grid[[ant x]][[ant y]].ant_status = 0;
        grid[new_x][new_y].ant_status = [ant antStatus];
        [ant setX:new_x];
        [ant setY:new_y];
        
        [ant setSinceMove:0];
      }
    }
  }
}

-(void) stopSimulation {
  [[NSThread currentThread] cancel];
}

-(void) initColonies {
  for(int i = 0; i < colonyCount; i++) {
    [colonies addObject:[[ABSSimulationColony alloc] init]];
    ABSSimulationColony* c = [colonies objectAtIndex:i];
    
    [c setDecayRate:arc4random () % 20000 / 1000000.0f];
    [c setWalkDropRate:arc4random () % 20000 / 1000000.0f];
    [c setSearchGiveupRate:arc4random () % 10000 / 1000000.0f];
    [c setTrailDropRate:arc4random () % 20000 / 1000000.0f];
    [c setDirDevConst:arc4random () % 314 / 100.0f];
    [c setDirDevCoeff2:arc4random () % 314 / 100.0f];
    [c setDirTimePow2:arc4random () % 200 / 1000.0f];
    
    if(usesPheromones) {
      [c setDensityThreshold:arc4random () % 80 / 10.0f];
      [c setDensityConstant:arc4random () % 200 / 100.0f - 1];
    }
    else {
      [c setDensityThreshold:1.0];
      [c setDensityConstant:-9.0];
    }
    
    if(usesSiteFidelity) {
      [c setDensityPatchThreshold:arc4random () % 80 / 10.0f];
      [c setDensityPatchConstant:arc4random () % 200 / 100.0f - 1];
    }
    else {
      [c setDensityPatchThreshold:1.0];
      [c setDensityPatchConstant:-9.0];
    }
    
    [c setDensityInfluenceThreshold:arc4random () % 80 / 10.0f];
    [c setDensityInfluenceConstant:arc4random () % 200 / 100.0f - 1];
    [c setActivationSensitivity:arc4random () % 100 / 100.0f];
    [c setDecayRateReturn:arc4random () % 500 / 1000.0f];
    [c setActiveProportion:1.0];
    
    //Manual Override.
    
    [c setDecayRate:0.007859];
    [c setTrailDropRate:0.004721];
    [c setWalkDropRate:0.024760];
    [c setSearchGiveupRate:0.f];
    [c setDirDevConst:0.209427];
    [c setDirDevCoeff1:0.f];
    [c setDirTimePow1:0.f];
    [c setDirDevCoeff2:3.737541];
    [c setDirTimePow2:0.249095];
    [c setDensityThreshold:0.532423];
    [c setDensitySensitivity:0.000000];
    [c setDensityConstant:-0.474696];
    [c setDensityPatchThreshold:0.516473];
    [c setDensityPatchConstant:0.494699];
    [c setDensityInfluenceThreshold:0.321963];
    [c setDensityInfluenceConstant:-0.816648];
    [c setActiveProportion:1.000000];
    [c setDecayRateReturn:0.244337];
    [c setActivationSensitivity:0.076127];
  }
}

-(void) initDistribution {
  if(numberOfSeeds == 0){numberOfSeeds = 256;}
  n_food_blue = numberOfSeeds * distributionRandom;

  n_food_red = (numberOfSeeds / 4) * distributionPowerlaw;
  n_food_orange = (numberOfSeeds / 4) * distributionPowerlaw;
  n_food_green = (numberOfSeeds / 4) * distributionPowerlaw;
  n_food_blue += (numberOfSeeds / 4) * distributionPowerlaw;

  n_food_green += numberOfSeeds * distributionClustered;
  
  n_food_red = (int)roundf(n_food_red);
  n_food_orange = (int)roundf(n_food_orange);
  n_food_green = (int)roundf(n_food_green);
  n_food_blue = (int)roundf(n_food_blue);
}

@end