#import <Cocoa/Cocoa.h>
#import "ServerController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  ServerController* serverController;
}

@property (nonatomic,retain) IBOutlet NSWindow* serverWindow;
@property (nonatomic,retain) IBOutlet ServerController* serverController;

@end
