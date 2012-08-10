#import <Foundation/Foundation.h>

@interface NSObject(ABSGAControllerNotifications)
-(void) didFinishGA:(NSArray*)returnValues;
@end

@interface ABSGAController : NSObject {
    NSObject* delegate;
    NSArray* returnValues;
    NSThread* GAThread;
}

+(ABSGAController*) getInstance;

@property (nonatomic,retain) NSObject* delegate;
@property (nonatomic,retain) NSArray* returnValues;
@property (nonatomic,retain) NSThread* GAThread;

-(void) start;
-(void) stop;

@end
