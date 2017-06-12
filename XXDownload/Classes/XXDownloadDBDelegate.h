//
//  XXDownloadDBDelegate.h
//  BackgroundDownload
//
//  Created by xby on 2017/6/12.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XXDownloadModel;

@protocol XXDownloadDBDelegate <NSObject>

/**
 获取所有的下载任务
 
 @return 下载任务数组
 */
- (NSArray<XXDownloadModel *> *)getAllTasks;

/**
 将未入库的下载任务插入到库中去
 
 @param downloadArray 下载数组
 */
- (void)insertTasks:(NSArray<XXDownloadModel *> *)downloadArray;

/**
 更新下载任务 用 model 里面的所有属性去更新表里面的所有属性
 
 @param taskArray 下载任务数组
 */
- (void)updateTasks:(NSArray<XXDownloadModel *> *)taskArray;

/**
 删除表中的model记录
 
 @param model 任务
 */
- (void)deleteTask:(XXDownloadModel *)model;

@end
