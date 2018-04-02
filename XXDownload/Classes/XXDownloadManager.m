//
//  Downloader.m
//  SuperStudy2
//
//  Created by xby on 2016/11/15.
//  Copyright © 2016年 wanxue. All rights reserved.
//

#import "XXDownloadManager.h"
#import "XXDownloadTool.h"
#import "XXDownloadPath.h"

@interface XXDownloadManager ()<XXDownloadTaskDelegate>

/**
 整个下载列表包括数据库中的数据和新添加的
 */
@property (strong,nonatomic,readwrite)NSMutableArray *downloadArray;
/**
 正在下载的数组
 */
@property (strong,nonatomic) NSMutableArray *downloadingArray;
/**
 等待下载中的数据
 */
@property (strong,nonatomic) NSMutableArray *waitArray;
/**
 下载目录
 */
@property (strong,nonatomic) XXDownloadPath *downloadPath;

@end

static XXDownloadManager *_instance = nil;

@implementation XXDownloadManager

#pragma mark - life cycle
+ (instancetype)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _instance = [[self alloc]init];
    });
    
    return _instance;
}
- (instancetype)init {

    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resignActive)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(terminte)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        self.taskNumber = 1;
        [self setUpDownloadTool];
    }
    return self;
}
- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - private
#pragma mark - 数据读取和保存
- (void)setUpDownloadTool {
    
    [XXDownloadTool sharedTool].delegate = self;
}
- (void)setUpData {

    NSArray *array = [self.dbHelper getAllTasks];
    for (XXDownloadModel *model in array) {
        
        XXDownloadTask *task = [[XXDownloadTask alloc] init];
        task.model = model;
        [self configureTask:task];
        
        if (task.state == XXDownloadStateOnGoing) {
            
            [self startTask:task];
            
        } else if (task.state == XXDownloadStateWaiting) {
        
            [self.waitArray addObject:task];
        }
        
        [self.downloadArray addObject:task];
    }
}
- (void)resignActive {

    [self saveDownloading];
}
- (void)terminte {

    for (XXDownloadTask *task in self.downloadingArray) {
        
        [[XXDownloadTool sharedTool] pauseDownloadWithTask:task];
    }
    [self saveDownloading];
}
- (void)saveDownloading {
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (XXDownloadTask *obj in self.downloadArray) {
        
        [tempArray addObject:obj.model];
    }
    [self.dbHelper updateTasks:tempArray];
}
#pragma mark - 任务调度
- (void)startDownloadWithTask:(XXDownloadTask *)task isForced:(BOOL)isForced {
    
    if (!task) {
        
        return;
    }
    if (self.downloadingArray.count < self.taskNumber) {
        
        [self startDownloadWithTask:task];
        [self.downloadingArray addObject:task];
        
    } else {
        
        if (isForced) {
            
            XXDownloadTask *cancelTask = self.downloadingArray.firstObject;
            [self pauseDownloadWithTask:cancelTask beginNext:NO];
            //递归
            [self startDownloadWithTask:task isForced:isForced];
            //让刚才被暂停的任务进入等待队列的第一个
            [self startTask:cancelTask];
        }
    }
}

- (void)startDownloadWithTask:(XXDownloadTask *)task {

    void (^startBlock)(void) = ^() {
    
        [[XXDownloadTool sharedTool] startDownloadWithTask:task];
        task.state = XXDownloadStateWaiting;
        [self.waitArray removeObject:task];
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadTask:stateChanged:)]) {
            
            [self.delegate downloadTask:task stateChanged:task.state];
        }
    };
    if (self.taskSetUpdelegate && [self.taskSetUpdelegate respondsToSelector:@selector(downloadTaskWillStart:setUpFinish:failBlock:)]) {
        
        [self.taskSetUpdelegate downloadTaskWillStart:task setUpFinish:^{
           
            startBlock();
            
        } failBlock:^{
            
            
        }];

    } else {
    
        startBlock();
    }
}
- (void)pauseDownloadWithTask:(XXDownloadTask *)task beginNext:(BOOL)beginNext {

    [[XXDownloadTool sharedTool] pauseDownloadWithTask:task];
    [self.waitArray removeObject:task];
    [self.downloadingArray removeObject:task];
    task.state = XXDownloadStatePaused;
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadTask:stateChanged:)]) {
        
        [self.delegate downloadTask:task stateChanged:task.state];
    }
    if (beginNext) {
        
        [self startNextTask];
    }
}
- (void)deleteTaskWithTask:(XXDownloadTask *)task {

    [[XXDownloadTool sharedTool] deleteDownloadWithTask:task];
    [self.waitArray removeObject:task];
    [self.downloadingArray removeObject:task];
    [self.downloadArray removeObject:task];
    [self startNextTask];
    [self saveDownloading];
}

- (void)startNextTask {
    
    XXDownloadTask *waitTask = self.waitArray.firstObject;
    if (waitTask) {
        
        [self startDownloadWithTask:self.waitArray.firstObject isForced:NO];
    }
}
- (void)configureTask:(XXDownloadTask *)task {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cacheDirectoryWithdownloadTask:)]) {
        
        task.cacheDir = [self.delegate cacheDirectoryWithdownloadTask:task];
        
    } else {
    
        task.cacheDir = self.downloadPath.cacheDir;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadDirectoryWithdownloadTask:)]) {
        
        task.downloadDir = [self.delegate downloadDirectoryWithdownloadTask:task];
        
    } else {
    
        task.downloadDir = self.downloadPath.downloadDir;
    }
}
#pragma mark - delegate
#pragma mark - XXDownloadTaskDelegate
- (void)downloadTask:(XXDownloadTask *)task stateChanged:(XXDownloadState)state {

    if (state == XXDownloadStateFinished) {
        
        [self.downloadingArray removeObject:task];
        [self startNextTask];
        [self saveDownloading];
        
    } else if (state == XXDownloadStateError) {
    
        [self.downloadingArray removeObject:task];
        [self startNextTask];
        [self saveDownloading];

    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadTask:stateChanged:)]) {
        
        [self.delegate downloadTask:task stateChanged:state];
    }
}
- (void)downloadTask:(XXDownloadTask *)task downloadSize:(CGFloat)dSize totalSize:(CGFloat)tSize progress:(CGFloat)progress speed:(CGFloat)speed {

    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadTask:downloadSize:totalSize:progress:speed:)]) {
        
        [self.delegate downloadTask:task downloadSize:dSize totalSize:tSize progress:progress speed:speed];
    }
}
#pragma mark - public
/**
 根据任务id 获取一个下载任务  判断下载状态等
 
 @param taskId 任务id Container 的 code
 @return 下载任务
 */
- (XXDownloadTask *)downloadTaskWithId:(NSString *)taskId {

    XXDownloadTask *task = nil;
    for (XXDownloadTask *obj in self.downloadArray) {
        
        if ([obj.model.taskId isEqualToString:taskId]) {
            
            task = obj;
            break;
        }
    }
    return task;
}

/**
 设置appDelegate里面的block
 */
- (void)addFinishBlock:(void(^)(void))finishBlock identifier:(NSString *)identifier {

    [XXDownloadTool sharedTool].appdelegateFinishBlock = finishBlock;
}

/**
 全部暂停
 */
- (void)stopAllTask {

    for (XXDownloadTask *task in self.downloadArray) {
        
        if (task.state == XXDownloadStateOnGoing || task.state == XXDownloadStateWaiting) {
            
            [self pauseDownloadWithTask:task beginNext:NO];
        }
    }
}
/**
 全部任务开始
 */
- (void)startAllTask {

    for (XXDownloadTask *task in self.downloadArray) {
        
        if (task.state == XXDownloadStatePaused || task.state == XXDownloadStateError) {
            
            [self startTask:task];
        }
    }
}
/**
 插入一个任务 直接开始下载
 
 @param task 下载任务
 */
- (void)insertTask:(XXDownloadTask *)task {

    if (!task) {
        
        return;
    }
    //判断下载任务是否在数据库的下载任务列表中
    NSString  *taskId = task.model.taskId;
    XXDownloadTask *temp = [self downloadTaskWithId:taskId];
    if (temp) {
        
        return;
    }
    task.state = XXDownloadStateWaiting;
    [self configureTask:task];
    [self.downloadArray addObject:task];
    [self.waitArray addObject:task];
    [self.dbHelper insertTasks:@[task.model]];
    [self startDownloadWithTask:task isForced:YES];
}
/**
 添加一个下载任务
 
 @param task 下载任务
 */
- (void)addTask:(XXDownloadTask *)task {

    if (!task) {
        
        return;
    }
    //判断下载任务是否在数据库的下载任务列表中
    NSString  *taskId = task.model.taskId;
    XXDownloadTask *temp = [self downloadTaskWithId:taskId];
    if (temp) {
        
        return;
    }
    task.state = XXDownloadStateWaiting;
    [self configureTask:task];
    [self.downloadArray addObject:task];
    [self.waitArray addObject:task];
    [self.dbHelper insertTasks:@[task.model]];
    [self startDownloadWithTask:task isForced:NO];
}
/**
 开始下载
 
 @param task 任务id
 */
- (void)startTask:(XXDownloadTask *)task {

    if (!task) {
        
        return;
    }
    task.state = XXDownloadStateWaiting;
    [self.waitArray insertObject:task atIndex:0];
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadTask:stateChanged:)]) {
        
        [self.delegate downloadTask:task stateChanged:task.state];
    }
    [self startDownloadWithTask:task isForced:NO];
}
/**
 暂停下载
 
 @param task 任务id
 */
- (void)pauseTask:(XXDownloadTask *)task {

    if (task.state == XXDownloadStateOnGoing || task.state == XXDownloadStateWaiting) {
        
        [self pauseDownloadWithTask:task beginNext:YES];
    }
}
/**
 删除任务
 
 @param task 任务
 */
- (void)deleteTask:(XXDownloadTask *)task {

    [self deleteTaskWithTask:task];
    [self.dbHelper deleteTask:task.model];
}
#pragma mark - getters and setters
- (void)setDbHelper:(id<XXDownloadDBDelegate>)dbHelper {

    _dbHelper = dbHelper;
    [self setUpData];
}

- (NSMutableArray *)downloadArray {

    if (!_downloadArray) {
        
        _downloadArray = [[NSMutableArray alloc] init];
    }
    return _downloadArray;
}
- (NSMutableArray *)downloadingArray {

    if (!_downloadingArray) {
        
        _downloadingArray = [[NSMutableArray alloc] init];
    }
    return _downloadingArray;
}
- (NSMutableArray *)waitArray {

    if (!_waitArray) {
        
        _waitArray = [[NSMutableArray alloc] init];
    }
    return _waitArray;
}
- (XXDownloadPath *)downloadPath {

    if (!_downloadPath) {
        
        _downloadPath = [[XXDownloadPath alloc] init];
    }
    return _downloadPath;
}

@end
