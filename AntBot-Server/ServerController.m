#import "ServerController.h"
#import "Settings.h"
#import "PheromoneController.h"
#import "DroneController.h"

@implementation ServerController


//Interface controls.
@synthesize serverWindow, tabView, monitorView;

//Other important application components.
@synthesize server, logViewController, robotView, statsViewController;

-(void) loadView {
	server = [[Server alloc] init];
    [server setDelegate:self];
	
	PheromoneController* pheromoneController = [PheromoneController getInstance];
	DroneController* droneController = [DroneController getInstance];
	
	//Register all start notifications.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(start:) name:@"start" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:server selector:@selector(start:) name:@"start" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:pheromoneController selector:@selector(start:) name:@"start" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:droneController selector:@selector(start:) name:@"start" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:logViewController selector:@selector(start:) name:@"start" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:statsViewController selector:@selector(start:) name:@"start" object:nil];
	
	//Register all message notifications.
	[[NSNotificationCenter defaultCenter] addObserver:pheromoneController selector:@selector(message:) name:@"message" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:droneController selector:@selector(message:) name:@"message" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:robotView selector:@selector(message:) name:@"message" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:statsViewController selector:@selector(message:) name:@"message" object:nil];
	
	//LogViewController receives log notifications from several sources.
	[[NSNotificationCenter defaultCenter] addObserver:logViewController selector:@selector(log:) name:@"log" object:nil];
	
	//StatsViewController receives stat notifications from several sources.
	[[NSNotificationCenter defaultCenter] addObserver:statsViewController selector:@selector(stats:) name:@"stats" object:nil];
}


-(void) start:(NSNotification*)notification {
	Settings* settings = [Settings getInstance];
	[[NSFileManager defaultManager] createDirectoryAtPath:[settings dataDirectory] withIntermediateDirectories:YES attributes:nil error:nil];
	NSString* parameterPath = [[settings dataDirectory] stringByAppendingString:@"/trial.plist"];
	[[settings parameters] writeToFile:parameterPath atomically:NO];
    
    NSString* parametersPath = [NSHomeDirectory() stringByAppendingString:@"/Desktop/evolvedParameters.plist"];
	NSMutableDictionary* parameters = [[NSMutableDictionary alloc] initWithContentsOfFile:parametersPath];
    if(!parameters) {
        NSLog(@"Evolved parameters file not found.");
    }
    else {
        [[PheromoneController getInstance] setPheromoneDecayRate:[[parameters objectForKey:@"pheromoneDecayRate"] floatValue]];
        [[PheromoneController getInstance] setPheromoneLayingRate:[[parameters objectForKey:@"pheromoneLayingRate"] floatValue]];
    }
    evolvedParameters = [NSString stringWithFormat:@"parameters,%@,%@,%@,%@,%@,%@,%@,%@\n",
                         [parameters objectForKey:@"travelGiveUpProbability"],
                         [parameters objectForKey:@"searchGiveUpProbability"],
                         [parameters objectForKey:@"uninformedSearchCorrelation"],
                         [parameters objectForKey:@"informedSearchCorrelation"],
                         [parameters objectForKey:@"informedGiveUpProbability"],
                         [parameters objectForKey:@"neighborSearchGiveUpProbability"],
                         [parameters objectForKey:@"stepSizeVariation"],
                         [parameters objectForKey:@"siteFidelityRate"]];
	
    NSRect frame = [serverWindow frame];
    if(frame.size.width < 800) {
        frame.origin.y -= (250 - 22);
        frame.size.width = 800;
        frame.size.height = 600;
		[serverWindow setMinSize:NSMakeSize(800, 600)];
        [serverWindow setFrame:frame display:YES animate:YES];
    }
    [tabView selectTabViewItemAtIndex:1];
}


-(void) didReceiveMessage:(NSString*)message onStream:(NSInputStream*)theStream {
	NSNumber* newClient = [NSNumber numberWithBool:NO];
	
	NSDictionary* data = [NSDictionary dictionaryWithObjects:
			[NSArray arrayWithObjects:message, [NSNumber numberWithInt:LOG_TAG_MESSAGE], nil] forKeys:
			[NSArray arrayWithObjects:@"message", @"tag", nil]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"log" object:self userInfo:data];
	
    NSArray* messageExploded = [message componentsSeparatedByString:@","];
	if([messageExploded count] == 1) {
		newClient = [NSNumber numberWithBool:YES];
		if([[[Settings getInstance] robotNames] objectForKey:[messageExploded objectAtIndex:0]]) {
			for(Connection* connection in [server connections]) {
				if([connection inputStream] == theStream) {
					[[server namedConnections] setObject:connection forKey:[messageExploded objectAtIndex:0]];
                    if (evolvedParameters) {
                        [server send:evolvedParameters toStream:[connection outputStream]];
                    }
					return;
				}
			}
		}
	}
	
	data = [NSDictionary dictionaryWithObjects:
						  [NSArray arrayWithObjects:messageExploded, newClient, nil] forKeys:
						  [NSArray arrayWithObjects:@"data", @"newClient", nil]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"message" object:server userInfo:data];
}

@end
