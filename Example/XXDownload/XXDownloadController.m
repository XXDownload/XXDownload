//
//  XXDownloadController.m
//  BackgroundDownload
//
//  Created by xby on 2017/3/14.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import "XXDownloadController.h"

#import "XXDownloadManager.h"
#import "XXDownloadCell.h"
#import "XXDownloadPath.h"


@interface XXDownloadController ()<UITableViewDataSource,UITableViewDelegate,XXDownloadTaskDelegate>

/**
 整个下载列表包括数据库中的数据和新添加的
 */
@property (strong,nonatomic) NSMutableArray *downloadArray;

/**
 tableView
 */
@property (strong,nonatomic) UITableView *tableView;
/**
 全部开始按钮
 */
@property (strong,nonatomic) UIButton *startAllBtn;
/**
 全部暂停按钮
 */
@property (strong,nonatomic) UIButton *stopAllBtn;
@property (strong,nonatomic) XXDownloadPath *downloadPath;

@end

@implementation XXDownloadController

#pragma mark - life cycle
- (void)dealloc {
    
    NSLog(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //清空数据重新获取
    [self setUpData];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //监听app回到前台的方法
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [self setUpSubView];
}
#pragma mark - private
- (void)setUpData {
    
    [XXDownloadManager sharedManager].delegate = self;
    NSArray *array = [XXDownloadManager sharedManager].downloadArray;
    self.downloadArray = [[NSMutableArray alloc] initWithArray:array];
    [self.tableView reloadData];
}
- (void)setUpSubView {
    
    self.title = @"下载";
    [self.view addSubview:self.startAllBtn];
    [self.view addSubview:self.stopAllBtn];
    [self.view addSubview:self.tableView];
}

- (void)sendLocalNotificationWithMessage:(NSString *)message {
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    NSDate *now = [NSDate date];
    notification.fireDate = [now dateByAddingTimeInterval:3]; //触发通知的时间
    notification.repeatInterval = 0; //循环次数，kCFCalendarUnitWeekday一周一次
    
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.alertBody = message;
    notification.alertAction = @"打开";  //提示框按钮
    notification.hasAction = YES; //是否显示额外的按钮，为no时alertAction消失
    //下面设置本地通知发送的消息，这个消息可以接受
    NSDictionary* infoDic = [NSDictionary dictionaryWithObject:@"value" forKey:@"key"];
    notification.userInfo = infoDic;
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
#pragma mark - event response
- (void)becomeActive {

    NSArray *array = [XXDownloadManager sharedManager].downloadArray;
    self.downloadArray = [[NSMutableArray alloc] initWithArray:array];
    [self.tableView reloadData];
}
- (void)startAllAction:(UIButton *)sender {

    [[XXDownloadManager sharedManager] startAllTask];
}
- (void)stopAllAction:(UIButton *)sender {

    [[XXDownloadManager sharedManager] stopAllTask];
}
#pragma mark - DownloadTaskDelegate
/**
 下载状态回调
 
 @param task 下载任务
 @param state 状态
 */
- (void)downloadTask:(XXDownloadTask *)task stateChanged:(XXDownloadState)state {
    
    NSInteger index = [self.downloadArray indexOfObject:task];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    XXDownloadCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.progressText = [NSString stringWithFormat:@"名:%@ 速度:%.2f,进度:%.2f,已:%.2f,总:%.2f",task.model.taskName,task.speed,task.progress,task.downloadSize,task.totalSize];
    cell.state = task.model.taskState;
    if (state == XXDownloadStateFinished) {
        
        NSString *text = [NSString stringWithFormat:@"%@任务下载完成了",task.model.taskName];
        [self sendLocalNotificationWithMessage:text];
        
    } else if (state == XXDownloadStateError) {
    
        NSString *text = [NSString stringWithFormat:@"%@任务下载失败了",task.model.taskName];
        [self sendLocalNotificationWithMessage:text];
    }
}
/**
 下载进度回调
 
 @param task 下载任务
 @param dSize 已下载大小  单位 MB
 @param tSize 总大小     单位 MB
 @param progress  进度
 @param speed 速度
 */
- (void)downloadTask:(XXDownloadTask *)task downloadSize:(CGFloat)dSize totalSize:(CGFloat)tSize progress:(CGFloat)progress speed:(CGFloat)speed {

    NSInteger index = [self.downloadArray indexOfObject:task];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    XXDownloadCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.progressText = [NSString stringWithFormat:@"名:%@ 速度:%.2f,进度:%.2f,已:%.2f,总:%.2f",task.model.taskName,task.speed,task.progress,task.downloadSize,task.totalSize];
    cell.state = task.model.taskState;
    
    NSLog(@"总大小：%.2f 已下载：%.2f 速度：%.2f 进度:%.2f",task.totalSize,task.downloadSize,task.speed,task.progress);
}
- (NSString *)cacheDirectoryWithdownloadTask:(XXDownloadTask *)task {

    return self.downloadPath.cacheDir;
}
- (NSString *)downloadDirectoryWithdownloadTask:(XXDownloadTask *)task {

    return self.downloadPath.downloadDir;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XXDownloadTask *task = self.downloadArray[indexPath.row];
    XXDownloadState state = task.model.taskState;
    switch (state) {
            
        case XXDownloadStateWaiting:{
            
            [[XXDownloadManager sharedManager] pauseTask:task];
            NSLog(@"等待状态");
            break;
        }
        case XXDownloadStateOnGoing:{
            
            NSLog(@"点击的任务是正在下载的状态");
            [[XXDownloadManager sharedManager] pauseTask:task];
            
            break;
        }
        case XXDownloadStatePaused:{
            
            NSLog(@"点击的任务是暂停的状态");
            [[XXDownloadManager sharedManager] startTask:task];
            
            break;
        }
        case XXDownloadStateFinished:{
            
            NSLog(@"点击的任务是已完成的状态");
            break;
        }
        case XXDownloadStateError:{
            
            NSLog(@"点击的任务是已出错的状态");
            
            //重新开始下载
            [[XXDownloadManager sharedManager] startTask:task];
            break;
        }
        default:
            break;
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"%@",indexPath);
    XXDownloadTask *model = self.downloadArray[indexPath.row];
    [self.downloadArray removeObject:model];
    [[XXDownloadManager sharedManager] deleteTask:model];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.downloadArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reUseIdentifier = @"reUseIdentifier";
    XXDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:reUseIdentifier];
    if (!cell) {
        
        cell = [[XXDownloadCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reUseIdentifier];
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    XXDownloadTask *task = self.downloadArray[indexPath.row];
    
    cell.progressText = [NSString stringWithFormat:@"名:%@ 速度:%.2f,进度:%.2f,已:%.2f,总:%.2f",task.model.taskName,task.speed,task.progress,task.downloadSize,task.totalSize];
    cell.state = task.model.taskState;
    
    return cell;
}

#pragma mark - getters and setters
- (UITableView *)tableView {

    if (!_tableView) {
        
        _tableView = [[UITableView alloc] init];
        _tableView.frame = CGRectMake(0, CGRectGetMaxY(self.startAllBtn.frame), self.view.frame.size.width, CGRectGetMaxY(self.view.frame) - CGRectGetMaxY(self.startAllBtn.frame));
        _tableView.rowHeight = 130;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
    }
    return _tableView;
}
- (UIButton *)startAllBtn {

    if (!_startAllBtn) {
        
        _startAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _startAllBtn.backgroundColor = [UIColor lightGrayColor];
        _startAllBtn.frame = CGRectMake(0, 64, self.view.bounds.size.width * 0.5, 44);
        [_startAllBtn setTitle:@"全部开始" forState:UIControlStateNormal];
        [_startAllBtn addTarget:self action:@selector(startAllAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startAllBtn;
}
- (UIButton *)stopAllBtn {
    
    if (!_stopAllBtn) {
        
        _stopAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _stopAllBtn.backgroundColor = [UIColor lightGrayColor];
        _stopAllBtn.frame = CGRectMake(CGRectGetMaxX(self.startAllBtn.frame),64, self.view.bounds.size.width * 0.5, 44);
        [_stopAllBtn setTitle:@"全部暂停" forState:UIControlStateNormal];
        [_stopAllBtn addTarget:self action:@selector(stopAllAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopAllBtn;
}
- (XXDownloadPath *)downloadPath {

    if (!_downloadPath) {
        
        _downloadPath = [[XXDownloadPath alloc] init];
    }
    return _downloadPath;
}


@end
