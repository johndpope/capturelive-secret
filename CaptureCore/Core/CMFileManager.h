//
//  FileManager.h
//  CaptureMedia-Library
//
//  Created by hatebyte on 8/15/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

extern char *StreamFileQueue;

#import <Foundation/Foundation.h>

typedef void (^CompleteWithPath)(NSString *documentPath);
typedef void (^Complete)();

static const NSString *CaptureMediaDirectory = @"capturemedia";


@interface CMFileManager : NSObject

+ (instancetype)defaultManager;
- (int)numFilesInDirectory:(NSString *)docPath;
- (NSString *)createMp4FilePathInDirectory:(NSString *)directory fileName:(NSString *)format;
- (NSString *)documentDirectoryPathForName:(NSString *)path;
- (NSString *)tmpDirectoryPathForName:(NSString *)path;
- (void)removeStreamFile:(NSString *)filePath;
- (NSString *)deleteOldestFileInDirectory:(NSString *)directory;
- (void)clearFilesFromDirectory:(NSString *)docPath;
- (void)wipeOutDirectory:(NSString *)docPath;
- (void)clearAllStreamFiles;
- (void)clearDocuments;
- (void)clearTmp;
- (NSString *)documentsDirectory;

- (NSArray *)filesInDirectory:(NSString *)directory sortedByAge:(NSComparisonResult)sort;
- (unsigned long long)sizeOfAllFilesInDirectory:(NSString *)directory;
- (int)indexOfFileName:(NSString *)path andContentType:(NSString *)type;

@end
