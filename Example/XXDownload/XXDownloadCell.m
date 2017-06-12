//
//  XXDownloadCell.m
//  BackgroundDownload
//
//  Created by xby on 2017/3/14.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import "XXDownloadCell.h"

#import "XXDownloadTask.h"

@interface XXDownloadCell ()


/**
 下载进度信息文本框
 */
@property (strong,nonatomic)UILabel *progressLabel;

/**
 下载状态文本框
 */
@property (strong,nonatomic)UILabel *stateLabel;

@end

@implementation XXDownloadCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.progressLabel.frame = CGRectMake(0, 5, [UIScreen mainScreen].bounds.size.width,60);
        self.progressLabel.font = [UIFont systemFontOfSize:14];
        self.progressLabel.numberOfLines = 0;
        
        [self.contentView addSubview:self.progressLabel];
        
        self.stateLabel.frame = CGRectMake(0, 65, [UIScreen mainScreen].bounds.size.width, 40);
        self.stateLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.stateLabel];
        
    }
    return self;
}

#pragma mark - getters and setters
- (void)setState:(NSInteger)state {
    
    NSString *stateText;
    switch (state) {
        case XXDownloadStateError: {
            
            stateText = @"下载出错";
            break;
        }
        case XXDownloadStatePaused: {
            
            stateText = @"暂停";
            break;
        }
        case XXDownloadStateOnGoing: {
            
            stateText = @"正在下载";
            break;
        }
        case XXDownloadStateWaiting: {
            
            stateText = @"等待中...";
            break;
        }
        case XXDownloadStateFinished: {
            
            stateText = @"已完成状态";
            break;
        }
        default:
            break;
    }
    self.stateLabel.text = stateText;
}

- (void)setProgressText:(NSString *)progressText {

    self.progressLabel.text = progressText;
}

- (UILabel *)progressLabel {

    if (!_progressLabel) {
        
        _progressLabel = [[UILabel alloc] init];
    }
    return _progressLabel;
}
- (UILabel *)stateLabel {

    if (!_stateLabel) {
        
        _stateLabel = [[UILabel alloc] init];
    }
    return _stateLabel;
}
@end
