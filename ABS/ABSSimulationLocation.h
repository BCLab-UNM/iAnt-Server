#import <Foundation/Foundation.h>

@interface ABSSimulationLocation : NSObject

@property float p1;  // indicates the end of a trail
@property float p2;  // pheromone that ants follow
@property int p1_time_updated; // time X-marks-the-spot pheromone was updated at this location
@property int p2_time_updated; // time pheromones were updated at this location

@property int ant_status; // 0 = no ant, 1 = traveling ant, 2 = ant carrying food; 3 = searching ant
@property int carrying; // food type ant is carrying: 0 = no food; # = foot item of distribution #
@property int food; // 0 = no food; # = food item of distribution #
@property int nseeds; // number of seeds at this location
@property bool nest;
@property bool pen_down; // false = ant not laying a trail; true = ant laying a trail

@end
