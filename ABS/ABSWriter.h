#import <Foundation/Foundation.h>

@interface ABSWriter : NSObject {
    NSMutableDictionary* files; //A mapping of filenames to filehandles.
}

+(ABSWriter*)getInstance;

-(BOOL) openFilename:(NSString*)filename;
-(void) closeFilename:(NSString*)filename;
-(BOOL) writeString:(NSString*)string toFile:(NSString*)filename;
-(BOOL) isOpen:(NSString*)filename;
-(void) closeAll;

@end
