#import <Cocoa/Cocoa.h>

@class ABSServer;
@class ABSRobotDisplayView;

@interface ABSServerController : NSViewController {
    NSString* workingDirectory;
    NSMutableDictionary* pendingPheromones;
    NSMutableDictionary* tagFound;
    
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
    ABSRobotDisplayView* robotDisplayView;
}

-(IBAction) start:(id)sender;

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
@property (nonatomic,retain) IBOutlet ABSRobotDisplayView* robotDisplayView;

@end
