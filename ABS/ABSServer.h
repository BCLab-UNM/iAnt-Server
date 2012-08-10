#import <Cocoa/Cocoa.h>

@class ABSWriter;
@class ABSRobotDisplayView;

@interface NSObject(ABSServerNotifications)
-(void)didReceiveMessage:(NSString*)message onStream:(NSInputStream*)theStream;
@end

@interface ABSServer : NSObject <NSStreamDelegate,NSNetServiceDelegate> {
    NSObject* delegate;
	CFSocketRef listenSocket;
    NSMutableArray* connections;
    NSNetService* netService;
}

-(BOOL) listenOnPort:(int)port;
-(void) send:(NSString*)message toStream:(NSOutputStream*)stream;
-(void) stream:(NSStream *)theStream handleEvent:(NSStreamEvent)eventCode;
-(void) stop;

@property (nonatomic,retain) NSObject* delegate;
@property (nonatomic,retain) NSMutableArray* connections;

@end
