//
//  XXDownloadPath.h
//  SuperStudy2
//
//  Created by xby on 2016/11/25.
//  Copyright © 2016年 wanxue. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 拼接下载路径 获取下载文件的位置
 */
@interface XXDownloadPath : NSObject


/**
 下载目录
 */
@property (copy,nonatomic)NSString *downloadDir;
/**
 缓存目录
 */
@property (copy,nonatomic)NSString *cacheDir;

/**
 根据任务id返回该任务的路径

 @param taskId 任务id
 @return 任务的路径
 */
- (NSString *)taskPathWithTakId:(NSString *)taskId;
/**
 根据任务id返回该任务的缓存路径
 
 @param taskId 任务id
 @return 任务的路径
 */
- (NSString *)cachePathWithTakId:(NSString *)taskId;

@end
