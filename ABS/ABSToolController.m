#import "ABSToolController.h"

@implementation ABSToolController

@synthesize console,stats;
@synthesize startTime;

-(void) initialize {
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
  
  consoleMessages = [[NSMutableArray alloc] init];
  consoleTags = 3;
  
  [self resetConsole];
  [stats reloadData];
}

-(double) currentTime {
  return [startTime timeIntervalSinceNow] * -1; //multiply by -1000 for milliseconds, -1 for seconds, etc.
}

-(void) updateTemporals:(id)sender {
  if(startTime == [NSDate distantFuture]){return;}

  double newIntakeRate = [[dataValues objectAtIndex:0] doubleValue]/([self currentTime]/60.);
  [dataValues replaceObjectAtIndex:1 withObject:[NSNumber numberWithDouble:newIntakeRate]];

  double elapsed = floor(([self currentTime]/60.)*100.)/100;
  [dataValues replaceObjectAtIndex:6 withObject:[NSNumber numberWithDouble:(elapsed)]];
  
  [stats reloadData];
}

-(void) updateStartTime {
  startTime = [NSDate date];
  [timerTemporals fire];
}

-(void) updatePheromonesPerTag {
  double pheromones = [[dataValues objectAtIndex:4] doubleValue];
  double tags = [[dataValues objectAtIndex:0] doubleValue];
  if(tags){
    [dataValues replaceObjectAtIndex:5 withObject:[NSNumber numberWithDouble:(pheromones/tags)]];
  }
  [stats reloadData];
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
      
      case 6:
        label = @"Elapsed Time";
      break;
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

-(IBAction)didSelectToolbarThing:(id)sender {
  if([sender class] == [NSSegmentedControl class]) {
    long segments = [sender segmentCount];
    consoleTags = 0;
    for(int i=0; i<segments; i++) {
      if([sender isSelectedForSegment:i]) {
        consoleTags |= (1 << i);
      }
    }
    [self resetConsole];
  }
  else {
    if([[sender label] isEqualToString:@"Console"]) {
      [[[console superview] superview] setHidden:NO];
      [[[stats superview] superview] setHidden:YES];
    }
    else if([[sender label] isEqualToString:@"Stats"]) {
      [[[console superview] superview] setHidden:YES];
      [[[stats superview] superview] setHidden:NO];
    }
  }
}

-(void) resetConsole {
  
  //Clear the console.
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
  [consoleMessages addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:tag],message,nil]];
  
  //If we actually have to display the message, update the NSTextView.
  if(consoleTags & (1 << tag)){
    
    //Keep track of whether or not we should scroll BEFORE we add the text.
    BOOL shouldScroll=NO;
    
    //Conveniently, the verticalScroller always has a value of 1 (even if there IS no vertical scroller).
    NSScrollView* scrollView = (NSScrollView*)[console enclosingScrollView];
    if([[scrollView verticalScroller] floatValue] == 1.f) {
      shouldScroll=YES;
    }
    
    //Add the text.
    [[[console textStorage] mutableString] appendString:[NSString stringWithFormat:@"%@\n",message]];
    
    //Set the correct font.
    [[console textStorage] setFont:[NSFont fontWithName:@"Monaco" size:11.f]];
    
    //Scroll to bottom if we were previously scrolled to the bottom.
    if(shouldScroll){
      [console scrollRangeToVisible:NSMakeRange([[console string] length],0)];
    }
  }
}

@end
