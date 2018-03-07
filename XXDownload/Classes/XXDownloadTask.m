//
//  XXDownloadModel.m
//  BackgroundDownload
//
//  Created by xby on 2017/5/17.
//  Copyright © 2017年 wanxue. All rights reserved.
//
#import "XXDownloadTask.h"

@interface XXDownloadTask ()

/**
 缓存resumeData 的路径
 */
@property (copy,nonatomic) NSString *cachePath;

/**
 用于计算下载速度
 */
@property (assign,nonatomic)int64_t lastBytes;
/**
 定时器用于计算下载速度
 */
@property (strong,nonatomic)NSTimer *timer;
/**
 暂停或者下载出错产生的数据   用于断点续传
 */
@property (strong,nonatomic) NSData *partData;

@end

@implementation XXDownloadTask


#pragma mark - life cycle
- (void)dealloc {
    
#ifdef DEBUG
    
    NSLog(@"%s",__func__);
#endif
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/**
 创建一个下载任务
 */
+ (XXDownloadTask *)taskWithId:(NSString *)taskId name:(NSString *)taskName type:(XXDownloadType)taskType url:(NSString *)taskUrl desc:(NSString *)desc {
    
    XXDownloadModel *model = [[XXDownloadModel alloc] init];
    
    XXDownloadTask *dTask = [[XXDownloadTask alloc] init];
    
    model.taskId = taskId;
    model.taskName = taskName;
    model.taskState = XXDownloadStateWaiting;
    model.taskType = taskType;
    model.taskUrl = taskUrl;
    model.desc = desc;
    
    dTask.model = model;
    
    return dTask;
    
}
#pragma mark - public

/**
 删除任务的文件
 */
- (void)deleteTaskFile {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    if ([fileManager fileExistsAtPath:self.savePath]) {
        
        BOOL flag = [fileManager removeItemAtPath:self.savePath error:&error];
#ifdef DEBUG
        if (flag) {
            
            NSLog(@"删除成功 %s",__func__);
            
        } else {
            
            NSLog(@"删除失败,%@ %s",error,__func__);
        }
#endif
    }
    if ([fileManager fileExistsAtPath:self.cachePath]) {
        
        BOOL flag2 = [fileManager removeItemAtPath:self.cachePath error:&error];
#ifdef DEBUG
        if (flag2) {
            
            NSLog(@"删除成功 %s",__func__);
            
        } else {
            
            NSLog(@"删除失败,%@ %s",error,__func__);
        }
#endif
    }
}
/**
 激活定时器计算下载速度
 */
- (void)activeTimer {

    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    });
}
/**
 摧毁定时器
 */
- (void)destroyTimer {

    self.courrentBytes = 0;
    self.lastBytes = 0;
    self.speed = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.timer invalidate];
        self.timer = nil;
    });
}
///设置下载暂停的数据
- (void)setUpPartData:(NSData *)partData {
    
    if (partData) {
        
        self.partData = partData;
        BOOL flag = [partData writeToFile:self.cachePath atomically:YES];
        if (flag) {
#ifdef DEBUG
            NSLog(@"写入成功");
#endif
        } else {
            
#ifdef DEBUG
            NSLog(@"写入失败");
#endif
        }
    }
}
///获取原来的下载暂停数据
- (NSData *)originPartData {
    
    NSData *partData = self.partData ? self.partData : [[NSData alloc] initWithContentsOfFile:self.cachePath];
    self.partData = partData;
    return partData;
}

#pragma mark - event response
- (void)timerAction {
    
    self.speed = fabs((self.courrentBytes - self.lastBytes) / 1024.0f);
    self.lastBytes = self.courrentBytes;
}
#pragma mark - private
#pragma mark - delegate

#pragma mark - setter and getter

- (void)setModel:(XXDownloadModel *)model {

    _model = model;
    
    self.totalSize = _model.taskSize;
    self.downloadSize = _model.downloadedSize;
    self.state = model.taskState;
    
    if (self.totalSize != 0) {
        
        self.progress = self.downloadSize / self.totalSize;
    }
}
- (void)setTotalSize:(CGFloat)totalSize {

    _totalSize = totalSize;
    self.model.taskSize = _totalSize;
}
- (void)setDownloadSize:(CGFloat)downloadSize {

    _downloadSize = downloadSize;
    self.model.downloadedSize = downloadSize;
}
- (void)setState:(XXDownloadState)state {

    _state = state;
    self.model.taskState = _state;
}

- (NSString *)cachePath {

    if (!_cachePath) {
        
        _cachePath = [self.cacheDir stringByAppendingPathComponent:self.model.taskId];
    }
    return _cachePath;
}
- (NSString *)savePath {

    if (!_savePath) {
        
        NSString *fileName = self.model.taskId;
        _savePath = [self.downloadDir stringByAppendingPathComponent:fileName];
    }
    return _savePath;
}
- (NSURLSessionDownloadTask *)downloadTask {

    if (!_downloadTask) {
    
        NSURL *url = [NSURL URLWithString:self.model.taskUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithRequest:request];
        _downloadTask = downloadTask;
    }
    return _downloadTask;
}

@end
