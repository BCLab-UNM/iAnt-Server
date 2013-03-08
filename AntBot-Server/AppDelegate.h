#import <Cocoa/Cocoa.h>
#import "RobotDisplayController.h"
#import "ServerController.h"
#import "RobotDisplayView.h"
#import "ToolController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  NSWindow* serverWindow;
  NSWindow* robotDisplayWindow;
  NSWindow* toolWindow;
  RobotDisplayController* robotDisplayController;
  ServerController* serverController;
  ToolController* toolController;
}

@property (nonatomic,retain) IBOutlet NSWindow* serverWindow;
@property (nonatomic,retain) IBOutlet NSWindow* robotDisplayWindow;
@property (nonatomic,retain) IBOutlet NSWindow* toolWindow;
@property (nonatomic,retain) IBOutlet RobotDisplayController* robotDisplayController;
@property (nonatomic,retain) IBOutlet ServerController* serverController;
@property (nonatomic,retain) IBOutlet ToolController* toolController;

@end
