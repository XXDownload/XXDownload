#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSData+NSURLSessionResumeData.h"
#import "XXDownload.h"
#import "XXDownloadDBDelegate.h"
#import "XXDownloadEnum.h"
#import "XXDownloadManager.h"
#import "XXDownloadModel.h"
#import "XXDownloadPath.h"
#import "XXDownloadTask.h"
#import "XXDownloadTaskDelegate.h"
#import "XXDownloadTaskSetUpDelegate.h"
#import "XXDownloadTool.h"

FOUNDATION_EXPORT double XXDownloadVersionNumber;
FOUNDATION_EXPORT const unsigned char XXDownloadVersionString[];

