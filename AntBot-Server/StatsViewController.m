#import "StatsViewController.h"

@implementation StatsViewController

@synthesize stats;

-(void) start {
	dataValues = [[NSMutableArray alloc] initWithObjects:
				  [NSNumber numberWithInt:0],
				  [NSNumber numberWithFloat:0.],
				  [NSNumber numberWithInt:0],
				  [NSNumber numberWithInt:0],
				  [NSNumber numberWithInt:0],
				  [NSNumber numberWithFloat:0.],
				  [NSNumber numberWithFloat:0],
				  nil];
	
	startTime = [NSDate distantFuture];
	timerTemporals = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(updateTemporals:) userInfo:nil repeats:YES];
	
	[stats reloadData];
}

-(void) message:(NSNotification*)notification {
	if(startTime == [NSDate distantFuture]) {
		startTime = [NSDate date];
		[timerTemporals fire];
	}
	
	
}

-(void) updateTemporals:(id)sender {
	if(startTime == [NSDate distantFuture]){return;}
	
	double currentTime = [startTime timeIntervalSinceNow] * -1;
	
	double newIntakeRate = [[dataValues objectAtIndex:0] doubleValue]/(currentTime/60.);
	[dataValues replaceObjectAtIndex:1 withObject:[NSNumber numberWithDouble:newIntakeRate]];
	
	double elapsed = floor((currentTime/60.)*100.)/100;
	[dataValues replaceObjectAtIndex:6 withObject:[NSNumber numberWithDouble:(elapsed)]];
	
	[stats reloadData];
}

-(NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
	return 7;
}

-(NSView*) tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	NSTextView* result = [tableView makeViewWithIdentifier:@"CellStatsIdentifier" owner:self];
	
	if(result == nil) {
		result = [[NSTextView alloc] initWithFrame:result.frame];
		[result setIdentifier:@"CellStatsIdentifier"];
	}
	
	//Hate to use switches here
	if([[tableColumn identifier] isEqualToString:@"ColumnKey"]) {
		NSString* label = @"";
		switch(row) {
			case 0: label = @"Tag Count"; break;
			case 1: label = @"Intake Rate"; break;
			case 2: label = @"Best Fitness"; break;
			case 3: label = @"Generation"; break;
			case 4: label = @"Pheromones"; break;
			case 5: label = @"Pheromones/Tags"; break;
			case 6: label = @"Elapsed Time"; break;
		}
		[result setString:label];
	}
	else {
		if(dataValues == nil){[result setString:@""];}
		else{[result setString:[[dataValues objectAtIndex:row] stringValue]];}
	}
	[result setEditable:NO];
	[result setSelectable:NO];
	
	return result;
}

@end
