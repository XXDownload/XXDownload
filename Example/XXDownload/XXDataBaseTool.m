//
//  XXDataBaseTool.m
//  SuperStudy2
//
//  Created by xby on 2016/11/1.
//  Copyright © 2016年 wanxue. All rights reserved.
//

#import "XXDataBaseTool.h"

#import "XXDownloadPath.h"

@interface XXDataBaseTool ()

@end

@implementation XXDataBaseTool

static XXDataBaseTool *_instance = nil;

#pragma mark - life cycle
+ (instancetype)sharedTool {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _instance = [[self alloc]init];
    });
    
    return _instance;
}

#pragma mark - private

#pragma mark - public 
#pragma mark - getters and setters
- (FMDatabaseQueue *)downloadDBQueue {

    if (!_downloadDBQueue) {
        //创建 download.db 数据库文件
        XXDownloadPath *path = [[XXDownloadPath alloc] init];
        NSString *filePath = [path.downloadDir stringByAppendingPathComponent:@"download.db"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:filePath]) {
            
            [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        }
        _downloadDBQueue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    }
    return _downloadDBQueue;
}


@end
