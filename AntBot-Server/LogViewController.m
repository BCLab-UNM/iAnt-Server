#import "LogViewController.h"
#import "Writer.h"
#import "Settings.h"

@implementation LogViewController

@synthesize console, userLogTextField;

-(void) start {
	consoleMessages = [[NSMutableArray alloc] init];
	consoleTags = 0;
}

-(void) message:(NSNotification*)notification {
	NSArray* data = [[notification userInfo] objectForKey:@"data"];
	Settings* settings = [Settings getInstance];
	NSString* robotName = [[settings robotNames] objectForKey:[data objectAtIndex:0]];
	if(!robotName){robotName = @"unknownRobot";}
	
	NSString* filename = [NSString stringWithFormat:@"%@/%@.csv", [settings dataDirectory], robotName];
    
    Writer* writer = [Writer getInstance];
    
    if(![writer isOpen:filename]) {
        if(![writer openFilename:filename]) {
            [self log:[NSString stringWithFormat:@"[CTR] Error opening %@ for writing.", filename] withTag:LOG_TAG_PROBLEM];
        }
    }
    
	int logTag = LOG_TAG_MESSAGE;
	if([data count] >= 5){logTag = LOG_TAG_EVENT;}
	NSString* message = @""; //Implode data, replace mac with robotName
    [writer writeString:[NSString stringWithFormat:@"%@\n", message] toFile:filename];
    [self log:[NSString stringWithFormat:@"[CTR] Received: %@", message] withTag:logTag];
}

-(IBAction) didSelectConsoleTags:(id)sender {
	long segments = [sender segmentCount];
	consoleTags = 0;
	for(int i = 0; i < segments; i++) {
		if([sender isSelectedForSegment:i]) {
			consoleTags |= (1 << i);
		}
	}
	[self resetConsole];
}

-(void) resetConsole {
	[console setString:@""];
	
	//Iterate through the array of messages.
	for(NSArray* arr in consoleMessages) {
		int tag = [[arr objectAtIndex:0] intValue];
		if(consoleTags & (1 << tag)) {
			[[[console textStorage] mutableString] appendString:[NSString stringWithFormat:@"%@\n",[arr objectAtIndex:1]]];
		}
	}
	
	//Set the correct font and scroll to the bottom.
	[[console textStorage] setFont:[NSFont fontWithName:@"Monaco" size:11.f]];
	[console scrollRangeToVisible:NSMakeRange([[console string] length],0)];
}

-(void) log:(NSString*)message withTag:(int)tag {
	
	//Add the message to the array of messages.
	[consoleMessages addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:tag], message, nil]];
	
	//If we actually have to display the message, update the NSTextView.
	if(consoleTags & (1 << tag)) {
		
		//Keep track of whether or not we should scroll BEFORE we add the text.
		BOOL shouldScroll = NO;
		
		//Conveniently, the verticalScroller always has a value of 1 (even if there IS no vertical scroller).
		NSScrollView* scrollView = (NSScrollView*)[console enclosingScrollView];
		if([[scrollView verticalScroller] floatValue] == 1.f) {
			shouldScroll = YES;
		}
		
		//Add the text.
		[[[console textStorage] mutableString] appendString:[NSString stringWithFormat:@"%@\n", message]];
		
		//Set the correct font.
		[[console textStorage] setFont:[NSFont fontWithName:@"Monaco" size:11.f]];
		
		//Scroll to bottom if we were previously scrolled to the bottom.
		if(shouldScroll) {
			[console scrollRangeToVisible:NSMakeRange([[console string] length], 0)];
		}
	}
}

-(IBAction) logUserMessage:(id)sender {
    Writer* writer = [Writer getInstance];
	NSString* filename = [[[Settings getInstance] dataDirectory] stringByAppendingString:@"/userLogs.log"];
	NSString* message = [userLogTextField stringValue];
	if(![writer isOpen:filename]){[writer openFilename:filename];}
	
	[writer writeString:[message stringByAppendingString:@"\n"] toFile:filename];
	[self log:[NSString stringWithFormat:@"User logged \"%@\".",message] withTag:LOG_TAG_EVENT];
	
	[userLogTextField setStringValue:@""];
}

@end
