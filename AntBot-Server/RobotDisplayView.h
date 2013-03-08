#import <Cocoa/Cocoa.h>

@interface RobotDisplayView : NSView {
  //Dictionary of robot names to an array of x, y, color.
  NSMutableDictionary* robots;
  NSMutableDictionary* pheromones;
  NSNumber* boundsRadius;
  NSTimer* drawTimer;
  NSDate* startTime;
}

@property (nonatomic,retain) NSNumber* boundsRadius;

-(BOOL) isFlipped;

-(double) currentTime;

-(void) addRobot:(NSString*)robotName;
-(void) setX:(NSNumber*)x andY:(NSNumber*)y andColor:(NSColor*)color forRobot:(NSString*)robotName;
-(void) removeRobot:(NSString*)robotName;

-(void) redraw;

-(void) reset;

@end
