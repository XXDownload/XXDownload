//
//  XXDownloadTool.m
//  BackgroundDownload
//
//  Created by xby on 2017/6/5.
//  Copyright © 2017年 wanxue. All rights reserved.
//
#import "XXDownloadTool.h"

@interface XXDownloadTool ()<NSURLSessionDelegate,NSURLSessionDownloadDelegate>

/**
 后台下载配置对象
 */
@property (strong,nonatomic) NSURLSessionConfiguration *configure;
/**
 下载的session
 */
@property (strong,nonatomic) NSURLSession *session;
/**
 正在下载的字典数据
 */
@property (strong,nonatomic) NSMutableDictionary <NSNumber *,XXDownloadTask *> *downloadingDict;

@end

@implementation XXDownloadTool


#pragma mark - life cycle
- (void)dealloc {
    
#ifdef DEBUG
    
    NSLog(@"%s",__func__);
#endif
}
/**
 下载单例工具
 
 @return 下载工具
 */
+ (instancetype)sharedTool {

    static XXDownloadTool *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _instance = [[self alloc]init];
    });
    
    return _instance;
}

#pragma mark - private
- (void)configureTask:(XXDownloadTask *)task {
    
    task.session = self.session;
}
#pragma mark - public
/**
 开始下载任务
 */
- (void)startDownloadWithTask:(XXDownloadTask *)task {

    [self configureTask:task];
    task.downloadTask = nil;
    NSData *partData = [task originPartData];
    if (partData) {
        
        task.downloadTask = [self.session downloadTaskWithResumeData:partData];
        [task.downloadTask resume];
        
    } else {
    
        [task.downloadTask resume];
    }
    [self.downloadingDict setObject:task forKey:@(task.downloadTask.taskIdentifier)];    
    //激活定时器
    [task activeTimer];
}
/**
 暂停下载任务
 */
- (void)pauseDownloadWithTask:(XXDownloadTask *)task {

    [self configureTask:task];
    [task.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        
        [task setUpPartData:resumeData];
    }];
    [self.downloadingDict removeObjectForKey:@(task.downloadTask.taskIdentifier)];
    //摧毁定时器
    [task destroyTimer];
    
}
/**
 删除下载任务
 */
- (void)deleteDownloadWithTask:(XXDownloadTask *)task {

    [self configureTask:task];
    [task.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        
        
    }];
    [self.downloadingDict removeObjectForKey:@(task.downloadTask.taskIdentifier)];
    [task deleteTaskFile];
    //摧毁定时器
    [task destroyTimer];
}

#pragma mark - delegate
#pragma mark - NSURLSessionDelegate
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session NS_AVAILABLE_IOS(7_0) {
    
    if (self.appdelegateFinishBlock) {
        
        self.appdelegateFinishBlock();
    }
}
#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    XXDownloadTask *dTask = [self.downloadingDict objectForKey:@(task.taskIdentifier)];
    if (!dTask) {
        
        return;
    }
    if (dTask.totalSize <= 0) {
        
        dTask.totalSize = task.countOfBytesExpectedToReceive / 1024.0f / 1024.0f;
    }
    dTask.downloadSize = task.countOfBytesReceived / 1024.0f / 1024.0f;
    
    if (error) {
        
#ifdef DEBUG
        
        NSLog(@"下载失败了，快快检查：%@",error);
#endif
        if (dTask.state != XXDownloadStatePaused) {
            //真的下载失败了
            if ([error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData]) {
                
                NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
                if (resumeData) {
                    
                    [dTask setUpPartData:resumeData];
                }
                dTask.downloadTask = [self.session downloadTaskWithResumeData:resumeData];
                [dTask.downloadTask resume];
                
            } else {
                
                //摧毁定时器
                [dTask destroyTimer];
                dTask.state = XXDownloadStateError;
            }
        }
    } else {
        
        //摧毁定时器
        [dTask destroyTimer];
        
        //下载成功
        dTask.progress = 1;
        dTask.state = XXDownloadStateFinished;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadTask:stateChanged:)]) {
            
            [self.delegate downloadTask:dTask stateChanged:dTask.state];
        }
    });
}
#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
    XXDownloadTask *dTask = [self.downloadingDict objectForKey:@(downloadTask.taskIdentifier)];
    if (!dTask) {
        
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *toUrl = [NSURL fileURLWithPath:dTask.savePath];
    NSError *error = nil;
    [fileManager moveItemAtURL:location toURL:toUrl error:&error];
    
#ifdef DEBUG
    
    if (error) {
        
        NSLog(@"移动失败，请检查 %@",error);
        
    } else {
        
        NSLog(@"下载文件移动成功");
    }
#endif
    
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    
    XXDownloadTask *dTask = [self.downloadingDict objectForKey:@(downloadTask.taskIdentifier)];
    if (!dTask) {
        
        return;
    }
    if (dTask.totalSize <= 0) {
        
        dTask.totalSize = totalBytesExpectedToWrite / 1024.0f / 1024.0f;
    }
    dTask.downloadSize = totalBytesWritten / 1024.0f / 1024.0f;
    dTask.progress = dTask.downloadSize / dTask.totalSize;
    dTask.state = XXDownloadStateOnGoing;
    
    //下载速度相关
    dTask.courrentBytes += bytesWritten;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadTask:downloadSize:totalSize:progress:speed:)]) {
            
            [self.delegate downloadTask:dTask downloadSize:dTask.downloadSize totalSize:dTask.totalSize progress:dTask.progress speed:dTask.speed];
        }
    });
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {

#ifdef DEBUG
    NSLog(@"文件偏移位置%.2f\n还有多少文件下载:%.2f",fileOffset / 1024.0 / 1024.0,expectedTotalBytes / 1024.0 / 1024.0);
#endif
    
}
#pragma mark - event response

#pragma mark - getters and setters
- (NSURLSession *)session {

    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *bundeId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
        NSURLSessionConfiguration *configure = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:bundeId];
        
        session = [NSURLSession sessionWithConfiguration:configure
                                                delegate:self
                                           delegateQueue:nil];
    });
    return session;
}
- (NSMutableDictionary<NSNumber *,XXDownloadTask *> *)downloadingDict {
    
    if (!_downloadingDict) {
        
        _downloadingDict = [[NSMutableDictionary alloc] init];
    }
    return _downloadingDict;
}



@end
