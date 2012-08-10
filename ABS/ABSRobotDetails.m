#import "ABSRobotDetails.h"

@implementation ABSRobotDetails

static NSDictionary* robotColors = nil;
static NSDictionary* robotNames = nil;

+(void) initialize {
    //Get the current working directory.
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* desktop = [[fileManager URLForDirectory:NSDesktopDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil] path];
    if(!robotColors) {
        NSString* path = [NSString stringWithFormat:@"%@/../Dropbox/AntBot/Data/robotColors.plist",desktop];
        robotColors = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    if(!robotNames) {
        NSString* path = [NSString stringWithFormat:@"%@/../Dropbox/AntBot/Data/robotNames.plist",desktop];
        robotNames = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
}

+(NSColor*) colorFromName:(NSString *)robotName {
    double r, g, b, a;
    NSArray* colorComponents;
    colorComponents = [[robotColors objectForKey:robotName] componentsSeparatedByString:@","];
    r = [[colorComponents objectAtIndex:0] doubleValue];
    g = [[colorComponents objectAtIndex:1] doubleValue];
    b = [[colorComponents objectAtIndex:2] doubleValue];
    a = 1.0;
    return [NSColor colorWithCalibratedRed:r green:g blue:b alpha:a];
}

+(NSString*) nameFromMacAddress:(NSString *)macAddress {
    return [robotNames objectForKey:macAddress];
}

@end
