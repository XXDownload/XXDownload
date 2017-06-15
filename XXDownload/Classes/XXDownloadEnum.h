//
//  Header.h
//  BackgroundDownload
//
//  Created by xby on 2017/5/22.
//  Copyright © 2017年 wanxue. All rights reserved.
//
typedef enum : NSUInteger {
    
    /** 等待状态*/
    XXDownloadStateWaiting = 10,
    /** 正在下载状态*/
    XXDownloadStateOnGoing = 11,
    /** 暂停状态*/
    XXDownloadStatePaused = 12,
    /** 下载错误状态*/
    XXDownloadStateError = 13,
    /** 完成状态*/
    XXDownloadStateFinished = 14,
} XXDownloadState;

typedef enum : NSUInteger {
    /** 通过url下载 */
    XXDownloadTypeUrl = 1,
    /** 通过CC下载 */
    XXDownloadTypeCC = 2,
} XXDownloadType;

