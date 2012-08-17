#import <Cocoa/Cocoa.h>

@interface ABSToolController : NSViewController <NSToolbarDelegate> {
    NSTextField* console;
}

-(void) log:(NSString*)message;

@property IBOutlet NSTextField* console;

@end
