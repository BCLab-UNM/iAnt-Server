#import <Foundation/Foundation.h>

@interface DroneController : NSObject {
	NSPoint dronePosition;
}

+(DroneController*) getInstance;

@end
