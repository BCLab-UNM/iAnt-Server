#import "DroneController.h"
#import "PheromoneController.h"
#import "Server.h"

@implementation DroneController

+(DroneController*) getInstance {
    static DroneController* instance;
	if(!instance){instance = [[DroneController alloc] init];}
	return instance;
}

-(void) start:(NSNotification*)notification {
	
}

-(void) message:(NSNotification *)notification {
	NSArray* data = [[notification userInfo] objectForKey:@"data"];
	Server* server = [notification object];
	
	if([[data objectAtIndex:0] isEqualToString:@"mocap"]) {
        if([data count] == 3) {
            NSString* robotName = [data objectAtIndex:1];
            NSString* heading = [data objectAtIndex:2];
            
            Connection* connection = [[server namedConnections] objectForKey:robotName];
            if(connection != nil) {
                [server send:[NSString stringWithFormat:@"heading,%@\n",heading] toStream:[connection outputStream]];
            }
            return;
        }
        else if([data count] == 4) {
            //Convert mm to cm, invert sign of y value
            dronePosition.x = [[data objectAtIndex:2] doubleValue] / 10;
            dronePosition.y = [[data objectAtIndex:3] doubleValue] / -10;
            
            return;
        }
    }
    else if ([[data objectAtIndex:0] isEqualToString:@"roundel"]) {
        //Add pheromone at drone's location with pheromone strength of DBL_MAX so it never fully evaporates
        [[PheromoneController getInstance] addPheromoneAtX:[NSNumber numberWithDouble:dronePosition.x]
													  andY:[NSNumber numberWithDouble:dronePosition.y]
													forTag:0
									 withPheromoneStrength:[NSNumber numberWithDouble:FLT_MAX]];
    }
}

@end
