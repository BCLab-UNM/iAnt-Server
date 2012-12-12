#import <Foundation/Foundation.h>

@interface Pheromone : NSObject { //Miniclass used as container for pheromone data
  NSNumber* i; //The QR tag index of the pheromone.
  NSNumber* x; //The x coordinate of the pheromone.
  NSNumber* y; //The y coordinate of the pheromone.
  NSNumber* n; //The strength of the pheromone [0..1]
  NSNumber* t; //The time (in microseconds) at which the pheromone last decayed.
}

@property NSNumber* i;
@property NSNumber* x;
@property NSNumber* y;
@property NSNumber* n;
@property NSNumber* t;

@end

@interface NSObject(ABSPheromoneControllerNotifications)
  -(void) didPlacePheromoneAt:(NSPoint)position;
@end

@interface ABSPheromoneController : NSObject {
  NSObject* delegate;
  NSMutableArray* pheromoneList;
  double pheromoneSum;
  NSDate* startTime;
}

+(ABSPheromoneController*) getInstance;

-(double) currentTime;
-(void) addPheromoneAtX:(NSNumber*)x andY:(NSNumber*)y forTag:(NSNumber*)tagId;
-(void) removePheromoneForTag:(NSNumber*)tagId;
-(NSArray*) getPheromoneForTag:(NSNumber*)tagId;
-(void) decayPheromones;
-(NSArray*) getPheromone;
-(NSArray*) getAllPheromones;
-(void) clearPheromones;

@property (nonatomic,retain) NSObject* delegate;

@end
