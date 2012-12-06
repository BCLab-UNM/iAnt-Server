#import "ABSSimulationColony.h"

@implementation ABSSimulationColony

@synthesize decayRate, trailDropRate, walkDropRate, searchGiveupRate;
@synthesize dirDevConst, dirDevCoeff, dirTimePow;
@synthesize densityThreshold, densityConstant;
@synthesize densityPatchThreshold, densityPatchConstant;
@synthesize densityInfluenceThreshold, densityInfluenceConstant;
@synthesize activeProportion, decayRateReturn, activationSensitivity;
@synthesize seedsCollected, antTimeOut;

-(id) init {
    if(self = [super init]) {
        decayRate = 0.0;
        trailDropRate = 0.0;
        walkDropRate = 0.0;
        searchGiveupRate = 0.0;

        dirDevConst = 1.0;
        dirDevCoeff = 0.0;
        dirTimePow = 0.0;

        densityThreshold = 0.0;
        densityConstant = 0.0;

        densityPatchThreshold = 0.0;
        densityPatchConstant = 0.0;

        densityInfluenceThreshold = 0.0;
        densityInfluenceConstant = 0.0;

        activeProportion = 0.0;
        decayRateReturn = 0.0;
        activationSensitivity = 0.0;

        seedsCollected = 0.0;
        antTimeOut = 0.0;
    }
  
  return self;
}

@end
