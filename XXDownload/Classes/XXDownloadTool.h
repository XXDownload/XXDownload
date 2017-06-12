//
//  XXDownloadTool.h
//  BackgroundDownload
//
//  Created by xby on 2017/6/5.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXDownloadTask.h"
#import "XXDownloadTaskDelegate.h"

/**
 *后台配置对象标识符
 */
extern NSString *const SSBackgroundIdentifier;


@interface XXDownloadTool: NSObject

/**
 下载单例工具

 @return 下载工具
 */
+ (instancetype)sharedTool;
/**
 下载回调对象
 */
@property (weak,nonatomic) id <XXDownloadTaskDelegate> delegate;

/**
 保存appDelegate
 */
@property (copy,nonatomic) void(^appdelegateFinishBlock)();

/**
 开始下载任务
 */
- (void)startDownloadWithTask:(XXDownloadTask *)task;
/**
 暂停下载任务
 */
- (void)pauseDownloadWithTask:(XXDownloadTask *)task;
/**
 删除下载任务
 */
- (void)deleteDownloadWithTask:(XXDownloadTask *)task;

@end
