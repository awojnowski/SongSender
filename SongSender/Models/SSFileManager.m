//
//  SSFileManager.m
//  SongSender
//
//  Created by Aaron Wojnowski on 2014-05-07.
//  Copyright (c) 2014 Aaron. All rights reserved.
//

#import "SSFileManager.h"

@implementation SSFileManager

+(NSString *)documentsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
    
}

#pragma mark - Temporary Directory

+(NSString *)temporarySaveDirectory {
    
    NSString *directory = [self documentsDirectory];
    directory = [directory stringByAppendingPathComponent:@"tmp"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
        
        [self createDirectory:directory];
        
    }
    
    return directory;
    
}

+(NSURL *)temporarySaveDirectoryURL {
    
    return [NSURL fileURLWithPath:[self temporarySaveDirectory]];
    
}
    
+(NSString *)temporaryFilePathWithName:(NSString *)name {
    
    return [[self temporarySaveDirectory] stringByAppendingPathComponent:name];
    
}

+(NSURL *)temporaryFileURLWithName:(NSString *)name {
    
    return [NSURL fileURLWithPath:[self temporaryFilePathWithName:name]];
    
}

#pragma mark - Directory Management

+(void)createDirectory:(NSString *)directory {
    
    [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:nil];
    
}

+(void)wipeTemporarySaveDirectory {
    
    [[NSFileManager defaultManager] removeItemAtPath:[self temporarySaveDirectory] error:nil];
    
}

@end
