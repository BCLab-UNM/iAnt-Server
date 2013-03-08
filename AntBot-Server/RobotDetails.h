#import <Foundation/Foundation.h>

@interface RobotDetails : NSObject {
  
}

+(void) initializeWithWorkingDirectory:(NSString*)workingDirectory;

+(NSColor*) colorFromName:(NSString*)robotName;
+(NSString*) nameFromMacAddress:(NSString*)macAddress;

@end
