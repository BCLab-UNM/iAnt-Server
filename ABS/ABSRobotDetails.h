#import <Foundation/Foundation.h>

@interface ABSRobotDetails : NSObject {
    
}

+(NSColor*) colorFromName:(NSString*)robotName;
+(NSString*) nameFromMacAddress:(NSString*)macAddress;

@end
