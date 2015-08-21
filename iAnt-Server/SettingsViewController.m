#import "SettingsViewController.h"
#import "Settings.h"
#import "Writer.h"

@implementation SettingsViewController

@synthesize tagDistributionPopUp, tagCountTextField, boundsRadiusTextField, trialTypePopUp, environmentTypePopUp, validRunButton, startButton, workingDirectoryTextField;

-(void) awakeFromNib {
	[workingDirectoryTextField setStringValue:[[[Settings getInstance] settingsPlist] objectForKey:@"Working Directory"]];
}

-(IBAction) start:(id)sender {
	
	//Set default values for empty text fields.
    if([[tagCountTextField stringValue] isEqualToString:@""]) {
        [tagCountTextField setStringValue:[[tagCountTextField cell] placeholderString]];
    }
    if([[boundsRadiusTextField stringValue] isEqualToString:@""]) {
        [boundsRadiusTextField setStringValue:[[boundsRadiusTextField cell] placeholderString]];
    }
	
	//Set trial parameters for Settings.
	Settings* settings = [Settings getInstance];
	[settings setTagDistribution:[[tagDistributionPopUp selectedItem] title]];
	[settings setTagCount:[[tagCountTextField stringValue] intValue]];
	[settings setBoundsRadius:[[boundsRadiusTextField stringValue] intValue]];
	[settings setTrialType:[[trialTypePopUp selectedItem] title]];
	[settings setEnvironmentType:[[environmentTypePopUp selectedItem] title]];
	[settings setValid:([validRunButton state] == NSOnState ? YES : NO)];
	[settings setWorkingDirectory:[workingDirectoryTextField stringValue]];
	
	//Broadcast a start event.
	[[NSNotificationCenter defaultCenter] postNotificationName:@"start" object:nil];
    
    //Change button text.
    [startButton setEnabled:NO];
}

@end
