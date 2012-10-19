#import <Foundation/Foundation.h>

@interface ABSSimulationColony : NSObject {
  
}

@property float decayRate;
@property float trailDropRate;
@property float walkDropRate;
@property float searchGiveupRate;

@property float dirDevConst;
@property float dirDevCoeff1;
@property float dirTimePow1;
@property float dirDevCoeff2;
@property float dirTimePow2;

@property float densityThreshold;
@property float densitySensitivity;
@property float densityConstant;

@property float densityPatchThreshold;
@property float densityPatchConstant;

@property float densityInfluenceThreshold;
@property float densityInfluenceConstant;

@property float activeProportion;
@property float decayRateReturn;
@property float activationSensitivity;

@property float seedsCollected;
@property float antTimeOut;
@property float fitness;

@end