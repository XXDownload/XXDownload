//
//  NSData+NSURLSessionResumeData.h
//  BackgroundDownload
//
//  Created by xby on 2017/6/9.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (NSURLSessionResumeData)
/**
 获取纠正过后的resumeData

 @return resumeData
 */
- (NSData *)getRightResumeData;

@end
