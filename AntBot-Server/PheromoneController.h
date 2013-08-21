#import <Foundation/Foundation.h>

@interface PhysicalPheromone : NSObject { //Miniclass used as container for pheromone data
    NSNumber* i; //The QR tag index of the pheromone.
    NSNumber* x; //The x coordinate of the pheromone.
    NSNumber* y; //The y coordinate of the pheromone.
    NSNumber* n; //Current strength of the pheromone
    NSNumber* nMax; //Initial strength of the pheromone.
    NSNumber* t; //The time (in microseconds) at which the pheromone last decayed.
}

@property NSNumber* i;
@property NSNumber* x;
@property NSNumber* y;
@property NSNumber* n;
@property NSNumber* nMax;
@property NSNumber* t;

@end

@interface NSObject(ABSPheromoneControllerNotifications)
-(void) didPlacePheromoneAt:(NSPoint)position;
@end

@interface PheromoneController : NSObject {
    NSObject* delegate;
    NSMutableArray* pheromoneList;
    double pheromoneSum;
    NSDate* startTime;
	NSMutableDictionary* pendingPheromones;
	NSMutableDictionary* tagFound;
	float pheromoneDecayRate;
	float pheromoneLayingRate;
	NSString* evolvedParameters;
	int tagCount;
}

+(PheromoneController*) getInstance;

-(double) currentTime;
-(void) addPheromoneAtX:(NSNumber*)x andY:(NSNumber*)y forTag:(NSNumber*)tagId;
-(void) addPheromoneAtX:(NSNumber*)x andY:(NSNumber*)y forTag:(NSNumber*)tagId withPheromoneStrength:(NSNumber*)n;
-(void) decayPheromones;
-(NSArray*) getPheromone;
-(NSArray*) getAllPheromones;
-(void) clearPheromones;

@property (nonatomic,retain) NSObject* delegate;

@end
