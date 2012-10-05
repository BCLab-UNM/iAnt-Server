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
                  [NSNumber numberWithFloat:0.],
                  [NSNumber numberWithInt:0],
                  [NSNumber numberWithInt:0],
                  [NSNumber numberWithInt:0],
                  [NSNumber numberWithFloat:0.],
                  nil];
    [stats reloadData];
    startTime = [NSDate date];
    timerIntakeRate = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(updateIntakeRate:) userInfo:nil repeats:YES];
}

-(void) updateIntakeRate:(id)sender {
    //Update intake rate in dataValues.
    double newIntakeRate = [[dataValues objectAtIndex:1] doubleValue]/([self currentTime]/60.);
    [dataValues replaceObjectAtIndex:1 withObject:[NSNumber numberWithDouble:newIntakeRate]];
}

-(double) currentTime {
    return [startTime timeIntervalSinceNow] * -1; //multiply by -1000 for milliseconds, -1000000 for microseconds, -1 for seconds, etc.
}

-(void) setTagCount:(NSNumber*)tagCount {
    [dataValues replaceObjectAtIndex:0 withObject:tagCount];
    [self updatePheromonesPerTag];
    [stats reloadData];
}

-(void) setPheromoneCount:(NSNumber*)pheromoneCount {
    [dataValues replaceObjectAtIndex:4 withObject:pheromoneCount];
    [self updatePheromonesPerTag];
    [stats reloadData];
}

-(void) updatePheromonesPerTag {
    double pheromones = [[dataValues objectAtIndex:4] doubleValue];
    double tags = [[dataValues objectAtIndex:0] doubleValue];
    if(tags){
        [dataValues replaceObjectAtIndex:5 withObject:[NSNumber numberWithDouble:(pheromones/tags)]];
    }
}

-(NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    return 6;
}

-(NSView*) tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTextView* result = [tableView makeViewWithIdentifier:@"CellStatsIdentifier" owner:self];
    
    if(result == nil) {
        result = [[NSTextView alloc] initWithFrame:result.frame];
        [result setIdentifier:@"CellStatsIdentifier"];
    }
    
    //Hate to use switches here
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
                label = @"Pheromones";
                break;
                
            case 5:
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
            [result setString:[[dataValues objectAtIndex:row] stringValue]];
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
    
    NSScrollView* scrollView = (NSScrollView*)[[console superview] superview];
    if(self.console.frame.size.height > scrollView.frame.size.height) {
        if([scrollView hasVerticalScroller]) {
            if([[scrollView verticalScroller] doubleValue] == 1.) {
                [console scrollRangeToVisible:NSMakeRange([[console string] length],0)];
            }
        }
    }
}

@end
