#import "ABSToolController.h"

@interface ABSToolController ()

@end

@implementation ABSToolController

@synthesize console;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) loadView {

}

-(void) log:(NSString*)message {
    [console setStringValue:[NSString stringWithFormat:@"%@%@\n",[console stringValue],message]];
    //[console setFrame:CGRectMake(console.frame.origin.x,console.frame.origin.y,console.frame.size.width,console.frame.size.height+10)];
}

@end
