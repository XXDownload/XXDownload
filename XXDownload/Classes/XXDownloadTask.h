//
//  XXDownloadTask.h
//  SuperStudy2
//
//  Created by xby on 2016/11/16.
//  Copyright © 2016年 wanxue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXDownloadModel.h"

@interface XXDownloadTask : NSObject

/**
 数据库中的Model数据
 */
@property (strong,nonatomic) XXDownloadModel *model;
/**
 下载状态
 */
@property (assign,nonatomic) XXDownloadState state;
/**
 下载目录
 */
@property (copy,nonatomic)NSString *downloadDir;
/**
 缓存目录
 */
@property (copy,nonatomic)NSString *cacheDir;
/**
 下载完成保存的路径
 */
@property (copy,nonatomic) NSString *savePath;
/**
 下载进度
 */
@property (assign,nonatomic) CGFloat progress;

/**
 界面显示用 单位 MB
 */
@property (assign,nonatomic) CGFloat downloadSize;

/**
 界面显示用 单位 MB
 */
@property (assign,nonatomic) CGFloat totalSize;
/**
 下载速度
 */
@property (assign,nonatomic) CGFloat speed;

/**
 下载session 由manager传过来
 */
@property (strong,nonatomic) NSURLSession *session;
/**
 下载器自己懒加载创建
 */
@property (strong,nonatomic) NSURLSessionDownloadTask *downloadTask;

/**
 当前下载的字节数 用于计算下载速度
 */
@property (assign,nonatomic)int64_t courrentBytes;
/**
 暂停或者下载出错产生的数据   用于断点续传
 */
@property (strong,nonatomic) NSData *partData;

/**
 创建一个下载任务
 */
+ (XXDownloadTask *)taskWithId:(NSString *)taskId name:(NSString *)taskName type:(XXDownloadType)taskType url:(NSString *)taskUrl desc:(NSString *)desc;

/**
 删除任务的文件
 */
- (void)deleteTaskFile;
/**
 返回纠正过后的数据

 @return 下载失败时的数据
 */
- (NSData *)rightPartData;
/**
 激活定时器计算下载速度
 */
- (void)activeTimer;
/**
 摧毁定时器
 */
- (void)destroyTimer;


@end
