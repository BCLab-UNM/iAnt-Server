#import <Foundation/Foundation.h>

@interface DroneController : NSObject {
	NSPoint dronePosition;
}

+(DroneController*) getInstance;

-(void) start;
-(void) message:(NSNotification*)notification;

@end
