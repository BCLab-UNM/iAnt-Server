#import <Cocoa/Cocoa.h>

@interface StatsViewController : NSViewController <NSToolbarDelegate,NSTableViewDataSource,NSTableViewDelegate> {
	NSMutableDictionary* dataValues;
	NSArray* keys;
	NSTimer* timerTemporals;
	NSDate* startTime;
}

@property IBOutlet NSTableView* stats;

@end