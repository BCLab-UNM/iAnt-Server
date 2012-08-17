#import <Cocoa/Cocoa.h>

@interface ABSToolController : NSViewController <NSToolbarDelegate,NSTableViewDataSource,NSTableViewDelegate> {
    NSTextView* console;
    NSTableView* stats;
}

-(void) log:(NSString*)message;
-(IBAction) didSelectToolbarThing:(id)sender;

@property IBOutlet NSTextView* console;
@property IBOutlet NSTableView* stats;

@end