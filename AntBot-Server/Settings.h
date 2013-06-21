#import <Foundation/Foundation.h>

@interface Settings : NSObject {
	
}

+(Settings*)getInstance;

@property NSString* tagDistribution;
@property int tagCount;
@property float boundsRadius;
@property NSString* trialType;
@property NSString* environmentType;
@property bool valid;

@property NSDictionary* robotColors;
@property NSDictionary* robotNames;

@property NSMutableDictionary* settingsPlist;
@property (nonatomic) NSString* workingDirectory;
@property (nonatomic) NSString* dataDirectory;

-(NSMutableDictionary*) parameters;

@end
