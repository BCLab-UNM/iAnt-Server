#import <Cocoa/Cocoa.h>

@interface LogViewController : NSViewController {
	int consoleTags;
	 NSMutableArray* consoleMessages;
}

-(void) log:(NSString*)message withTag:(int)tag;
-(IBAction) didSelectConsoleTags:(id)sender;
-(IBAction) logUserMessage:(id)sender;

@property IBOutlet NSTextView* console;
@property IBOutlet NSTextField* userLogTextField;

@end
