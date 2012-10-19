#import <Foundation/Foundation.h>

@interface ABSRobotDetails : NSObject {
  
}

+(void) initializeWithWorkingDirectory:(NSString*)workingDirectory;

+(NSColor*) colorFromName:(NSString*)robotName;
+(NSString*) nameFromMacAddress:(NSString*)macAddress;

@end
