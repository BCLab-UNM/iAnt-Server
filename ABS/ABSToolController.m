#import "ABSToolController.h"

@implementation ABSToolController

@synthesize console,stats;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        NSLog(@"Init");
    }
    
    return self;
}

-(void) initialize {
    dataValues = [[NSMutableArray alloc] initWithObjects:
                  [NSNumber numberWithInt:0],
                  [NSNumber numberWithFloat:0.f],
                  [NSNumber numberWithInt:0],
                  [NSNumber numberWithInt:0],
                  [NSNumber numberWithFloat:0.f],
                  nil];
}

-(void) setTagCount:(NSNumber*)tagCount {
    [dataValues replaceObjectAtIndex:0 withObject:tagCount];
    [stats reloadData];
}

-(NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    return 5;
}

-(NSView*) tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTextView* result = [tableView makeViewWithIdentifier:@"CellStatsIdentifier" owner:self];
    
    if(result == nil) {
        result = [[NSTextView alloc] initWithFrame:result.frame];
        [result setIdentifier:@"CellStatsIdentifier"];
    }
    
    if([[tableColumn identifier] isEqualToString:@"ColumnKey"]) {
        NSString* label;
        switch(row) {
            case 0:
                label = @"Tag Count";
                break;
                
            case 1:
                label = @"Intake Rate";
                break;
                
            case 2:
                label = @"Best Fitness";
                break;
                
            case 3:
                label = @"Generation";
                break;
                
            case 4:
                label = @"Pheromones/Tags";
                break;
        }
        [result setString:label];
    }
    else {
        if(dataValues == nil) {
            [result setString:@""];
        }
        else {
            [result setString:[dataValues objectAtIndex:row]];
        }
    }
    [result setEditable:NO];
    
    return result;
}

-(IBAction)didSelectToolbarThing:(id)sender {
    if([[sender label] isEqualToString:@"Console"]) {
        [[[console superview] superview] setHidden:NO];
        [[[stats superview] superview] setHidden:YES];
    }
    else {
        [[[console superview] superview] setHidden:YES];
        [[[stats superview] superview] setHidden:NO];
    }
}

-(void) log:(NSString*)message {
    [console setString:[NSString stringWithFormat:@"%@%@\n",[console string],message]];
    
    //NSScrollView* scrollView = (NSScrollView*)[console superview];
    /*if(self.console.frame.size.height > scrollView.frame.size.height) {
        if([scrollView hasVerticalScroller]) {
            if([[scrollView verticalScroller] floatValue] != 1.) {
                [console scrollRangeToVisible:NSMakeRange([[console string] length],0)];
            }
        }
    }*/
}

@end
