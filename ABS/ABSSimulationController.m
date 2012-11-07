#import "ABSSimulationController.h"
#import "ABSSimulation.h"

@implementation ABSSimulationController

@synthesize delegate;
@synthesize simulations;

+(ABSSimulationController*) getInstance {
  static ABSSimulationController* instance;
  
  @synchronized(self) {
    if(!instance) {
      instance = [[ABSSimulationController alloc] init];
    }
    return instance;
  }
}

-(id) init {
  if(self = [super init]){
    simulations = [[NSMutableDictionary alloc] init];
    simulationThreads = [[NSMutableDictionary alloc] init];
  }
  return self;
}

-(void) addSimulationWithTag:(NSString*)tag {
  [simulations setObject:[[ABSSimulation alloc] init] forKey:tag];
  //Leave the thread as nil for now.
  [[simulations objectForKey:tag] setSimulationTag:tag];
}

-(ABSSimulation*) simulationWithTag:(NSString*)tag {
  return [simulations objectForKey:tag];
}

-(void) removeSimulationWithTag:(NSString*)tag {
  [[simulations objectForKey:tag] stopSimulation];
  [simulations removeObjectForKey:tag];
  [simulationThreads removeObjectForKey:tag];
}

-(void) removeAllSimulations {
  for(NSString* tag in simulations) {
    [[simulations objectForKey:tag] stopSimulation];
  }
  [simulations removeAllObjects];
  [simulationThreads removeAllObjects];
}

-(ABSSimulationColony*) bestColonyForTag:(NSString*)tag {
  ABSSimulation* simulation = [simulations objectForKey:tag];
  return [simulation bestColony];
}

-(void) startAll {
  for(NSString* tag in simulations) {
    NSThread* thread = [[NSThread alloc] initWithTarget:self selector:@selector(simulationThreadMain) object:nil];
    [thread start];
    [simulationThreads setObject:thread forKey:tag];
    [self performSelector:@selector(runSimulationWithTag:) onThread:thread withObject:tag waitUntilDone:NO];
  }
}

-(void) runSimulationWithTag:(NSString*)tag {
  ABSSimulation* simulation = [simulations objectForKey:tag];
  [simulation startSimulation];
  [self performSelectorOnMainThread:@selector(finishSimulationWithTag:) withObject:tag waitUntilDone:NO];
}

-(void) finishSimulationWithTag:(NSString*)tag {
  if([delegate respondsToSelector:@selector(didFinishSimulationWithTag:)]) {
    [delegate didFinishSimulationWithTag:tag];
  }
}

-(void) simulationThreadMain {
  //Keep alives are put in so the thread doesn't immediately shut down (apparently we have to trick the run loop).
  [self performSelector:@selector(simulationKeepAlive) withObject:nil afterDelay:60];
  BOOL done = NO;
  
  while(!done) {
    SInt32 result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, YES);
    if ((result == kCFRunLoopRunStopped) || (result == kCFRunLoopRunFinished)){done = YES;}
  }
}

-(void) simulationKeepAlive {
  [self performSelector:@selector(simulationKeepAlive) withObject:nil afterDelay:60];
}

@end
