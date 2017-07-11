//
//  XXSetUpTool.h
//  XXDownload
//
//  Created by xby on 2017/7/11.
//  Copyright © 2017年 acct<blob>=0xE7BE8AE5AD90. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XXDownload.h"
@interface XXSetUpTool: NSObject<XXDownloadTaskSetUpDelegate>


+ (instancetype)sharedInstance;

@end
