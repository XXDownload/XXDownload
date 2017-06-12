//
//  XXDataBaseTool.h
//  SuperStudy2
//
//  Created by xby on 2016/11/1.
//  Copyright © 2016年 wanxue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface XXDataBaseTool : NSObject

/**
 *  单例创建数据库管理工具
 *
 *  @return 数据库管理工具
 */
+ (XXDataBaseTool *)sharedTool;

/**
 下载资源的数据库队列，download.db 用该对象去操作 改对象是懒加载的
 */
@property (strong,nonatomic)FMDatabaseQueue *downloadDBQueue;


@end
