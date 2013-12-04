#import <Cocoa/Cocoa.h>

@class Writer;
@class RobotView;

@interface Connection : NSObject

@property NSInputStream* inputStream;
@property NSOutputStream* outputStream;
@property NSString* ip;
@property int port;

@end


@interface NSObject(ABSServerNotifications)
  -(void) didReceiveMessage:(NSString*)message onStream:(NSInputStream*)theStream;
  -(void) didLogMessage:(NSString*)message withTag:(int)tag;
@end


@interface Server : NSObject <NSStreamDelegate,NSNetServiceDelegate> {
	NSObject* delegate;
	CFSocketRef listenSocket;
	NSNetService* netService;
	NSMutableArray* rxBuffer;
}

-(void) start:(NSNotification*)notification;
-(BOOL) listenOnPort:(int)port;
-(void) send:(NSString*)message toStream:(NSOutputStream*)stream;
-(void) send:(NSString*)message toNamedConnection:(NSString*)name;
-(void) stream:(NSStream *)theStream handleEvent:(NSStreamEvent)eventCode;
-(NSString*) getMessage;
-(void) log:(NSString*)message withTag:(int)tag;
-(void) stop;

@property (nonatomic,retain) NSObject* delegate;
@property (nonatomic,retain) NSMutableArray* connections;
@property (nonatomic,retain) NSMutableDictionary* namedConnections;

@end
