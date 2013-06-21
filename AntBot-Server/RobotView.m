#import <CoreFoundation/CoreFoundation.h>
#import "PheromoneController.h"
#import "RobotView.h"
#import "Settings.h"

@implementation RobotView

-(BOOL) isFlipped {return YES;}

-(id) initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
		startTime = [NSDate date];
        drawTimer = nil;
        
        [self translateOriginToPoint:NSMakePoint(200, 200)];
        [self setBounds:NSMakeRect(-210, -210, 420, 420)];
    }
    
    return self;
}

-(void) addRobot:(NSString*)robotName {
	double currentTime = [startTime timeIntervalSinceNow] * -1;
	
    [robots setObject:[NSMutableArray arrayWithObjects:
                       [NSNumber numberWithDouble:0.0],
                       [NSNumber numberWithDouble:0.0],
                       [NSNumber numberWithDouble:0.0],
					   [NSNumber numberWithDouble:currentTime],
                       nil]
               forKey:robotName];
    [self redraw];
}


//TODO change this to be calculated from the message: selector
-(void) setX:(NSNumber*)x andY:(NSNumber*)y forRobot:(NSString *)robotName {
	double currentTime = [startTime timeIntervalSinceNow] * -1;

    if([robots objectForKey:robotName] == nil){[self addRobot:robotName];}
    
    double xPrevious = [[[robots objectForKey:robotName] objectAtIndex:0] doubleValue],
           yPrevious = [[[robots objectForKey:robotName] objectAtIndex:1] doubleValue],
    dx = [x doubleValue] - xPrevious,
    dy = [y doubleValue] - yPrevious;
    
    NSNumber* direction = [NSNumber numberWithDouble:atan2(dy,dx)];
    
    [robots setObject:[NSMutableArray arrayWithObjects:x, y, direction, currentTime, nil] forKey:robotName];
    
    [self redraw];
}

-(void) redraw {
    if(drawTimer == nil) {
        drawTimer = [NSTimer scheduledTimerWithTimeInterval:.5f target:self selector:@selector(drawTimerDidFire:) userInfo:nil repeats:NO];
    }
}

-(void) drawTimerDidFire:(id)sender {
    [drawTimer invalidate];
    drawTimer = nil;
    [self setNeedsDisplay:YES];
}

-(void) drawRect:(NSRect)dirtyRect {
	Settings* settings = [Settings getInstance];
	double currentTime = [startTime timeIntervalSinceNow] * -1;

    //Clear view to black.
    [[NSColor blackColor] set];
    NSRectFill(dirtyRect);
    
    //Draw the virtual fence.
    [[NSColor grayColor] set];
    NSBezierPath* boundsPath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-200, -200, 400, 400)];
    [boundsPath stroke];
    
    //Draw the pheromones.
    for(PhysicalPheromone* pheromone in [[PheromoneController getInstance] getAllPheromones]) {
        NSBezierPath* pheromoneLine = [[NSBezierPath alloc] init];
        [pheromoneLine moveToPoint:NSMakePoint(0, 0)];
        double pixelsInMeter;
        if([settings boundsRadius] > 0){pixelsInMeter = 400.0 / ([settings boundsRadius] * 2);}
        else{pixelsInMeter = 0.0;}
        double x = ([pheromone.x doubleValue] / 100.0) * pixelsInMeter;
        double y = ([pheromone.y doubleValue] / 100.0) * pixelsInMeter;
        [pheromoneLine lineToPoint:NSMakePoint(x, y)];
        
        double pheromoneValue = [pheromone.n doubleValue];
        if([pheromone.nMax doubleValue] != 0.0) {
            pheromoneValue /= [pheromone.nMax doubleValue];
        }
        [[[NSColor greenColor] colorWithAlphaComponent:.5 + (pheromoneValue / 2.0)] set];
        [pheromoneLine setLineWidth:(4*pheromoneValue)];
        [pheromoneLine stroke];
    }
    
    for(NSString* key in robots) {
        
        //Only draw robots that we've heard from recently:
        if(currentTime - [[[robots objectForKey:key] objectAtIndex:3] doubleValue] < 90) {
            
            double x,y,direction;
            NSColor* color;
            x = [[[robots objectForKey:key] objectAtIndex:0] doubleValue];
            y = [[[robots objectForKey:key] objectAtIndex:1] doubleValue];
            direction=[[[robots objectForKey:key] objectAtIndex:2] doubleValue];
            color = [[settings robotColors] objectForKey:key];

            //Convert the robot's current position from cm to px (can we do this in setX:andY: ?).
            double pixelsInMeter;
            if([settings boundsRadius] > 0){pixelsInMeter = 400.0 / ([settings boundsRadius] * 2);}
            else{pixelsInMeter = 0.0;}
            
            x = (x / 100.0) * pixelsInMeter;
            y = (y / 100.0) * pixelsInMeter;
            
            //Draw a circle at the robot's current position.
            NSRect rect = NSMakeRect(x - 8, y - 8, 16, 16);
            NSBezierPath* path = [NSBezierPath bezierPathWithOvalInRect:rect];
            
            [color set];
            [path fill];
            [[NSColor whiteColor] set];
            [path stroke];
            
            NSBezierPath* directionPath = [[NSBezierPath alloc] init];
            [directionPath moveToPoint:NSMakePoint(x,y)];
            [directionPath lineToPoint:NSMakePoint(x+(cos(direction)*8),y+(sin(direction)*8))];
            [[NSColor whiteColor] set];
            [directionPath stroke];
        }
    }
}

//Zoom in and out with pinching.
-(void) magnifyWithEvent:(NSEvent*) event {
    double m = [event magnification];
    double x = self.bounds.origin.x / (1 + m);
    [self setBounds:NSMakeRect(x, x, x * -2, x * -2)];
}

@end
