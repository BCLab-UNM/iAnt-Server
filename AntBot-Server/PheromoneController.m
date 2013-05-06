#import "PheromoneController.h"

//Implementation for the Pheromone class
@implementation Pheromone
@synthesize i, x, y, n, nMax, t;
@end

//Implementation for the actual PheromoneController
@implementation PheromoneController
@synthesize pheromoneDecayRate;
@synthesize delegate;

+(PheromoneController*) getInstance {
    static PheromoneController* instance;
    
    @synchronized(self) {
        if(!instance) {
            instance = [[PheromoneController alloc] init];
        }
        return instance;
    }
}

-(id) init {
    self = [super init];
    pheromoneList = [[NSMutableArray alloc] init];
    startTime = [NSDate date];
    return self;
}

-(void) dealloc {
    
}

-(double) currentTime {
    return [startTime timeIntervalSinceNow] * -1; //multiply by -1000 for milliseconds, -1000000 for microseconds, -1 for seconds, etc.
}

-(void) addPheromoneAtX:(NSNumber*)x andY:(NSNumber*)y forTag:(NSNumber*)tagId {
    [self addPheromoneAtX:x andY:y forTag:tagId withPheromoneStrength:[NSNumber numberWithDouble:1.0]];
}

-(void) addPheromoneAtX:(NSNumber*)x andY:(NSNumber*)y forTag:(NSNumber*)tagId withPheromoneStrength:(NSNumber*)n {
    Pheromone* pheromone = [[Pheromone alloc] init];
    [pheromone setI:tagId];
    [pheromone setX:x];
    [pheromone setY:y];
    [pheromone setN:n];
    [pheromone setNMax:n];
    [pheromone setT:[NSNumber numberWithDouble:[self currentTime]]]; //seconds since class was created.
    [pheromoneList addObject:pheromone];
    
    
    if([[self delegate] respondsToSelector:@selector(didPlacePheromoneAt:)]) {
        [[self delegate] didPlacePheromoneAt:NSMakePoint([x floatValue],[y floatValue])];
    }
}


-(void) decayPheromones {
    pheromoneSum = 0;
    double currentTime = [self currentTime]; //seconds since class was created.
    int i;
    for(i=0; i<[pheromoneList count]; i++) {
        Pheromone* pheromone = [pheromoneList objectAtIndex:i];
        double delta = currentTime - [[pheromone t] doubleValue];
        double newN = exponentialDecay([[pheromone n] floatValue], 4 * delta , pheromoneDecayRate);
        
        if(newN>=.001){
            [pheromone setN:[NSNumber numberWithDouble:newN]];
            [pheromone setT:[NSNumber numberWithDouble:currentTime]];
            pheromoneSum += [[pheromone n] doubleValue];
        }
        else {
            [pheromoneList removeObject:pheromone];
            i -= 1;
        }
    }
}

-(NSArray*) getPheromone {
    [self decayPheromones];
    double randomNumber = ((double) arc4random() / 0x100000000) * pheromoneSum; //random number [0..pheromoneSum]
    int i;
    for(i=0; i<[pheromoneList count]; i++) {
        Pheromone* pheromone = [pheromoneList objectAtIndex:i];
        if(randomNumber < [[pheromone n] doubleValue]){
            NSNumber* x = [pheromone x];
            NSNumber* y = [pheromone y];
            NSArray* position = [NSArray arrayWithObjects:x, y, nil];
            return position;
        }
        else {
            randomNumber -= [[pheromone n] doubleValue];
        }
    }
    return nil; //should never happen
}

-(NSArray*) getAllPheromones {
    [self decayPheromones];
    return [[NSArray alloc] initWithArray:pheromoneList];
}

-(void) clearPheromones {
    [pheromoneList removeAllObjects];
    [self decayPheromones];
}

@end
