//
//  XXDownloadManager.h
//  SuperStudy2
//
//  Created by xby on 2016/11/15.
//  Copyright © 2016年 wanxue. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XXDownloadTask.h"
#import "XXDownloadTaskDelegate.h"
#import "XXDownloadTaskSetUpDelegate.h"
#import "XXDownloadDBDelegate.h"

/**
 下载工具类
 */
@interface XXDownloadManager : NSObject

/**
 *  单例创建数据库管理工具
 *
 *  @return 数据库管理工具
 */
+ (XXDownloadManager *)sharedManager;
/**
 整个下载列表包括数据库中的数据和新添加的
 */
@property (strong,nonatomic,readonly)NSMutableArray *downloadArray;

/**
 并行任务数  默认为1
 */
@property (assign,nonatomic) NSInteger taskNumber;
/**
 下载回调对象
 */
@property (weak,nonatomic) id <XXDownloadTaskDelegate> delegate;
/**
 任务配置代理对象
 */
@property (weak,nonatomic) id <XXDownloadTaskSetUpDelegate> taskSetUpdelegate;
/**
 数据库操作对象
 */
@property (strong,nonatomic) id <XXDownloadDBDelegate> dbHelper;

/**
 根据任务id 获取一个下载任务  判断下载状态等
 @return 下载任务
 */
- (XXDownloadTask *)downloadTaskWithId:(NSString *)taskId;

/**
 设置appDelegate里面的block
 */
- (void)addFinishBlock:(void(^)())finishBlock identifier:(NSString *)identifier;

/**
 全部暂停
 */
- (void)stopAllTask;
/**
 全部任务开始
 */
- (void)startAllTask;
/**
 添加一个下载任务

 @param task 下载任务
 */
- (void)addTask:(XXDownloadTask *)task;
/**
 开始下载

 @param task 任务id
 */
- (void)startTask:(XXDownloadTask *)task;
/**
 暂停下载

 @param task 任务id
 */
- (void)pauseTask:(XXDownloadTask *)task;
/**
 删除任务

 @param task 任务
 */
- (void)deleteTask:(XXDownloadTask *)task;

@end
