#import <Cocoa/Cocoa.h>

@class ABSServer;
@class ABSRobotDisplayView;
@class ABSToolController;

@interface ABSServerController : NSViewController {
    
    //Interface controls.
    NSTextField* portTextField;
    NSPopUpButton* fusionTypePopUp;
    NSPopUpButton* tagDistributionPopUp;
    NSTextField* tagRadiusTextField;
    NSTextField* tagCountTextField;
    NSTextField* boundsRadiusTextField;
    NSPopUpButton* trialTypePopUp;
    NSPopUpButton* environmentTypePopUp;
    NSButton* validRunButton;
    NSTextField* notesTextField;
    NSButton* startButton;
    NSTextField* workingDirectoryTextField;
    
    //Other important application components.
    ABSServer* server;
    ABSRobotDisplayView* robotDisplayView;
    ABSToolController* toolController;
    
    //Internal variables.
    NSString* workingDirectory;
    NSString* dataDirectory;
    NSMutableDictionary* pendingPheromones;
    NSMutableDictionary* tagFound;
    NSMutableDictionary* settingsPlist;
    NSNumber* statTagCount;
}

-(IBAction) start:(id)sender;
-(void) log:(NSString*)message;

//Interface controls.
@property IBOutlet NSTextField* portTextField;
@property IBOutlet NSPopUpButton* fusionTypePopUp;
@property IBOutlet NSPopUpButton* tagDistributionPopUp;
@property IBOutlet NSTextField* tagRadiusTextField;
@property IBOutlet NSTextField* tagCountTextField;
@property IBOutlet NSTextField* boundsRadiusTextField;
@property IBOutlet NSPopUpButton* trialTypePopUp;
@property IBOutlet NSPopUpButton* environmentTypePopUp;
@property IBOutlet NSButton* validRunButton;
@property IBOutlet NSTextField* notesTextField;
@property IBOutlet NSButton* startButton;
@property IBOutlet NSTextField* workingDirectoryTextField;

//Other important application components.
@property ABSServer* server;
@property IBOutlet ABSRobotDisplayView* robotDisplayView;
@property IBOutlet ABSToolController* toolController;

//Internal variables.
@property NSString* workingDirectory;
@property NSString* dataDirectory;
@property NSMutableDictionary* pendingPheromones;
@property NSMutableDictionary* tagFound;
@property NSMutableDictionary* settingsPlist;
@property NSNumber* statTagCount;

@end
