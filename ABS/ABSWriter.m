#import "ABSWriter.h"

@implementation ABSWriter

+(ABSWriter*) getInstance {
  static ABSWriter* instance;
  
  @synchronized(self) {
    if(!instance) {
      instance = [[ABSWriter alloc] init];
    }
    return instance;
  }
}

-(id) init {
  self = [super init];
  files = [[NSMutableDictionary alloc] init];
  return self;
}

-(BOOL) openFilename:(NSString*)filename {
  NSFileManager* fileManager = [NSFileManager defaultManager];
  
  [fileManager createFileAtPath:filename contents:nil attributes:nil];
  
  NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath:filename];
  
  if(fileHandle == nil){return NO;}
  else {
    [files setObject:fileHandle forKey:filename];
    return YES;
  }
}

-(void) closeFilename:(NSString*)filename {
  [[files objectForKey:filename] closeFile];
  [files removeObjectForKey:filename];
}

-(BOOL) writeString:(NSString*)string toFile:(NSString*)filename {
  NSFileHandle* fileHandle = (NSFileHandle*)[files objectForKey:filename];
  
  if(fileHandle == nil){return NO;}
  else {
    [fileHandle writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    return YES;
  }
}

-(BOOL) isOpen:(NSString*)filename {
  if([files objectForKey:filename] != nil){return YES;}
  return NO;
}

-(void) closeAll {
  NSEnumerator* enumerator = [files keyEnumerator];
  id key;
  while(key = [enumerator nextObject]) {
    [[files objectForKey:key] closeFile];
  }
}

@end
