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
	[[NSNotificationCenter defaultCenter] addObserver:server selector:@selector(start) name:@"start" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:pheromoneController selector:@selector(start) name:@"start" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:droneController selector:@selector(start) name:@"start" object:nil];
	
	//Register all message notifications.
	[[NSNotificationCenter defaultCenter] addObserver:pheromoneController selector:@selector(message:) name:@"message" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:droneController selector:@selector(message:) name:@"message" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:logViewController selector:@selector(message:) name:@"message" object:nil];
}


-(void) start:(NSNotification*)notification {
	Settings* settings = [Settings getInstance];
	[[NSFileManager defaultManager] createDirectoryAtPath:[settings dataDirectory] withIntermediateDirectories:YES attributes:nil error:nil];
	NSString* parameterPath = [[settings dataDirectory] stringByAppendingString:@"/trial.plist"];
	[[settings parameters] writeToFile:parameterPath atomically:NO];
	
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
    NSArray* messageExploded = [message componentsSeparatedByString:@","];
	if([messageExploded count] == 1) {
		newClient = [NSNumber numberWithBool:YES];
		if([[[Settings getInstance] robotNames] objectForKey:[messageExploded objectAtIndex:0]]) {
			for(Connection* connection in [server connections]) {
				if([connection inputStream] == theStream) {
					[[server namedConnections] setObject:connection forKey:[messageExploded objectAtIndex:0]];
					return;
				}
			}
		}
	}
	
	NSDictionary* data = [NSDictionary dictionaryWithObjects:
						  [NSArray arrayWithObjects:messageExploded, newClient, nil] forKeys:
						  [NSArray arrayWithObjects:@"data", @"newClient", nil]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"message" object:server userInfo:data];
}

@end
