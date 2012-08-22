#import <Cocoa/Cocoa.h>

@interface ABSToolController : NSViewController <NSToolbarDelegate,NSTableViewDataSource,NSTableViewDelegate> {
    NSTextView* console;
    NSTableView* stats;
    NSMutableArray* dataValues;
}

-(void) log:(NSString*)message;
-(IBAction) didSelectToolbarThing:(id)sender;
-(void) initialize;
-(void) setTagCount:(NSNumber*)tagCount;

@property IBOutlet NSTextView* console;
@property IBOutlet NSTableView* stats;

@end