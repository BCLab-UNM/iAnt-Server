#import "ABSAppDelegate.h"
#import "ABSRobotDisplayView.h"

@implementation ABSAppDelegate

@synthesize serverWindow, robotDisplayWindow, serverController, robotDisplayController;

-(void) applicationDidFinishLaunching:(NSNotification *)aNotification {
	/*
	 * Basically, once the application finishes launching,
	 * tell our ABSController to make a new view and add it
	 * as a subview to our "root view".
	 *
	 * This then triggers the "loadView" event of ABSController,
	 * which is the entry point for everything else.
	 */
    [[serverWindow contentView] addSubview:[serverController view]];
}

@end
