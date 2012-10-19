#import <Foundation/Foundation.h>

@interface ABSConnection : NSObject {
  
}

@property (readwrite, nonatomic, assign) NSInputStream* inputStream;
@property (readwrite, nonatomic, assign) NSOutputStream* outputStream;
@property (readwrite, nonatomic, assign) NSString* ip;
@property (readwrite, nonatomic, assign) int port;

@end
