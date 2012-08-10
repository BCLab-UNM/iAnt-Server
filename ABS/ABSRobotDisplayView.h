#import <Cocoa/Cocoa.h>

@interface ABSRobotDisplayView : NSView {
    //Dictionary of robot names to an array of x, y, color.
    NSMutableDictionary* robots;
    NSMutableDictionary* pheromones;
    NSNumber* boundsRadius;
}

@property (nonatomic,retain) NSNumber* boundsRadius;

-(BOOL) isFlipped;

-(void) addRobot:(NSString*)robotName;
-(void) setX:(NSNumber*)x andY:(NSNumber*)y andColor:(NSColor*)color forRobot:(NSString*)robotName;

-(void) reset;

@end
