#import "ABSServer.h"
#import "ABSConnection.h"
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

@implementation ABSServer

@synthesize connections;
@synthesize delegate;

/* 
 * Opens a socket for listening on the specified port.
 */
-(BOOL) listenOnPort:(int)port {
    CFSocketContext context = { 0, (__bridge void*)self, NULL, NULL, NULL };
    
	//Create the socket.  The constants here indicate that it's a TCP socket (vs. UDP).
	listenSocket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)&socketAcceptCallBack, &context);
	if(!listenSocket) {
        [self log:@"[SRV] Couldn't create socket."];
		return NO;
	}
	
	/*
	 * Here, we check if the address is already in use.
	 * If there is an idle socket listening on the port we want to use,
	 * (i.e. the last run crashed and the socket didn't get cleaned up properly),
	 * we set socket options here to reuse the port, so we don't get "address in use" errors.
	 */
	int reuse = true;
	int fileDescriptor = CFSocketGetNative(listenSocket);
	if(setsockopt(fileDescriptor, SOL_SOCKET, SO_REUSEADDR, (void*)&reuse, sizeof(int)) != 0) {
		[self log:@"[SRV] Couldn't set socket options."];
		return NO;
	}
    
	/*
	 * Lower level stuff to set the address and port of the socket.
	 */
	struct sockaddr_in address;
	memset(&address, 0, sizeof(address));
	address.sin_len = sizeof(address);
	address.sin_family = AF_INET;
	address.sin_addr.s_addr = htonl(INADDR_ANY);
	address.sin_port = htons(port);
	CFDataRef addressData = CFDataCreate(NULL, (const UInt8 *)&address, sizeof(address));
	
	//Finally, attempt to start listening.
	if(CFSocketSetAddress(listenSocket, addressData) != kCFSocketSuccess)
    {
        CFRelease(addressData);
		[self log:@"[SRV] Couldn't bind socket."];
		return NO;
	}
    CFRelease(addressData);
	
    CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, listenSocket, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    CFRelease(source);
    
    [self log:[NSString stringWithFormat:@"[SRV] Listening on port %d", port]];
    
    connections = [[NSMutableArray alloc] init];
    
    /*netService = [[NSNetService alloc] initWithDomain:@"" type:@"_abs._tcp." name:@"ABS" port:2223];
    [netService setDelegate:self];
    [netService publish];*/
    
	return YES;
}


-(void) netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
    [self log:@"[SRV] Error publishing Bonjour."];
}


/*
 * Callback for receiving a connection.
 * Here we create higher level NSStreams for the client
 * and schedule them on a runloop.
 */
static void socketAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    
    /*
     * This is a c function, thus there is no 'self' variable.
     * We declare self in the socket context when we open the listenSocket,
     * and read it in here using the info parameter.
     * Essentially this allows us to reference the server's instance variables even though we're in a static function.
     */
    ABSServer* self = (__bridge ABSServer*) info;
    
    //There are several different socket events we can receive.  The only interesting one for our purposes is receiving a connection.
    if(type == kCFSocketAcceptCallBack) {
        
        //This next chunk retrieves the IP and port from the new client.
        CFSocketNativeHandle socketHandle = *(CFSocketNativeHandle*) data;
        
        uint8_t name[SOCK_MAXADDRLEN];
        socklen_t nameLen = sizeof(name);
        struct sockaddr *addr = (struct sockaddr*)name;
        NSString* ip;
        int port = 0;
        if(0 == getpeername(socketHandle, addr, &nameLen)) {
            const struct sockaddr_in* addr_in = (const struct sockaddr_in*)addr;
            const uint8* ipInt = (const uint8*)&addr_in->sin_addr.s_addr;
            ip = [NSString stringWithFormat:@"%u.%u.%u.%u",(unsigned)ipInt[0],(unsigned)ipInt[1],(unsigned)ipInt[2],(unsigned)ipInt[3]];
            port = ntohs(addr_in->sin_port);
            [self log:[NSString stringWithFormat:@"[SRV] New client: %@:%d",ip,port]];
        }
        else {
            [self log:@"[SRV] Can't get IP/Port from client."];
        }
        
        //Create higher-level streams used to send/receive data.
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, socketHandle, &readStream, &writeStream);
        
        //Create a new ABSConnection, which is just a wrapper class that holds the ip, port, and stream variables of the client.
        ABSConnection* connection = [[ABSConnection alloc] init];
        
        [connection setInputStream:(__bridge NSInputStream*)readStream];
        [connection setOutputStream:(__bridge NSOutputStream*)writeStream];
        [connection setIp:ip];
        [connection setPort:port];
        
        if([connection inputStream] && [connection outputStream]) {
            [[connection inputStream] setDelegate:self];
            [[connection outputStream] setDelegate:self];
            
            //Scheduling streams in a run-loop basically makes the streams non-blocking.
            [[connection inputStream] scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [[connection outputStream] scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            
            [[connection inputStream] open];
            [[connection outputStream] open];
            
            [self->connections addObject:connection];
        }
        else {
            [self log:@"[SRV] Error creating input and output streams."];
        }
    }
}


/*
 * Sends a string to a specific outputStream.
 */
-(void) send:(NSString*)message toStream:(NSOutputStream*)stream {
    [self log:[NSString stringWithFormat:@"[SRV] Sending %@",message]];
    NSData* data = [[NSData alloc] initWithData:[message dataUsingEncoding:NSASCIIStringEncoding]];
    [stream write:[data bytes] maxLength:[data length]];
}


/*
 * Callback for receiving messages from clients.
 */
-(void) stream:(NSStream *)theStream handleEvent:(NSStreamEvent)eventCode {
    switch(eventCode) {
        case NSStreamEventOpenCompleted:
			//NSLog(@"Stream opened");
			break;
            
        case NSStreamEventHasBytesAvailable:
            
            //Make sure the stream is an inputStream before trying to receive data.
            if([theStream isKindOfClass:[NSInputStream class]]) {
                NSInputStream* theInputStream = (NSInputStream*)theStream; //ugh, compilers are stupid
                uint8_t buffer[1024];
                long len;
                NSString* str = @"";
                
                /*
                 * In the case that the message received is greater than 1024 characters,
                 * We have to read each 1024-char chunk in and append it onto a string to get
                 * the full message.  Otherwise, weird truncation happens.
                 */
                while([theInputStream hasBytesAvailable]) {
                    len = [theInputStream read:buffer maxLength:sizeof(buffer)];
                    if(len) {
                        NSString* chunk = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        str = [NSString stringWithFormat:@"%@%@",str,chunk];
                    }
                }
                
                //If no one's around to receive the message, don't bother.
                if([[self delegate] respondsToSelector:@selector(didReceiveMessage:onStream:)]) {
                        
                    /*
                     * Sometimes, several lines will be received at once (due to buffering and such).
                     * Instead of dealing with message sizes/delimiters, this is a cheap hack
                     * which explodes the message at newlines and processes each one individually.
                     */
                    NSArray* messages = [str componentsSeparatedByString:@"\n"];
                    
                    for(__strong NSString* message in messages){
                        if([message length]>0){
                            [[self delegate] didReceiveMessage:message onStream:theInputStream];
                        }
                    }
                }
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            //NSLog(@"Server has space available for writing");
            break;
            
		case NSStreamEventErrorOccurred:
			[self log:@"[SRV] Can not connect to the host!"];
			break;
            
        //If remote host closes the connection, close stream on this end and remove from runloop.
		case NSStreamEventEndEncountered:
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			break;
            
		default:
            break;
    }
}

-(void) log:(NSString*)message {
    if([[self delegate] respondsToSelector:@selector(didLogMessage:)]) {
        [[self delegate] didLogMessage:message];
    }
}

-(void) stop {
    int native = CFSocketGetNative(listenSocket);
    close(native);
    CFSocketInvalidate(listenSocket);
    CFRelease(listenSocket);
    for(ABSConnection* connection in connections) {
        [[connection inputStream] close];
        [[connection inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [[connection outputStream] close];
        [[connection outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    [connections removeAllObjects];
}

@end
