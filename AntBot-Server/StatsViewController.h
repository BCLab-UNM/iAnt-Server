#import <Cocoa/Cocoa.h>

@interface StatsViewController : NSViewController <NSToolbarDelegate,NSTableViewDataSource,NSTableViewDelegate> {
	NSMutableArray* dataValues;
	NSTimer* timerTemporals;
	NSDate* startTime;
}

@property IBOutlet NSTableView* stats;

@end