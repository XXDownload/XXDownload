//
//  XXDownloadPath.m
//  SuperStudy2
//
//  Created by xby on 2016/11/25.
//  Copyright © 2016年 wanxue. All rights reserved.
//

#import "XXDownloadPath.h"

@implementation XXDownloadPath


#pragma mark - public
/**
 根据任务id返回该任务的路径
 
 @param taskId 任务id
 @return 任务的路径
 */
- (NSString *)taskPathWithTakId:(NSString *)taskId {

    if (!taskId) {
        
        return nil;
    }
    NSString *fullPath = [self.downloadDir stringByAppendingPathComponent:taskId];
    return fullPath;
}
/**
 根据任务id返回该任务的缓存路径
 
 @param taskId 任务id
 @return 任务的路径
 */
- (NSString *)cachePathWithTakId:(NSString *)taskId {

    if (!taskId) {
        
        return nil;
    }
    NSString *fullPath = [self.cacheDir stringByAppendingPathComponent:taskId];
    return fullPath;
}

#pragma mark - getters and setters
- (NSString *)downloadDir {

    if (!_downloadDir) {
        
        NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        
        NSString *downloadDir = [libraryPath stringByAppendingFormat:@"/%@",@"downloads"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        if (![fileManager fileExistsAtPath:downloadDir]) {
            //目录不存在
            [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:NO attributes:nil error:&error];
            
            if (error) {
                
                downloadDir = nil;
            }
        }
        _downloadDir = downloadDir;
    }
    return _downloadDir;
}
- (NSString *)cacheDir {

    if (!_cacheDir) {
        
        NSString *libraryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        
        NSString *cacheDir = [libraryPath stringByAppendingFormat:@"/%@",@"cacheDownloads"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        if (![fileManager fileExistsAtPath:cacheDir]) {
            //目录不存在
            [fileManager createDirectoryAtPath:cacheDir withIntermediateDirectories:NO attributes:nil error:&error];
            
            if (error) {
                
                cacheDir = nil;
            }
        }
        _cacheDir = cacheDir;
    }
    return _cacheDir;
}


@end
