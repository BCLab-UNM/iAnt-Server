#import <Foundation/Foundation.h>

@interface DroneController : NSObject {
	NSPoint dronePosition;
}

+(DroneController*) getInstance;

-(void) start:(NSNotification*)notification;
-(void) message:(NSNotification *)notification;

@end
