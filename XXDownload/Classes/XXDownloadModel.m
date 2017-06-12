//
//  XXDownloadModel.m
//  BackgroundDownload
//
//  Created by xby on 2017/5/17.
//  Copyright © 2017年 wanxue. All rights reserved.
//
#import "XXDownloadModel.h"

@interface XXDownloadModel ()


@end

@implementation XXDownloadModel


#pragma mark - life cycle
- (void)dealloc {
    
    NSLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (NSTimeInterval)createTime {

    return [[NSDate date] timeIntervalSince1970];
}
- (NSTimeInterval)updateTime {

    return [[NSDate date] timeIntervalSince1970];
}

@end
