//
//  NSData+NSURLSessionResumeData.m
//  BackgroundDownload
//
//  Created by xby on 2017/6/9.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import "NSData+NSURLSessionResumeData.h"

@implementation NSData (NSURLSessionResumeData)

/**
 获取纠正过后的resumeData
 
 @return resumeData
 */
- (NSData *)rightResumeDataWithUrlString:(NSString *)urlString {
    
    NSMutableDictionary *resumeDataDic =[NSPropertyListSerialization propertyListWithData:self options:NSPropertyListImmutable format:nil error:nil];
    
    NSMutableURLRequest *newResumeRequest =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSInteger bytes =[[resumeDataDic objectForKey:@"NSURLSessionResumeBytesReceived"] integerValue];
    NSString *bytesStr =[NSString stringWithFormat:@"bytes=%ld-",bytes];
    [newResumeRequest addValue:bytesStr forHTTPHeaderField:@"Range"];
    
    NSData *newResumeData =[NSKeyedArchiver archivedDataWithRootObject:newResumeRequest];
    [resumeDataDic setObject:newResumeData forKey:@"NSURLSessionResumeCurrentRequest"];
    [resumeDataDic setObject:urlString forKey:@"NSURLSessionDownloadURL"];
    NSData *data =[NSPropertyListSerialization dataWithPropertyList:resumeDataDic format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
    
    //清除 iOS 11 上面出问题的字符串
    NSString *dataString =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSString *string =[self cleanResumeDataWithString:dataString];
    data =[string dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
}

-(NSString *)cleanResumeDataWithString:(NSString *)dataString {
    
    if([dataString containsString:@"<key>NSURLSessionResumeByteRange</key>"]) {
        
        NSRange rangeKey = [dataString rangeOfString:@"<key>NSURLSessionResumeByteRange</key>"];
        NSString *headStr = [dataString substringToIndex:rangeKey.location];
        NSString *backStr = [dataString substringFromIndex:rangeKey.location];
        
        NSRange rangeValue = [backStr rangeOfString:@"</string>\n\t"];
        NSString *tailStr = [backStr substringFromIndex:rangeValue.location + rangeValue.length];
        dataString = [headStr stringByAppendingString:tailStr];
    }
    return dataString;
}

@end
