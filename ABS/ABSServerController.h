#import <Cocoa/Cocoa.h>

@class ABSServer;
@class ABSRobotDisplayView;
@class ABSToolController;

@interface ABSServerController : NSViewController {
    NSString* workingDirectory;
    NSString* dataDirectory;
    NSMutableDictionary* pendingPheromones;
    NSMutableDictionary* tagFound;
    NSMutableDictionary* settingsPlist;
    //NSNumber* tagCount;
    
	ABSServer* server;
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
    ABSRobotDisplayView* robotDisplayView;
    ABSToolController* toolController;
}

-(IBAction) start:(id)sender;
-(void) log:(NSString*)message;

@property (nonatomic,retain) NSString* workingDirectory;
@property (nonatomic,retain) NSMutableDictionary* pendingPheromones;
@property (nonatomic,retain) IBOutlet NSTextField* portTextField;
@property (nonatomic,retain) IBOutlet NSPopUpButton* fusionTypePopUp;
@property (nonatomic,retain) IBOutlet NSPopUpButton* tagDistributionPopUp;
@property (nonatomic,retain) IBOutlet NSTextField* tagRadiusTextField;
@property (nonatomic,retain) IBOutlet NSTextField* tagCountTextField;
@property (nonatomic,retain) IBOutlet NSTextField* boundsRadiusTextField;
@property (nonatomic,retain) IBOutlet NSPopUpButton* trialTypePopUp;
@property (nonatomic,retain) IBOutlet NSPopUpButton* environmentTypePopUp;
@property (nonatomic,retain) IBOutlet NSButton* validRunButton;
@property (nonatomic,retain) IBOutlet NSTextField* notesTextField;
@property (nonatomic,retain) IBOutlet NSButton* startButton;
@property (nonatomic,retain) IBOutlet NSTextField* workingDirectoryTextField;
@property (nonatomic,retain) IBOutlet ABSRobotDisplayView* robotDisplayView;
@property (nonatomic,retain) IBOutlet ABSToolController* toolController;

@end
