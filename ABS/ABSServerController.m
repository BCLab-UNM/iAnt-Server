#import "ABSServerController.h"
#import "ABSPheromoneController.h"
#import "ABSServer.h"
#import "ABSWriter.h"
#import "ABSRobotDisplayView.h"
#import "ABSRobotDetails.h"
#import "ABSConnection.h"
#import "ABSSimulationController.h"
#import "ABSToolController.h"
#import "ABSSimulation.h"
#import "ABSSimulationColony.h"

@implementation ABSServerController


//Interface controls.
@synthesize portTextField, fusionTypePopUp, tagDistributionPopUp, tagRadiusTextField, tagCountTextField, boundsRadiusTextField, trialTypePopUp, environmentTypePopUp, validRunButton, notesTextField, startButton, workingDirectoryTextField;

//Other important application components.
@synthesize server, robotDisplayView, toolController;

//Internal variables.
@synthesize workingDirectory, dataDirectory, pendingPheromones, tagFound, settingsPlist, statTagCount;


/*
 * Called when the view loads.  Essentially our initialize function.
 */
-(void) loadView {
	[fusionTypePopUp addItemWithTitle:@"None"];
  [fusionTypePopUp addItemWithTitle:@"Bayesian"];
  [fusionTypePopUp addItemWithTitle:@"Kahlman"];
  [fusionTypePopUp addItemWithTitle:@"Other"];
  
  [tagDistributionPopUp addItemWithTitle:@"Clumped"];
  [tagDistributionPopUp addItemWithTitle:@"Uniform"];
  [tagDistributionPopUp addItemWithTitle:@"Normal"];
  [tagDistributionPopUp addItemWithTitle:@"Powerlaw"];
  [tagDistributionPopUp addItemWithTitle:@"Other"];
  
  [trialTypePopUp addItemWithTitle:@"Site Fidelity"];
  [trialTypePopUp addItemWithTitle:@"Pheromones"];
  [trialTypePopUp addItemWithTitle:@"Both"];
  
  [environmentTypePopUp addItemWithTitle:@"Concrete"];
  [environmentTypePopUp addItemWithTitle:@"Asphalt"];
  [environmentTypePopUp addItemWithTitle:@"Grass"];
  [environmentTypePopUp addItemWithTitle:@"Sand"];
  [environmentTypePopUp addItemWithTitle:@"Tile"];
  [environmentTypePopUp addItemWithTitle:@"Other"];
  
  //Load the working directory from the settings.plist file located in the User's library.
  NSString* settingsPath = [NSHomeDirectory() stringByAppendingString:@"/Library/Application Support/ABS/settings.plist"];
  settingsPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
  
  //If the plist file doesn't exist, load a default settings thingy.
  if(settingsPlist == nil) {
    settingsPlist = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    NSString* defaultWorkingDirectory = [NSHomeDirectory() stringByAppendingString:@"/Dropbox/AntBot/Data"];
    [settingsPlist setObject:defaultWorkingDirectory forKey:@"Working Directory"];
  }
  
  //Set the working directory text field's string to whatever the settings file says it should be.
  [workingDirectoryTextField setStringValue:[settingsPlist objectForKey:@"Working Directory"]];
}


/*
 * Called when the user hits the "start" button.
 * Checks state of all form elements, writes out the XML file containing trial parameters,
 * and (re)starts everything up.
 */
-(IBAction) start:(id)sender {
  
  //Read all the values from the parameter form.
  int port = [[portTextField stringValue] intValue];
  NSString* fusionType = [[fusionTypePopUp selectedItem] title];
  NSString* tagDistribution = [[tagDistributionPopUp selectedItem] title];
  int tagRadius = [[tagRadiusTextField stringValue] intValue];
  int tagCount = [[tagCountTextField stringValue] intValue];
  double boundsRadius = [[boundsRadiusTextField stringValue] doubleValue];
  NSString* trialType = [[trialTypePopUp selectedItem] title];
  NSString* environmentType = [[environmentTypePopUp selectedItem] title];
  BOOL validRun = ([validRunButton state]==NSOnState ? YES : NO);
  NSString* notes = [notesTextField stringValue];
  workingDirectory = [workingDirectoryTextField stringValue];
  
  //Write the desired workingDirectory to a plist file.
  [settingsPlist setObject:workingDirectory forKey:@"Working Directory"];
  NSString* settingsDirectory = [NSHomeDirectory() stringByAppendingString:@"/Library/Application Support/ABS"];
  [[NSFileManager defaultManager] createDirectoryAtPath:settingsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
  NSString* settingsPath = [settingsDirectory stringByAppendingString:@"/settings.plist"];
  [settingsPlist writeToFile:settingsPath atomically:NO];
  
  //Close any files that were previously open and get root directory.
  [[ABSWriter getInstance] closeAll];
  
  //Get formatted date, used to name the directories.
  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy_M_dd_ccc"];
  NSString* dateDirectory = [formatter stringFromDate:[NSDate date]];
  [formatter setDateFormat:@"HH_mm_ss"];
  NSString* timeDirectory = [NSString stringWithFormat:@"Trial_%@",[formatter stringFromDate:[NSDate date]]];
  
  NSString* dataRoot;
  dataRoot = [NSString stringWithString:workingDirectory];
  if(!validRun){dataRoot = [NSHomeDirectory() stringByAppendingString:@"/Desktop"];}
  
  //Concatenate everything together to get a complete directory path.
  dataDirectory = [NSString stringWithFormat:@"%@/raw/%@/%@",dataRoot,dateDirectory,timeDirectory];
  [[NSFileManager defaultManager] createDirectoryAtPath:dataDirectory withIntermediateDirectories:YES attributes:nil error:nil];
  NSString* filename = [dataDirectory stringByAppendingString:@"/trialXML.xml"];
  
  ABSWriter* writer = [ABSWriter getInstance];
  if(![writer isOpen:filename]) {
    if(![writer openFilename:filename]) {
      [self log:@"[CTR] Error creating the xml file.  Check permissions, paths, etc." withTag:LOG_TAG_PROBLEM];
    }
  }
  
  //Format a huge xml string containing fields for all the user parameters.
  NSString* params = [NSString stringWithFormat:
                      @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
                      "<trial>\n"
                      "   <fusion method> %@ </fusion method>\n"
                      "   <tag distribution> %@ </tag distribution>\n"
                      "   <tag radius> %d </tag radius>\n"
                      "   <total tags> %d </total tags>\n"
                      "   <bounds radius> %g </bounds radius>\n"
                      "   <trial type> %@ </trial type>\n"
                      "   <environment> %@ </environment>\n"
                      "   <valid> %d </valid>\n"
                      "</trial>\n"
                      "<robots>\n"
                      "   <robot names> %@ </robot names>\n"
                      "   <robot mac addr> %@ </robot mac addr>\n"
                      "</robots>\n"
                      "<info>\n"
                      "   <start time> %@ </start time>\n"
                      "   <end time> %@ </end time>\n"
                      "   <date> %@ </date>\n"
                      "</info>\n"
                      "<additional>\n"
                      "   <notes>\n"
                      "   %@\n"
                      "   </notes>\n"
                      "</additional>\n",
                      fusionType, tagDistribution, tagRadius, tagCount, boundsRadius, trialType, environmentType, validRun,
                      @"something here", @"something here",
                      @"something here", @"something here", dateDirectory,
                      notes];
  
  //Write the xml string to the file and close the file.
  [writer writeString:params toFile:filename];
  [writer closeFilename:filename];
  
  //Set up GA.
  /*[[ABSSimulationController getInstance] setDelegate:self];
  [[ABSSimulationController getInstance] addSimulationWithTag:@"MainSimulation"];
  ABSSimulation* sim = [[ABSSimulationController getInstance] simulationWithTag:@"MainSimulation"];
  [sim setGenerationCount:10];
  [sim setAntCount:1];
  [sim setColonyCount:10];
  [sim setUsesPheromones:YES];
  [sim setUsesSiteFidelity:YES];
  [sim setDistributionPowerlaw:1.];
  [sim setNumberOfSeeds:256];
  [[ABSSimulationController getInstance] startAll];*/
  
  //Set up robotDetails
  [ABSRobotDetails initializeWithWorkingDirectory:workingDirectory];
  
  //Set up GUI.
  [robotDisplayView setBoundsRadius:[NSNumber numberWithDouble:boundsRadius]];
  [robotDisplayView reset];
  
  //Set up pheromones.
  [[ABSPheromoneController getInstance] clearPheromones];
  pendingPheromones = [[NSMutableDictionary alloc] init];
  tagFound = [[NSMutableDictionary alloc] init];
  for(int i=0; i<tagCount; i+=1) {
    [tagFound setObject:[NSNumber numberWithBool:NO] forKey:[NSNumber numberWithInt:i]];
  }
  
  //Set up and start server.
  [server stop];
  server = [[ABSServer alloc] init];
  [server setDelegate:self];
  [server listenOnPort:port];
  
  //if everything went well, change button text.
  [startButton setTitle:@"Restart"];
}


/*
 * Called whenever something needs to be logged.
 * This logs to a graphical console, not XCode's console,
 * which allows the user to see messages when running in release
 * mode, for example.
 */
-(void) log:(NSString*)message withTag:(int)tag {
  //NSLog(@"%@",message);
  [toolController log:message withTag:tag];
}


/*
 * Delegate method for ABSServer.
 * Called whenever the server receives something.
 * Main processing that occurs when we receive a message
 * goes here.
 */
-(void) didReceiveMessage:(NSString*)message onStream:(NSInputStream*)theStream {
  
  /*
   * Current protocol
   * <MAC_addr>,<timestamp>,<x>,<y>,<event>,<event_details>
   */
  
  //This bit replaces the mac address with the robot name, for a more readable output.
  NSString* macAddress = [[message componentsSeparatedByString:@","] objectAtIndex:0];
  NSString* robotName = [ABSRobotDetails nameFromMacAddress:macAddress];
  int logTag = LOG_TAG_MESSAGE;
  if(robotName == nil){robotName = @"unknownRobot";}
  message = [message stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@%@",macAddress,@","] withString:[NSString stringWithFormat:@"%@%@",robotName,@","]];
  
  NSArray* messageExploded = [message componentsSeparatedByString:@","];
  
  /*
   * If we receive a single number, this is assumed to be a tag id.
   * We reply with either a 'yes' if a tag has been found or 'no' otherwise.
   */
  if([messageExploded count] == 1){
    NSNumber* tagId = [NSNumber numberWithInt:[message intValue]];
    NSString* reply = ([[tagFound objectForKey:tagId] boolValue]==YES) ? @"old" : @"new";
    [self log:[NSString stringWithFormat:@"[CTR] Received tag query for tag %@.  Replied with %@",tagId,reply] withTag:LOG_TAG_EVENT];
    for(ABSConnection* connection in [server connections]) {
      if([connection inputStream] == theStream) {
        [server send:reply toStream:[connection outputStream]];
        break;
      }
    }
    return;
  }
  else if([messageExploded count] < 4) {
    //Malformed message.
    [self log:[NSString stringWithFormat:@"[CTR] Malformed message: %@",message] withTag:LOG_TAG_PROBLEM];
    return;
  }
  
  //event is either "", "tag", or "home"
  NSString* event;
  if([messageExploded count]>=5){event = [messageExploded objectAtIndex:4];}
  else{event = @"";}
  
  //If the robot found a tag, add its position to the pending pheromones list.
  if([event isEqualToString:@"tag"]) {
    logTag=LOG_TAG_EVENT;
  
    NSNumber* x = [NSNumber numberWithInt:[[messageExploded objectAtIndex:2] intValue]];
    NSNumber* y = [NSNumber numberWithInt:[[messageExploded objectAtIndex:3] intValue]];
    NSNumber* tagId = [NSNumber numberWithInt:[[messageExploded objectAtIndex:5] intValue]];
    NSNumber* n = [NSNumber numberWithInt:[[messageExploded objectAtIndex:6] intValue]]; //neighboring tag count.
    
    [tagFound setObject:[NSNumber numberWithBool:YES] forKey:tagId];
    statTagCount = [NSNumber numberWithInt:[statTagCount intValue]+1];
    [toolController setTagCount:statTagCount];
    
    //Only leave a pheromone if there are other tags nearby.
    if(n > [NSNumber numberWithInt:1]) {
      NSArray* pheromoneData = [NSArray arrayWithObjects:x, y, tagId, nil];
      [pendingPheromones setObject:pheromoneData forKey:robotName];
    }
  }
  else if([event isEqualToString:@"home"]) {
    logTag = LOG_TAG_EVENT;
    
    //First, add a pheromone if it found a tag during its run and if neighboring tags were found nearby (uses pendingPheromone list):
    NSArray* pheromoneData = [pendingPheromones objectForKey:robotName];
    if(pheromoneData != nil) {
      NSNumber* x = [pheromoneData objectAtIndex:0];
      NSNumber* y = [pheromoneData objectAtIndex:1];
      NSNumber* tagId = [pheromoneData objectAtIndex:2];
      [[ABSPheromoneController getInstance] addPheromoneAtX:x andY:y forTag:tagId];
      [pendingPheromones removeObjectForKey:robotName];
    }
    else {
      //Tag had at most 1 neighbor, or no tag was found (rarely happens).
    }
    
    //Next, give the robot a (weighted) random pheromone (it chooses whether or not to use it client-side).
    NSArray* pheromonePosition = [[ABSPheromoneController getInstance] getPheromone];
    
    /*
     * Here, we find which client we are receiving from by looping through the list of clients
     * and checking for equality between the two inputStreams.
     * This is potentially inefficient, but shouldn't be much of a problem for a handful of robots.
     */
    if (pheromonePosition != nil) {
      for(ABSConnection* connection in [server connections]) {
        if([connection inputStream] == theStream) {
          [server send:[NSString stringWithFormat:@"%d,%d", [[pheromonePosition objectAtIndex:0] intValue], [[pheromonePosition objectAtIndex:1] intValue]] toStream:[connection outputStream]];
          break;
        }
      }
    }
  }
  
  //Update the GUI with the new robot position (need colors here?)
  NSNumber* x = [NSNumber numberWithDouble:[[messageExploded objectAtIndex:2] intValue]];
  NSNumber* y = [NSNumber numberWithDouble:[[messageExploded objectAtIndex:3] intValue]];
  
  //Start the elapsed-time clock if it isn't started yet.
  if([toolController startTime] == [NSDate distantFuture]){[toolController updateStartTime];}
  
  if(![robotName isEqualToString:@"unknownRobot"]) {
    [robotDisplayView setX:x andY:y andColor:[ABSRobotDetails colorFromName:robotName] forRobot:robotName];
  }
  
  //Finally, log the message to a file and the console.  See ABSWriter.
  NSString* filename = [NSString stringWithFormat:@"%@/%@.csv",dataDirectory,robotName];
  
  ABSWriter* writer = [ABSWriter getInstance];
  
  if(![writer isOpen:filename]) {
    if(![writer openFilename:filename]) {
      [self log:[NSString stringWithFormat:@"[CTR] Error opening %@ for writing.",filename] withTag:LOG_TAG_PROBLEM];
    }
  }
  
  [writer writeString:[NSString stringWithFormat:@"%@\n",message] toFile:filename];
  
  [self log:[NSString stringWithFormat:@"[CTR] Received: %@",message] withTag:logTag];
}


/*
 * Called whenever the pheromone controller places a pheromone.
 */
-(void) didPlacePheromoneAt:(NSPoint)position {
  [self log:[NSString stringWithFormat:@"[PHC] Placed pheromone at %f,%f.",position.x,position.y] withTag:LOG_TAG_EVENT];
  [toolController setPheromoneCount:[NSNumber numberWithInt:(int)[[[ABSPheromoneController getInstance] getAllPheromones] count]]];
}


/*
 * Called whenever the server needs something logged to the graphical console.
 */
-(void) didLogMessage:(NSString*)message withTag:(int)tag {
  [self log:message withTag:tag];
}


/*
 * Called whenever a simulation finishes.
 */
-(void) didFinishSimulationWithTag:(NSString*)tag {
  /*ABSSimulation* simulation = [[ABSSimulationController getInstance] simulationWithTag:tag];
  ABSSimulationColony* colony = [simulation bestColony];
  float bestParameter = [colony dirDevConst];*/
}

@end
