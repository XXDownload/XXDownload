//
//  XXDownloadTaskDelegate.h
//  BackgroundDownload
//
//  Created by xby on 2017/6/5.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol XXDownloadTaskDelegate <NSObject>


/**
 下载状态回调
 
 @param task 下载任务
 @param state 状态
 */
- (void)downloadTask:(XXDownloadTask *)task stateChanged:(XXDownloadState)state;

/**
 下载进度回调
 
 @param task 下载任务
 @param dSize 已下载大小  单位 MB
 @param tSize 总大小     单位 MB
 @param progress  进度
 @param speed 速度
 */
- (void)downloadTask:(XXDownloadTask *)task downloadSize:(CGFloat)dSize totalSize:(CGFloat)tSize progress:(CGFloat)progress speed:(CGFloat)speed;

@optional;
/**
 下载任务的缓存目录

 @param task 下载任务
 @return 缓存目录
 */
- (NSString *)cacheDirectoryWithdownloadTask:(XXDownloadTask *)task;
/**
 下载任务的文件保存目录
 
 @param task 下载任务
 @return 缓存目录
 */
- (NSString *)downloadDirectoryWithdownloadTask:(XXDownloadTask *)task;

@end
