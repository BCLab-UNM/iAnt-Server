#import "RobotDisplayView.h"
#import "PheromoneController.h"
#import <CoreFoundation/CoreFoundation.h>

@implementation RobotDisplayView

@synthesize boundsRadius;

-(BOOL) isFlipped {
    return YES;
}

-(id) initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        robots = [[NSMutableDictionary alloc] init];
        pheromones = [[NSMutableDictionary alloc] init];
        startTime = [NSDate date];
        drawTimer = nil;
        
        [self translateOriginToPoint:NSMakePoint(200,200)];
        [self setBounds:NSMakeRect(-210,-210,420,420)];
    }
    
    return self;
}

-(double) currentTime {
    return [startTime timeIntervalSinceNow] * -1; //multiply by -1000 for milliseconds, -1000000 for microseconds, -1 for seconds, etc.
}

-(void) addRobot:(NSString*)robotName {
    [robots setObject:[NSMutableArray arrayWithObjects:
                       [NSNumber numberWithDouble:0.0],
                       [NSNumber numberWithDouble:0.0],
                       [NSNumber numberWithDouble:0.0],
                       [NSColor blackColor],
                       [NSNumber numberWithDouble:[self currentTime]],
                       nil]
               forKey:robotName];
    [self redraw];
}

-(void) setX:(NSNumber*)x andY:(NSNumber*)y andColor:(NSColor*)color forRobot:(NSString *)robotName {
    if([robots objectForKey:robotName] == nil) {
        [self addRobot:robotName];
    }
    
    double xPrevious = [[[robots objectForKey:robotName] objectAtIndex:0] doubleValue],
    yPrevious = [[[robots objectForKey:robotName] objectAtIndex:1] doubleValue],
    dx = [x doubleValue]-xPrevious,
    dy = [y doubleValue]-yPrevious;
    
    NSNumber* direction = [NSNumber numberWithDouble:atan2(dy,dx)];
    NSNumber* lastUpdated = [NSNumber numberWithDouble:[self currentTime]];
    
    [robots setObject:[NSMutableArray arrayWithObjects:x, y, direction, color, lastUpdated, nil] forKey:robotName];
    
    [self redraw];
}

-(void) removeRobot:(NSString*)robotName {
    [robots removeObjectForKey:robotName];
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

-(void) reset {
    [robots removeAllObjects];
    [self translateOriginToPoint:NSMakePoint(200,200)];
    [self setBounds:NSMakeRect(-210,-210,420,420)];
    [self redraw];
}

-(void) drawRect:(NSRect)dirtyRect {
    //Clear view to black.
    [[NSColor blackColor] set];
    NSRectFill(dirtyRect);
    
    //Draw the virtual fence.
    [[NSColor grayColor] set];
    NSBezierPath* boundsPath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-200,-200,400,400)];
    [boundsPath stroke];
    
    //Draw the pheromones.
    for(Pheromone* pheromone in [[PheromoneController getInstance] getAllPheromones]) {
        NSBezierPath* pheromoneLine = [[NSBezierPath alloc] init];
        [pheromoneLine moveToPoint:NSMakePoint(0,0)];
        double pixelsInMeter;
        if([[self boundsRadius] doubleValue]>0){pixelsInMeter = 400.0/([[self boundsRadius] doubleValue]*2);}
        else{pixelsInMeter = 0.0;}
        double x = ([pheromone.x doubleValue]/100.0)*pixelsInMeter;
        double y = ([pheromone.y doubleValue]/100.0)*pixelsInMeter;
        [pheromoneLine lineToPoint:NSMakePoint(x,y)];
        
        double pheromoneValue = [pheromone.n doubleValue];
        if ([pheromone.nMax doubleValue] != 0.0) {
            pheromoneValue /= [pheromone.nMax doubleValue];
        }
        [[[NSColor greenColor] colorWithAlphaComponent:.5+(pheromoneValue/2.0)] set];
        [pheromoneLine setLineWidth:(4*pheromoneValue)];
        [pheromoneLine stroke];
    }
    
    for(NSString* key in robots) {
        
        //Only draw robots that we've heard from recently:
        if([self currentTime] - [[[robots objectForKey:key] objectAtIndex:4] doubleValue] < 90) {
            
            double x,y,direction;
            NSColor* color;
            x = [[[robots objectForKey:key] objectAtIndex:0] doubleValue];
            y = [[[robots objectForKey:key] objectAtIndex:1] doubleValue];
            direction=[[[robots objectForKey:key] objectAtIndex:2] doubleValue];
            color = [[robots objectForKey:key] objectAtIndex:3];
            
            //Draw the robot's trail.  The path points have already been converted from cm to px.
            /*NSBezierPath* trailPath = [[robots objectForKey:key] objectAtIndex:3];
             int n = trailPath.elementCount;
             int i;
             int trailLength = 25;
             for(i=(n-1); i>=MAX(n-(trailLength+1),1); i--) {
             NSPoint point[1];
             NSBezierPath* tempPath = [[NSBezierPath alloc] init];
             [trailPath elementAtIndex:i associatedPoints:point];
             [tempPath moveToPoint:point[0]];
             [trailPath elementAtIndex:i-1 associatedPoints:point];
             [tempPath lineToPoint:point[0]];
             int idx = trailLength-(n-(i+1));
             [[color colorWithAlphaComponent:((idx+1)/((float)trailLength))] set];
             [tempPath setLineWidth:(1.f+(2*(idx/((float)trailLength))))];
             [tempPath stroke];
             }
             CGFloat dashStyle[2];
             dashStyle[0]=4.0;
             dashStyle[1]=2.0;
             [[color colorWithAlphaComponent:.35f] set];
             [trailPath setLineDash:dashStyle count:2 phase:0.0];
             [trailPath setLineWidth:.75f];
             [trailPath stroke];*/
            
            //Convert the robot's current position from cm to px (can we do this in setX:andY: ?).
            double pixelsInMeter;
            if([[self boundsRadius] doubleValue]>0){pixelsInMeter = 400.0/([[self boundsRadius] doubleValue]*2);}
            else{pixelsInMeter = 0.0;}
            
            x = (x/100.0)*pixelsInMeter;
            y = (y/100.0)*pixelsInMeter;
            
            //Draw a circle at the robot's current position.
            NSRect rect = NSMakeRect(x-8,y-8,16,16);
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
    double x = self.bounds.origin.x/(1+m);
    [self setBounds:NSMakeRect(x,x,x*-2,x*-2)];
}

-(void) dealloc {
    
}

@end