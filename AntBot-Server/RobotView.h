#import <Cocoa/Cocoa.h>

@interface RobotView : NSView {
	NSDate* startTime;
	NSTimer* drawTimer;
	
	NSMutableDictionary* robots;
	NSMutableDictionary* pheromones;
}

-(BOOL) isFlipped;
-(void) addRobot:(NSString*)robotName;
-(void) redraw;

@end
