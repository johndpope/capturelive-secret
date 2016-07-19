//
//  FileManager.m
//  CaptureMedia-Library
//
//  Created by hatebyte on 8/15/14.
//  Copyright (c) 2014 CaptureMedia. All rights reserved.
//

#import "CMFileManager.h"
//#import "Stream+Util.h"
#import "NSDate+CM.h"

@interface CMFileManager ()

@end

@implementation CMFileManager

+ (instancetype)defaultManager {
    static CMFileManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager                                                     = [[CMFileManager alloc] init];
    });
    return manager;
}

- (NSString *)createMp4FilePathInDirectory:(NSString *)directory fileName:(NSString *)fileName {
    NSString *docPath = [[self documentsDirectory] stringByAppendingPathComponent:directory];

    NSError *error                                                  = nil;
    NSArray *filelist                                               = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docPath error:&error];
    return [NSString stringWithFormat:@"%@/%@ (%ld).mp4", docPath, fileName, ((unsigned long)[filelist count])];
}

- (NSString *)documentsDirectory {
    NSArray *paths                                                  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

- (NSString *)documentDirectoryPathForName:(NSString *)path {
    return [self createPathInDirectory:[self documentsDirectory] andFilePath:path];
}

- (NSString *)tmpDirectoryPathForName:(NSString *)path {
    return [self createPathInDirectory:NSTemporaryDirectory() andFilePath:path];
}

- (void)clearFilesFromDirectory:(NSString *)directory {
    NSString *docPath = [[self documentsDirectory] stringByAppendingPathComponent:directory];

    NSError *error                                                  = nil;
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docPath error:&error]) {
        NSString *fullPath                                          = [NSString stringWithFormat:@"%@/%@", docPath, file];
        BOOL success                                                = [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
        if (!success || error) {
            NSLog(@"Couldn't clear file from : \n%@", fullPath);
        }
    }
}

- (NSString *)deleteOldestFileInDirectory:(NSString *)directory {
    NSString *docPath = [[self documentsDirectory] stringByAppendingPathComponent:directory];
    NSArray *files = [self filesInDirectory:docPath sortedByAge:NSOrderedAscending];
    if (files.count > 0) {
        NSString *filePath = [[self documentsDirectory] stringByAppendingPathComponent:directory];
        NSString *oldest = [NSString stringWithFormat:@"%@/%@", filePath, files.firstObject];
        [[NSFileManager defaultManager] removeItemAtPath:oldest error:nil];
        return oldest;
    }
    return @"deleteOldestFileInDirectory error";
}

- (void)wipeOutDirectory:(NSString *)directory {
    [self clearFilesFromDirectory:directory];
    NSString *docPath = [[self documentsDirectory] stringByAppendingPathComponent:directory];
    [[NSFileManager defaultManager] removeItemAtPath:docPath error:nil];
}

- (int)numFilesInDirectory:(NSString *)directory {
    NSString *docPath = [[self documentsDirectory] stringByAppendingPathComponent:directory];
    NSError *error                                                  = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docPath error:&error];
    if (error) {
        return 0;
    }
    return (int)[files count];
}

- (NSString *)createPathInDirectory:(NSString *)directory andFilePath:(NSString *)path {
    NSString *filePath                                              = [directory stringByAppendingPathComponent:path];

    NSError *error                                                  = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    return path;
}

- (void)removeStreamFile:(NSString *)filePath {
    NSString *docPath = [NSString stringWithFormat:@"%@/%@", [self documentsDirectory], filePath];

    dispatch_queue_t queue                                          = dispatch_queue_create(StreamFileQueue, DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        NSError *error;
        if ([[NSFileManager defaultManager] fileExistsAtPath:docPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:docPath error:&error];
            if (error) {
                NSLog(@"Stream couldn't remove url : %@, %@", docPath, error);
            }
        }
        NSString *directory                     = [docPath stringByDeletingLastPathComponent];
        if ([[NSFileManager defaultManager] fileExistsAtPath:directory]) {
            NSArray *files                      = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
            if ([files count] == 0) {
                [[NSFileManager defaultManager] removeItemAtPath:directory error:&error];
                if (error) {
                    NSLog(@"Stream directory couldn't be removed : %@, %@", directory, error);
                }
            }
        }
    });
}

- (void)clearAllStreamFiles {
    __weak typeof(self) weakSelf                                    = self;
    [weakSelf clearDocuments];
    [weakSelf clearTmp];
}

- (void)clearDocuments {
    NSArray *paths                                                  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory                                    = [paths objectAtIndex:0];
    [self clear:documentsDirectory];
}

- (void)clearTmp {
    [self clear:NSTemporaryDirectory()];
}

- (void)clear:(NSString *)path {
    NSError *e                                                      = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", path, CaptureMediaDirectory] error:&e];
}

- (NSArray *)filesInDirectory:(NSString *)directory sortedByAge:(NSComparisonResult)sort {
    NSError *error                                                  = nil;
    NSArray *filelist                                               = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&error];
    if (error || filelist.count < 1) {
        return  @[];
    }
    
    NSArray *sorted = [filelist sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSError *error                                              = nil;
        NSString *dir                                               = [directory stringByAppendingPathComponent:a];
        NSDictionary  *fileInfo                                     = [[NSFileManager defaultManager] attributesOfItemAtPath:dir error:&error];
        NSDate *modified1                                           = fileInfo[NSFileCreationDate];
        
        dir                                                         = [directory stringByAppendingPathComponent:b];
        fileInfo                                                    = [[NSFileManager defaultManager] attributesOfItemAtPath:dir error:&error];
        NSDate *modified2                                           = fileInfo[NSFileCreationDate];
        return [modified1 compare:modified2];
    }];
    if (sort == NSOrderedDescending) {
        return [[sorted reverseObjectEnumerator] allObjects];
    } else {
        return sorted;
    }
}

- (unsigned long long)sizeOfAllFilesInDirectory:(NSString *)directory {
    // get documents
    NSString *docPath = directory;  //[NSString stringWithFormat:@"%@/%@", [self documentsDirectory], directory];
    NSLog(@"docPath : %@", docPath);
    if (directory) {
        NSError *error                                                  = nil;
        NSArray *filelist                                               = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docPath error:&error];
        if (error || filelist.count < 1) {
            NSLog(@"docPath : %@", docPath);
            NSLog(@"filelist.count : %lu", (unsigned long)filelist.count);
            NSLog(@"error : %@", error.localizedDescription);
            return  0;
        }
        
        unsigned long long numBytes                                     = 0;
        for (NSString *file in filelist) {
            NSString *directoryP                                        = [docPath stringByAppendingPathComponent:file];
            NSDictionary  *fileInfo                                     = [[NSFileManager defaultManager] attributesOfItemAtPath:directoryP error:&error];
            NSNumber *fileSizeNumber                                    = [fileInfo objectForKey:NSFileSize];
            numBytes += [fileSizeNumber unsignedLongLongValue];
        }
        
        return numBytes;
    }
    return 0;
}

- (int)indexOfFileName:(NSString *)path andContentType:(NSString *)type {
    NSString *predicate                                             = [NSString stringWithFormat:@"\\(([^\\)]+)\\).%@", type];
    NSRegularExpression *re                                         = [[NSRegularExpression alloc] initWithPattern:predicate options:NSRegularExpressionAnchorsMatchLines error:nil];
    NSArray *matches                                                = [re matchesInString:path options:NSMatchingWithTransparentBounds range:NSMakeRange(0, path.length)];
    if (matches.count < 1) {
        return -1;
    }
    
    NSString *result                                                = @"";
    for (NSTextCheckingResult *match in matches) {
        result                                                      = [path substringWithRange: [match rangeAtIndex:1]];
    }
    int number                                                      = [result intValue];
    return number;
}


@end



char *StreamFileQueue                                               = "com.capturemedia.stream.filemanager.queue";



























