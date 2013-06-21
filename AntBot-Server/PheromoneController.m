#import "PheromoneController.h"
#import "Server.h"
#import "Settings.h"

//Implementation for the Pheromone class
@implementation PhysicalPheromone
@synthesize i, x, y, n, nMax, t;
@end

//Implementation for the actual PheromoneController
@implementation PheromoneController

@synthesize delegate;

+(PheromoneController*) getInstance {
    static PheromoneController* instance;
	if(!instance){instance = [[PheromoneController alloc] init];}
	return instance;
}

-(void) start {
	pheromoneList = [[NSMutableArray alloc] init];
	pendingPheromones = [[NSMutableDictionary alloc] init];
	tagFound = [[NSMutableDictionary alloc] init];
    startTime = [NSDate date];
	
    NSString* pheromoneInit = [NSString stringWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:@"/Desktop/pheromoneInit.txt"] encoding:NSUTF8StringEncoding error:nil];
    for(NSString* line in [pheromoneInit componentsSeparatedByString:@"\n"]) {
        NSArray* vals = [line componentsSeparatedByString:@","];
        NSNumber* i = [NSNumber numberWithInt:[[vals objectAtIndex:0] intValue]];
        NSNumber* x = [NSNumber numberWithInt:[[vals objectAtIndex:1] intValue]];
        NSNumber* y = [NSNumber numberWithInt:[[vals objectAtIndex:2] intValue]];
        [self addPheromoneAtX:x andY:y forTag:i];
    }
	
    for(int i = 0; i < [[Settings getInstance] tagCount]; i += 1) {
        [tagFound setObject:[NSNumber numberWithBool:NO] forKey:[NSNumber numberWithInt:i]];
    }
	
	NSString* parametersPath = [NSHomeDirectory() stringByAppendingString:@"/Desktop/parameters.csv"];
	evolvedParameters = [[NSString stringWithContentsOfFile:parametersPath encoding:NSUTF8StringEncoding error:nil]stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSArray* parameters = [evolvedParameters componentsSeparatedByString:@","];
    if([parameters count] == 9) {
        pheromoneDecayRate = [[parameters objectAtIndex:0] floatValue];
        pheromoneLayingRate = [[parameters objectAtIndex:6] floatValue];
        evolvedParameters = [NSString stringWithFormat:@"%@,%@", [[parameters subarrayWithRange:NSMakeRange(1, 5)] componentsJoinedByString:@","], [[parameters subarrayWithRange:NSMakeRange(7, 2)] componentsJoinedByString:@","]];
    }
}

-(void) message:(NSNotification*)notification {
	NSArray* data = [[notification userInfo] objectForKey:@"data"];
	Server* server = [notification object];
	NSString* robotName = [[[Settings getInstance] robotNames] objectForKey:[data objectAtIndex:0]];
	
	/*
     * If only MAC address and another string are present, second string is assumed to be a tag id.
     * We reply with either a 'new' if a new tag has been found or 'old' otherwise.
     */
	if([data count] == 2) {
        NSNumber* tagId = [NSNumber numberWithInt:[[data objectAtIndex:1] intValue]];
        NSString* reply = ([[tagFound objectForKey:tagId] boolValue]==YES) ? @"old" : @"new";
        //[self log:[NSString stringWithFormat:@"[CTR] Received tag query for tag %@.  Replied with %@",tagId,reply] withTag:LOG_TAG_EVENT];
		
		[server send:[NSString stringWithFormat:@"tag,%@\n", reply] toNamedConnection:[data objectAtIndex:0]];
        return;
    }
	
	/*
	 * Perform event logic (tag, home)
	 */
	NSString* event = @"";
	if([data count] >= 5){event = [data objectAtIndex:4];}
	
	if([event isEqualToString:@"tag"]) {
		NSNumber* x = [NSNumber numberWithInt:[[data objectAtIndex:2] intValue]];
		NSNumber* y = [NSNumber numberWithInt:[[data objectAtIndex:3] intValue]];
		NSNumber* tagId = [NSNumber numberWithInt:[[data objectAtIndex:5] intValue]];
		NSNumber* n = [NSNumber numberWithInt:[[data objectAtIndex:6] intValue]]; //neighboring tag count.
		
		[tagFound setObject:[NSNumber numberWithBool:YES] forKey:tagId];
		
		//Only leave a pheromone if there are other tags nearby.
		if(randomFloat(1.) < exponentialCDF([n intValue] + 1, 0)) {//pheromoneLayingRate)) {
			NSArray* pheromoneData = [NSArray arrayWithObjects:x, y, tagId, nil];
			[pendingPheromones setObject:pheromoneData forKey:robotName];
		}
	}
	else if([event isEqualToString:@"home"]) {
		
		//First, add a pheromone if it found a tag during its run and if neighboring tags were found nearby (uses pendingPheromone list):
		NSArray* pheromoneData = [pendingPheromones objectForKey:robotName];
		if(pheromoneData != nil) {
			NSNumber* x = [pheromoneData objectAtIndex:0];
			NSNumber* y = [pheromoneData objectAtIndex:1];
			NSNumber* tagId = [pheromoneData objectAtIndex:2];
			[[PheromoneController getInstance] addPheromoneAtX:x andY:y forTag:tagId];
			[pendingPheromones removeObjectForKey:robotName];
		}
		else {
			//Tag had at most 1 neighbor, or no tag was found (rarely happens).
		}
		
		//Next, give the robot a (weighted) random pheromone (it chooses whether or not to use it client-side).
		NSArray* pheromonePosition = [[PheromoneController getInstance] getPheromone];
		
		/*
		 * Here, we find which client we are receiving from by looping through the list of clients
		 * and checking for equality between the two inputStreams.
		 * This is potentially inefficient, but shouldn't be much of a problem for a handful of robots.
		 */
		if (pheromonePosition != nil) {
			[server send:[NSString stringWithFormat:@"pheromone,%d,%d\n", [[pheromonePosition objectAtIndex:0] intValue], [[pheromonePosition objectAtIndex:1] intValue]] toNamedConnection:[data objectAtIndex:0]];
		}
	}
}

-(double) currentTime {
    return [startTime timeIntervalSinceNow] * -1; //multiply by -1000 for milliseconds, -1000000 for microseconds, -1 for seconds, etc.
}

-(void) addPheromoneAtX:(NSNumber*)x andY:(NSNumber*)y forTag:(NSNumber*)tagId {
    [self addPheromoneAtX:x andY:y forTag:tagId withPheromoneStrength:[NSNumber numberWithDouble:1.0]];
}

-(void) addPheromoneAtX:(NSNumber*)x andY:(NSNumber*)y forTag:(NSNumber*)tagId withPheromoneStrength:(NSNumber*)n {
    PhysicalPheromone* pheromone = [[PhysicalPheromone alloc] init];
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
        PhysicalPheromone* pheromone = [pheromoneList objectAtIndex:i];
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
        PhysicalPheromone* pheromone = [pheromoneList objectAtIndex:i];
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
