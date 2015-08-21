#import "AppDelegate.h"

@implementation AppDelegate

@synthesize serverWindow, serverController;

-(void) applicationDidFinishLaunching:(NSNotification *)aNotification {
  [[serverWindow contentView] addSubview:[serverController view]];
}

@end
