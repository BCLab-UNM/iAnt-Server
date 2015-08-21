#import <Cocoa/Cocoa.h>
#import "Server.h"
#import "Writer.h"
#import "RobotView.h"
#import "StatsViewController.h"
#import "LogViewController.h"

@class Server;
@class LogViewController;
@class RobotViewController;
@class StatsViewController;

@interface ServerController : NSViewController {
    NSString* evolvedParameters;
}

//Interface controls.
@property IBOutlet NSWindow* serverWindow;
@property IBOutlet NSTabView* tabView;
@property IBOutlet NSView* monitorView;

//Other important application components.
@property Server* server;
@property IBOutlet LogViewController* logViewController;
@property IBOutlet RobotView* robotView;
@property IBOutlet StatsViewController* statsViewController;

@end
