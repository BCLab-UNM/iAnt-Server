#import "Settings.h"

@implementation Settings

@synthesize tagDistribution, tagCount, boundsRadius, trialType, environmentType, valid;
@synthesize robotColors, robotNames;
@synthesize settingsPlist, workingDirectory, dataDirectory;

+(Settings*) getInstance {
	static Settings* instance;
	if(!instance){instance = [[Settings alloc] init];}
	return instance;
}

-(id) init {
	if(self = [super init]) {
	
		//Load the working directory from the settings.plist file located in the User's library.
		NSString* settingsPath = [NSHomeDirectory() stringByAppendingString:@"/Library/Application Support/ABS/settings.plist"];
		settingsPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
		
		//If the plist file doesn't exist, load a default settings thingy.
		if(settingsPlist == nil) {
			settingsPlist = [[NSMutableDictionary alloc] initWithCapacity:1];
			
			NSString* defaultWorkingDirectory = [NSHomeDirectory() stringByAppendingString:@"/Dropbox/AntBot/Data"];
			[settingsPlist setObject:defaultWorkingDirectory forKey:@"Working Directory"];
		}
		
		robotColors = [[NSDictionary alloc] init];
		robotNames = [[NSDictionary alloc] init];
	}
	
	return self;
}

-(void) setWorkingDirectory:(NSString *)_workingDirectory {
	workingDirectory = _workingDirectory;

	[settingsPlist setObject:workingDirectory forKey:@"Working Directory"];
    NSString* settingsDirectory = [NSHomeDirectory() stringByAppendingString:@"/Library/Application Support/ABS"];
    [[NSFileManager defaultManager] createDirectoryAtPath:settingsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    NSString* settingsPath = [settingsDirectory stringByAppendingString:@"/settings.plist"];
    [settingsPlist writeToFile:settingsPath atomically:NO];
    
    NSString* path = [NSString stringWithFormat:@"%@/robotColors.plist", workingDirectory];
    robotColors = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    path = [NSString stringWithFormat:@"%@/robotNames.plist", workingDirectory];
    robotNames = [[NSDictionary alloc] initWithContentsOfFile:path];
}

-(NSString*) dataDirectory {
	if(!dataDirectory) {
		NSString* dataRoot;
		dataRoot = [NSString stringWithString:workingDirectory];
		if(!valid){dataRoot = [NSHomeDirectory() stringByAppendingString:@"/Desktop"];}

		NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy_M_dd_ccc"];
		NSString* dateDirectory = [formatter stringFromDate:[NSDate date]];
		[formatter setDateFormat:@"HH_mm_ss"];
		NSString* timeDirectory = [NSString stringWithFormat:@"Trial_%@",[formatter stringFromDate:[NSDate date]]];
		
		//Concatenate everything together to get a complete directory path.
		self.dataDirectory = [NSString stringWithFormat:@"%@/raw/%@/%@",dataRoot,dateDirectory,timeDirectory];
	}
	
	return dataDirectory;
}

-(NSMutableDictionary*) parameters {
	return [[NSMutableDictionary alloc] initWithObjects:
			[NSArray arrayWithObjects:
			 tagDistribution,
			 [NSNumber numberWithInt:tagCount],
			 [NSNumber numberWithFloat:boundsRadius],
			 trialType,
			 environmentType,
			 [NSNumber numberWithBool:valid], nil] forKeys:
			[NSArray arrayWithObjects:
			 @"tagDistribution",
			 @"tagCount",
			 @"boundsRadius",
			 @"trialType",
			 @"environmentType",
			 @"valid", nil]];
}

@end
