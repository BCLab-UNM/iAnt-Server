#import <Cocoa/Cocoa.h>
#import "ABSRobotDisplayController.h"
#import "ABSServerController.h"
#import "ABSRobotDisplayView.h"

@interface ABSAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow* serverWindow;
    NSWindow* robotDisplayWindow;
    ABSRobotDisplayController* robotDisplayController;
    ABSServerController* serverController;
}

@property (nonatomic,retain) IBOutlet NSWindow* serverWindow;
@property (nonatomic,retain) IBOutlet NSWindow* robotDisplayWindow;
@property (nonatomic,retain) IBOutlet ABSRobotDisplayController* robotDisplayController;
@property (nonatomic,retain) IBOutlet ABSServerController* serverController;

@end
