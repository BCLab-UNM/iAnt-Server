#import "ABSSimulationLocation.h"

@implementation ABSSimulationLocation
@synthesize p1, p2, p1_time_updated, p2_time_updated;
@synthesize ant_status, carrying, food, nseeds, nest, pen_down;

-(id) init {
  if(self = [super init]) {
    p1 = 0;
    p2 = 0;
    p1_time_updated = 0;
    p2_time_updated = 0;
    
    ant_status = 0;
    carrying = 0;
    food = 0;
    nseeds = 0;
    nest = false;
    pen_down = false;
  }
  
  return self;
}

@end
