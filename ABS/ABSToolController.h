#import <Cocoa/Cocoa.h>

@interface ABSToolController : NSViewController <NSToolbarDelegate,NSTableViewDataSource,NSTableViewDelegate> {
    NSTextView* console;
    NSTableView* stats;
    NSMutableArray* dataValues;
    NSDate* startTime;
    NSTimer* timerIntakeRate;
    
    NSMutableArray* consoleMessages;
    int consoleTags;
}

-(void) log:(NSString*)message withTag:(int)tag;
-(IBAction) didSelectToolbarThing:(id)sender;
-(void) initialize;
-(void) setTagCount:(NSNumber*)tagCount;
-(double) currentTime;

@property IBOutlet NSTextView* console;
@property IBOutlet NSTableView* stats;

@end