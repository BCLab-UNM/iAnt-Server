#import "StatsViewController.h"

@implementation StatsViewController

@synthesize stats;

-(void) start:(NSNotification*)notification {
	keys = [[NSArray alloc] initWithObjects:@"Tag Count", @"Intake Rate", @"Pheromones", @"Pheromones/Tags", @"Elapsed Time", nil];
	dataValues = [[NSMutableDictionary alloc] initWithObjects:
				  [NSArray arrayWithObjects:
				   [NSNumber numberWithInt:0],
				   [NSNumber numberWithFloat:0.],
				   [NSNumber numberWithInt:0],
				   [NSNumber numberWithFloat:0.],
				   [NSNumber numberWithFloat:0.],
				   nil] forKeys:keys];
	
	startTime = [NSDate distantFuture];
	timerTemporals = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(updateTemporals:) userInfo:nil repeats:YES];
	
	[stats reloadData];
}

-(void) message:(NSNotification*)notification {
	if(startTime == [NSDate distantFuture]) {
		startTime = [NSDate date];
		[timerTemporals fire];
	}
}

-(void) stats:(NSNotification*)notification {
	if(dataValues == nil){return;}
	NSString* key = [[notification userInfo] objectForKey:@"key"];
	NSNumber* val = [[notification userInfo] objectForKey:@"val"];
	
	[dataValues setObject:val forKey:key];
	
	if([key isEqualToString:@"Pheromones"] || [key isEqualToString:@"Tag Count"]) {
		int pheromones = [[dataValues objectForKey:@"Pheromones"] intValue];
		int tags = [[dataValues objectForKey:@"Tag Count"] intValue];
		double pheromonesPerTags = 0.;
		if(tags > 0){pheromonesPerTags = round(pheromones / tags * 100) / 100;}
		[dataValues setObject:[NSNumber numberWithDouble:pheromonesPerTags] forKey:@"Pheromones/Tags"];
	}
	
	[stats reloadData];
}

-(void) updateTemporals:(id)sender {
	if(startTime == [NSDate distantFuture]){return;}
	
	double currentTime = [startTime timeIntervalSinceNow] * -1;
	
	double newIntakeRate = round([[dataValues objectForKey:@"Tag Count"] doubleValue] / (currentTime / 60.) * 100) / 100;
	[dataValues setObject:[NSNumber numberWithDouble:newIntakeRate] forKey:@"Intake Rate"];
	
	int hours = (int)floor(currentTime / 3600);
	currentTime -= (hours * 3600);
	int minutes = (int)floor(currentTime / 60);
	currentTime -= (minutes * 60);
	int seconds = (int)floor(currentTime) % 60;
	NSString* elapsed = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
	[dataValues setObject:elapsed forKey:@"Elapsed Time"];
	
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
	
	NSString* key = [keys objectAtIndex:row];
	if([[tableColumn identifier] isEqualToString:@"ColumnKey"]){[result setString:key];}
	else {
		if(dataValues == nil){[result setString:@""];}
		else if([[dataValues objectForKey:key] isKindOfClass:[NSString class]]){[result setString:[dataValues objectForKey:key]];}
		else{[result setString:[[dataValues objectForKey:key] stringValue]];}
	}
	[result setEditable:NO];
	[result setSelectable:NO];
	
	return result;
}

@end
