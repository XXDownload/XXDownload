//
//  XXDownloadModel.h
//  BackgroundDownload
//
//  Created by xby on 2017/5/17.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXDownloadEnum.h"

/**
 对应 download.db里面的  download_task表   维护下载任务的表
 */
@interface XXDownloadModel: NSObject

/**
 任务id
 */
@property (copy,nonatomic)NSString *taskId;
/**
 任务名字
 */
@property (copy,nonatomic)NSString *taskName;
/**
 任务类型
 */
@property (assign,nonatomic)XXDownloadType taskType;
/**
 任务地址
 */
@property (copy,nonatomic)NSString *taskUrl;
/**
 任务的状态
 */
@property (assign,nonatomic)XXDownloadState taskState;
/**
 任务总大小
 */
@property (assign,nonatomic)CGFloat taskSize;
/**
 已下载的任务大小
 */
@property (assign,nonatomic)CGFloat downloadedSize;
/**
 校验和 md5
 */
@property (copy,nonatomic)NSString *checkSum;
/**
 文件名
 */
@property (copy,nonatomic)NSString *fileName;
/**
 描述信息
 */
@property (copy,nonatomic)NSString *desc;
/**
 创建时间 时间戳
 */
@property (assign,nonatomic)NSTimeInterval createTime;
/**
 更新时间 时间戳
 */
@property (assign,nonatomic)NSTimeInterval updateTime;



@end
