#import <Foundation/Foundation.h>

@class ABSSimulation;
@class ABSSimulationColony;

@interface NSObject(ABSSimulationControllerNotifications)
  -(void) didFinishSimulationWithTag:(NSString*)tag;
@end

@interface ABSSimulationController : NSObject {
  NSMutableDictionary* simulationThreads;
}

+(ABSSimulationController*) getInstance;

@property NSObject* delegate;
@property NSMutableDictionary* simulations;

-(void) addSimulationWithTag:(NSString*)tag;

-(ABSSimulation*) simulationWithTag:(NSString*)tag;

-(void) removeSimulationWithTag:(NSString*)tag;
-(void) removeAllSimulations;

-(ABSSimulationColony*) bestColonyForTag:(NSString*)tag;

-(void) startAll;

@end
