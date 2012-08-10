#import "ABSGAController.h"
#import "GA.h"

@implementation ABSGAController

@synthesize returnValues, GAThread, delegate;

+(ABSGAController*) getInstance {
    static ABSGAController* instance;
    
    @synchronized(self) {
        if(!instance) {
            instance = [[ABSGAController alloc] init];
        }
        return instance;
    }
}

-(void) start {
    NSLog(@"Starting GA");
    
    returnValues = nil;
    
    GAThread = [[NSThread alloc] initWithTarget:self selector:@selector(GAThreadMain) object:nil];
    [GAThread start];
    
    [self performSelector:@selector(runGA:) onThread:GAThread withObject:nil waitUntilDone:NO];
}

-(void) GAKeepAlive {
    [self performSelector:@selector(GAKeepAlive) withObject:nil afterDelay:60];    
}

-(void) GAThreadMain {
    //Keep alives are put in so the thread doesn't immediately shut down (apparently we have to trick the run loop).
    [self performSelector:@selector(GAKeepAlive) withObject:nil afterDelay:60];
    BOOL done = NO;
    
    while(!done) {
        SInt32 result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, YES);
        if ((result == kCFRunLoopRunStopped) || (result == kCFRunLoopRunFinished)){done = YES;}
    }
}

-(void) runGA:(id)object {
    returnValues = mainLoop();
    
    /*
     * Here I'm backing out of GAThread and returning to the main thread before I issue the delegate callback.
     * This might be unnecessary, but I'm thinking it's more versatile (if I want to process anything on
     * the main thread before starting the GA again or something).
     */
    [self performSelectorOnMainThread:@selector(GADone:) withObject:returnValues waitUntilDone:NO];
}

-(void) GADone:(id)data {
    if([[self delegate] respondsToSelector:@selector(didFinishGA:)]) {
        [[self delegate] didFinishGA:returnValues];
    }
    [self performSelector:@selector(runGA:) onThread:GAThread withObject:nil waitUntilDone:NO];
}

-(void) stop {
    NSLog(@"Stopping GA");
    
    //Need more stuff here (how to properly stop thread?)
}

@end
