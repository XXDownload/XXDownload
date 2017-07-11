//
//  XXSetUpTool.m
//  XXDownload
//
//  Created by xby on 2017/7/11.
//  Copyright © 2017年 acct<blob>=0xE7BE8AE5AD90. All rights reserved.
//
#import "XXSetUpTool.h"

@interface XXSetUpTool ()

@end

@implementation XXSetUpTool


#pragma mark - life cycle
- (void)dealloc {
    
    NSLog(@"%s",__func__);
}

+ (instancetype)sharedInstance {

    static XXSetUpTool *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _instance = [[self alloc]init];
    });
    
    return _instance;    
}
#pragma mark - private

#pragma mark - public

#pragma mark - delegate
- (void)downloadTaskWillStart:(XXDownloadTask *)task setUpFinish:(void(^)())successBlock failBlock:(void(^)())failBlock {

    if (successBlock) {
        
        successBlock();
    }
}

#pragma mark - event response

#pragma mark - getters and setters



@end
