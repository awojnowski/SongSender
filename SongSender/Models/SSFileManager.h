//
//  SSFileManager.h
//  SongSender
//
//  Created by Aaron Wojnowski on 2014-05-07.
//  Copyright (c) 2014 Aaron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSFileManager : NSObject

+(NSString *)documentsDirectory;

+(NSString *)temporarySaveDirectory;
+(NSURL *)temporarySaveDirectoryURL;
+(NSString *)temporaryFilePathWithName:(NSString *)name;
+(NSURL *)temporaryFileURLWithName:(NSString *)name;

+(void)createDirectory:(NSString *)directory;
+(void)wipeTemporarySaveDirectory;

@end
