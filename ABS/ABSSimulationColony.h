#import <Foundation/Foundation.h>

@interface ABSSimulationColony : NSObject {}

@property float decayRate;
@property float trailDropRate;
@property float walkDropRate;
@property float searchGiveupRate;

@property float dirDevConst;
@property float dirDevCoeff;
@property float dirTimePow;

@property float densityThreshold;
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

@end