#import <Cocoa/Cocoa.h>

@interface SettingsViewController : NSViewController

@property IBOutlet NSPopUpButton* tagDistributionPopUp;
@property IBOutlet NSTextField* tagCountTextField;
@property IBOutlet NSTextField* boundsRadiusTextField;
@property IBOutlet NSPopUpButton* trialTypePopUp;
@property IBOutlet NSPopUpButton* environmentTypePopUp;
@property IBOutlet NSButton* validRunButton;
@property IBOutlet NSButton* startButton;
@property IBOutlet NSTextField* workingDirectoryTextField;

@end
