//
//  XXDownloadTaskHelper.m
//  SuperStudy2
//
//  Created by xby on 2017/2/23.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import "XXDownloadDBHelper.h"

#import "XXDataBaseTool.h"
#import "XXDownloadModel.h"
#import <objc/runtime.h>

@implementation XXDownloadDBHelper

#pragma mark - life cycle
- (void)dealloc {
    
    NSLog(@"%s",__func__);
}
- (instancetype)init {

    if (self = [super init]) {
        
        //初次加载时创建表
        NSString *sql = @"CREATE TABLE IF NOT EXISTS download_task('id' INTEGER PRIMARY KEY AUTOINCREMENT,'task_id' TEXT NOT NULL,'task_name' TEXT NOT NULL,'task_state' INTEGER NOT NULL,'task_type' INTEGER NOT NULL,'task_url' TEXT NOT NULL,'task_size' DOUBLE NOT NULL,'downloadSize' DOUBLE NOT NULL,'checksum' TEXT,'file_name' TEXT,'description' TEXT,'create_time' DOUBLE ,'update_time' DOUBLE);";
        XXDataBaseTool *dbTool = [XXDataBaseTool sharedTool];
        [dbTool.downloadDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            
            BOOL flag = [db executeUpdate:sql];
            if (flag) {
                
                NSLog(@"创建表成功");
                
            } else {
                
                NSLog(@"创建表失败");
            }
        }];
    }
    return self;
}

#pragma mark - public
/**
 获取所有的下载任务
 
 @return 下载任务数组
 */
- (NSArray *)getAllTasks {

    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM download_task"];
    
    __block NSArray *array = nil;
    [self queryWithSql:sql success:^(NSArray *downloadArray) {
        
        array = downloadArray;
    }];
    return array;
}

/**
 将未入库的下载任务插入到库中去
 
 @param downloadArray 下载数组
 */
- (void)insertTasks:(NSArray *)downloadArray {
    
    NSArray *sqlArray = [self insertSqlWithArray:downloadArray];
    
    [[XXDataBaseTool sharedTool].downloadDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        for (NSString *sql in sqlArray) {
            
            BOOL flag = [db executeUpdate:sql];
            if (flag) {
                
                NSLog(@"插入成功:%@",sql);
                
            } else {
                
                *rollback = YES;
                NSLog(@"插入失败，请检查:%@",sql);
                break;
            }
        }
    }];
}

/**
 更新下载任务 用 model 里面的所有属性去更新表里面的所有属性
 
 @param taskArray 下载任务数组
 */
- (void)updateTasks:(NSArray *)taskArray {

    NSArray *sqlArray = [self updateSqlWithArray:taskArray];
    
    [[XXDataBaseTool sharedTool].downloadDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        for (NSString *sql in sqlArray) {
            
            BOOL flag = [db executeUpdate:sql];
            
            if (flag) {
                
                NSLog(@"更新成功 %@",sql);
                
            } else {
                
                *rollback = YES;
                NSLog(@"更新失败，请检查 %@",sql);
                break;
            }
        }
    }];
}

/**
 删除表中的model记录
 
 @param model 任务
 */
- (void)deleteTask:(XXDownloadModel *)model {

    NSString *sql = [NSString stringWithFormat:@"DELETE FROM download_task WHERE task_id = '%@';",model.taskId];
    [[XXDataBaseTool sharedTool].downloadDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        BOOL flag = [db executeUpdate:sql];
        
        if (flag) {
            
            NSLog(@"删除成功 %@",sql);
            
        } else {
            
            *rollback = YES;
            NSLog(@"删除失败，请检查 %@",sql);
        }
    }];
}
#pragma mark - private instance method

- (NSArray *)insertSqlWithArray:(NSArray *)downloadArray {
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    for (XXDownloadModel *model in downloadArray) {
        
        NSString *taskId = model.taskId;
        NSString *taskName = model.taskName;
        XXDownloadState state = model.taskState;
        XXDownloadType type = model.taskType;
        NSString *url = model.taskUrl;
        CGFloat size = model.taskSize;
        CGFloat downloadSize = model.downloadedSize;
        NSString *md5 = model.checkSum;
        NSString *fileName = model.fileName;
        NSString *desc = model.desc;
        NSTimeInterval createTime = model.createTime;
        NSTimeInterval updateTime = model.updateTime;
        
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO download_task('task_id','task_name','task_state','task_type','task_url','task_size','downloadSize','checksum','file_name','description','create_time','update_time') VALUES('%@','%@','%zd','%zd','%@','%.2f','%.2f',%@,'%@','%@','%.f','%.f');",taskId,taskName,state,type,url,size,downloadSize,md5,fileName,desc,createTime,updateTime];
        
        [dataArray addObject:sql];
    }
    return dataArray;
}

- (NSArray *)updateSqlWithArray:(NSArray *)downloadArray {
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    for (XXDownloadModel *model in downloadArray) {
        
        NSString *taskId = model.taskId;
        NSString *taskName = model.taskName;
        XXDownloadState state = model.taskState;
        XXDownloadType type = model.taskType;
        NSString *url = model.taskUrl;
        CGFloat size = model.taskSize;
        CGFloat downloadSize = model.downloadedSize;
        NSString *md5 = model.checkSum;
        NSString *fileName = model.fileName;
        NSString *desc = model.taskName;
        NSTimeInterval createTime = model.createTime;
        NSTimeInterval updateTime = model.updateTime;
        
        NSString *sql = [NSString stringWithFormat:@"UPDATE download_task SET 'task_name' = '%@', 'task_state' = '%zd','task_type' = '%zd','task_url' = '%@','downloadSize' = '%.2f','task_size' = '%.2f','checksum' = '%@','file_name' = '%@','description' = '%@','create_time' = '%f','update_time' = '%f' WHERE task_id = '%@';",taskName,state,type,url,downloadSize,size,md5,fileName,desc,createTime,updateTime,taskId];
        
        [dataArray addObject:sql];
    }
    return dataArray;
}


- (void)queryWithSql:(NSString *)sql success:(void(^)(NSArray *downloadArray))successBlock {
    
    [[XXDataBaseTool sharedTool].downloadDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        
        FMResultSet *result = [db executeQuery:sql];
        while ([result next]) {
            
            XXDownloadModel *task = [[XXDownloadModel alloc] init];
            
            task.taskId = [result stringForColumn:@"task_id"];
            task.taskName = [result stringForColumn:@"task_name"];
            task.taskState = [result intForColumn:@"task_state"];
            task.taskType = [result intForColumn:@"task_type"];
            if (task.taskType == XXDownloadTypeCC) {
                
                task.taskUrl = nil;
                
            } else {
            
                task.taskUrl = [result stringForColumn:@"task_url"];
            }
            task.downloadedSize = [result doubleForColumn:@"downloadSize"];
            task.taskSize = [result doubleForColumn:@"task_size"];
            task.checkSum = [result stringForColumn:@"checksum"];
            task.fileName = [result stringForColumn:@"file_name"];
            task.desc = [result stringForColumn:@"description"];
            task.createTime = [result doubleForColumn:@"create_time"];
            task.updateTime = [result doubleForColumn:@"update_time"];
            
            [dataArray addObject:task];
        }
        if (successBlock) {
            
            successBlock(dataArray);
        }
    }];
}
@end
