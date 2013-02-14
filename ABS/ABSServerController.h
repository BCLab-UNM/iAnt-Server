#import <Cocoa/Cocoa.h>

@class ABSServer;
@class ABSRobotDisplayView;
@class ABSToolController;

@interface ABSServerController : NSViewController {
    
    //Interface controls.
    NSWindow* serverWindow;
    NSTabView* tabView;
    NSPopUpButton* tagDistributionPopUp;
    NSTextField* tagCountTextField;
    NSTextField* boundsRadiusTextField;
    NSPopUpButton* trialTypePopUp;
    NSPopUpButton* environmentTypePopUp;
    NSButton* validRunButton;
    NSButton* startButton;
    NSTextField* workingDirectoryTextField;
    NSTextField* userLogTextField;
    
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
    
    int simCount;
}

-(IBAction) start:(id)sender;
-(IBAction) logUserMessage:(id)sender;
-(void) log:(NSString*)message withTag:(int)tag;

//Interface controls.
@property IBOutlet NSWindow* serverWindow;
@property IBOutlet NSTabView* tabView;
@property IBOutlet NSView* monitorView;
@property IBOutlet NSPopUpButton* tagDistributionPopUp;
@property IBOutlet NSTextField* tagCountTextField;
@property IBOutlet NSTextField* boundsRadiusTextField;
@property IBOutlet NSPopUpButton* trialTypePopUp;
@property IBOutlet NSPopUpButton* environmentTypePopUp;
@property IBOutlet NSButton* validRunButton;
@property IBOutlet NSButton* startButton;
@property IBOutlet NSTextField* workingDirectoryTextField;
@property IBOutlet NSTextField* userLogTextField;

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
