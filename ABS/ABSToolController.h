#import <Cocoa/Cocoa.h>

@interface ABSToolController : NSViewController <NSToolbarDelegate,NSTableViewDataSource,NSTableViewDelegate> {
  NSMutableArray* dataValues;
  
  NSTimer* timerTemporals;
    
  NSMutableArray* consoleMessages;
  int consoleTags;
}

-(void) initialize;

-(double) currentTime;
-(void) updateStartTime;

-(void) log:(NSString*)message withTag:(int)tag;
-(IBAction) didSelectToolbarThing:(id)sender;

-(void) setTagCount:(NSNumber*)tagCount;
-(void) setPheromoneCount:(NSNumber*) pheromoneCount;

@property IBOutlet NSTextView* console;
@property IBOutlet NSTableView* stats;

@property NSDate* startTime;

@end