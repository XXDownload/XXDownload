//
//  XXDownloadTaskSetUpDelegate.h
//  BackgroundDownload
//
//  Created by xby on 2017/6/12.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXDownloadTask.h"

/**
 对下载任务进行配置的代理
 */
@protocol XXDownloadTaskSetUpDelegate <NSObject>


/**
 下载任务将要开始  可以对该任务做最后的配置   主要是因为 cc 的url地址是有时效的  所以每次将要开始的时候重新更新cc的url地址
 
 @param task 将要开始的任务
 @param successBlock 配置成功过后的回调
 @param failBlock 配置失败后的回调
 */
- (void)downloadTaskWillStart:(XXDownloadTask *)task setUpFinish:(void(^)())successBlock failBlock:(void(^)())failBlock;


@end
