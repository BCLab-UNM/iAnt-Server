#import <Cocoa/Cocoa.h>

@interface StatsViewController : NSViewController <NSToolbarDelegate,NSTableViewDataSource,NSTableViewDelegate> {
	NSMutableDictionary* dataValues;
	NSArray* keys;
	NSTimer* timerTemporals;
	NSDate* startTime;
}

-(void) start:(NSNotification*)notification;
-(void) message:(NSNotification*)notification;
-(void) stats:(NSNotification*)notification;

@property IBOutlet NSTableView* stats;

@end