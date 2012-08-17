#import "ABSRobotDisplayView.h"
#import "ABSPheromoneController.h"
#import <CoreFoundation/CoreFoundation.h>

@implementation ABSRobotDisplayView

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
        
        [self translateOriginToPoint:NSMakePoint(200,200)];
        [self setBounds:NSMakeRect(-210,-210,420,420)];
    }
    
    return self;
}

-(void) addRobot:(NSString*)robotName {
    [robots setObject:[NSMutableArray arrayWithObjects:[NSNumber numberWithDouble:0.0], [NSNumber numberWithDouble:0.0], [NSColor blackColor], [[NSBezierPath alloc] init], nil] forKey:robotName];
    NSBezierPath* path = [[robots objectForKey:robotName] objectAtIndex:3];
    [path moveToPoint:NSMakePoint(0.0,0.0)];
    [self setNeedsDisplay:YES];
}

-(void) setX:(NSNumber*)x andY:(NSNumber*)y andColor:(NSColor*)color forRobot:(NSString *)robotName {
    if([robots objectForKey:robotName] == nil) {
        [self addRobot:robotName];
    }
    
    NSBezierPath* path = [[robots objectForKey:robotName] objectAtIndex:3];
    double pixelsInMeter;
    if([[self boundsRadius] doubleValue]>0){pixelsInMeter = 400.0/([[self boundsRadius] doubleValue]*2);}
    else{pixelsInMeter = 0.0;}
    [path lineToPoint:NSMakePoint(([x doubleValue]/100.0)*pixelsInMeter,([y doubleValue]/100.0)*pixelsInMeter)];
    
    if(path.elementCount >= 500) {
        int n=path.elementCount;
        NSBezierPath* newPath = [[NSBezierPath alloc] init];
        int i;
        for(i=((n-1)-300); i<n; i+=1) {
            NSPoint point[1];
            [path elementAtIndex:i associatedPoints:point];
            if(i == (n-1)-300) {
                [newPath moveToPoint:point[0]];
            }
            else {
                [newPath lineToPoint:point[0]];
            }
        }
        path = newPath;
    }
    
    [robots setObject:[NSMutableArray arrayWithObjects:x, y, color, path, nil] forKey:robotName];
    
    [self setNeedsDisplay:YES];
}

-(void) reset {
    [robots removeAllObjects];
    [self translateOriginToPoint:NSMakePoint(200,200)];
    [self setBounds:NSMakeRect(-210,-210,420,420)];
    [self setNeedsDisplay:YES];
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
    for(Pheromone* pheromone in [[ABSPheromoneController getInstance] getAllPheromones]) {
        NSBezierPath* pheromoneLine = [[NSBezierPath alloc] init];
        [pheromoneLine moveToPoint:NSMakePoint(0,0)];
        double pixelsInMeter;
        if([[self boundsRadius] doubleValue]>0){pixelsInMeter = 400.0/([[self boundsRadius] doubleValue]*2);}
        else{pixelsInMeter = 0.0;}
        double x = ([pheromone.x doubleValue]/100.0)*pixelsInMeter;
        double y = ([pheromone.y doubleValue]/100.0)*pixelsInMeter;
        [pheromoneLine lineToPoint:NSMakePoint(x,y)];
        [[[NSColor greenColor] colorWithAlphaComponent:.5+([pheromone.n doubleValue]/2.0)] set];
        [pheromoneLine setLineWidth:(4*[pheromone.n doubleValue])];
        [pheromoneLine stroke];
    }
    
    for(NSString* key in robots) {
        double x,y;
        NSColor* color;
        x = [[[robots objectForKey:key] objectAtIndex:0] doubleValue];
        y = [[[robots objectForKey:key] objectAtIndex:1] doubleValue];
        color = [NSColor whiteColor];//[[robots objectForKey:key] objectAtIndex:2];
        
        //Draw the robot's trail.  The path points have already been converted from cm to px.
        NSBezierPath* trailPath = [[robots objectForKey:key] objectAtIndex:3];
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
        [trailPath stroke];
        
        //Convert the robot's current position from cm to px (can we do this in setX:andY: ?).
        double pixelsInMeter;
        if([[self boundsRadius] doubleValue]>0){pixelsInMeter = 400.0/([[self boundsRadius] doubleValue]*2);}
        else{pixelsInMeter = 0.0;}
        
        x = (x/100.0)*pixelsInMeter;
        y = (y/100.0)*pixelsInMeter;
        
        //Here, I checked if a robot went outside the view, and resized accordingly.  Took it out when pinch commands were added.
        /*if((x-8) < self.bounds.origin.x) {
            double newSize=self.bounds.size.width+(self.bounds.origin.x-(x-8));
            [self setBounds:NSMakeRect(x-8,self.bounds.origin.y,newSize,newSize)];
        }
        if((y-8) < self.bounds.origin.y) {
            double newSize=self.bounds.size.height+(self.bounds.origin.y-(y-8));
            [self setBounds:NSMakeRect(self.bounds.origin.x,y-8,newSize,newSize)];
        }
        if((x+8) > self.bounds.size.width+self.bounds.origin.x) {
            double newSize=(x+8)-self.bounds.origin.x;
            [self setBounds:NSMakeRect(self.bounds.origin.x,self.bounds.origin.y,newSize,newSize)];
        }
        if((y+8) > self.bounds.size.height+self.bounds.origin.y) {
            double newSize=(y+8)-self.bounds.origin.y;
            [self setBounds:NSMakeRect(self.bounds.origin.x,self.bounds.origin.y,newSize,newSize)];
        }*/
        
        //Draw a circle at the robot's current position.
        NSRect rect = NSMakeRect(x-8,y-8,16,16);
        NSBezierPath* path = [NSBezierPath bezierPathWithOvalInRect:rect];
        
        color=[[robots objectForKey:key] objectAtIndex:2];
        [color set];
        [path fill];
        [[NSColor whiteColor] set];
        [path stroke];
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
