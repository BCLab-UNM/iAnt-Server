#import <Cocoa/Cocoa.h>

@class ABSWriter;
@class ABSRobotDisplayView;

@interface NSObject(ABSServerNotifications)
  -(void) didReceiveMessage:(NSString*)message onStream:(NSInputStream*)theStream;
  -(void) didLogMessage:(NSString*)message withTag:(int)tag;
@end

@interface ABSServer : NSObject <NSStreamDelegate,NSNetServiceDelegate> {
  NSObject* delegate;
	CFSocketRef listenSocket;
  NSNetService* netService;
  NSMutableArray* rxBuffer;
}

-(BOOL) listenOnPort:(int)port;
-(void) send:(NSString*)message toStream:(NSOutputStream*)stream;
-(void) stream:(NSStream *)theStream handleEvent:(NSStreamEvent)eventCode;
-(NSString*) getMessage;
-(void) log:(NSString*)message withTag:(int)tag;
-(void) stop;

@property (nonatomic,retain) NSObject* delegate;
@property (nonatomic,retain) NSMutableArray* connections;
@property (nonatomic,retain) NSMutableDictionary* namedConnections;

@end
