//
//  ViewController.m
//  BackgroundDownload
//
//  Created by xby on 2017/3/12.
//  Copyright © 2017年 wanxue. All rights reserved.
//

#import "XXViewController.h"

#import "XXDownloadManager.h"

#import "XXDownloadController.h"

@interface XXViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic)UITableView *tableView;

@property (strong,nonatomic)NSArray *dataArray;

@end

@implementation XXViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setUpData];
    [self setUpSubView];
    
}
#pragma mark - private
- (void)setUpData {
    
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"videoList.json" ofType:nil];
    NSData *data = [[NSData alloc] initWithContentsOfFile:jsonPath];
    
    NSError *error = nil;
    self.dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSAssert(!error, @"json文件转对象出错，请检查");
}

- (void)setUpSubView {
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"下载" style:UIBarButtonItemStylePlain target:self action:@selector(downloadAction:)];
    self.navigationItem.rightBarButtonItem = item;
    
    [self.view addSubview:self.tableView];
}
#pragma mark - event response
- (void)downloadAction:(UIBarButtonItem *)sender {
    
    XXDownloadController *downloadVC = [[XXDownloadController alloc] init];
    [self.navigationController pushViewController:downloadVC animated:YES];
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dataDict = self.dataArray[indexPath.row];
    
    NSString *taskId = [dataDict valueForKey:@"id"];
    NSString *name = [dataDict valueForKey:@"name"];
    NSString *url = [dataDict valueForKey:@"url"];
    NSInteger type = [[dataDict valueForKey:@"type"] integerValue];
    
    XXDownloadTask *dTask = [XXDownloadTask taskWithId:taskId name:name type:type url:url size:0];
    [[XXDownloadManager sharedManager] addTask:dTask];
    XXDownloadController *downloadVC = [[XXDownloadController alloc] init];
    [self.navigationController pushViewController:downloadVC animated:YES];
    
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reUseIdentifier = @"reUseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reUseIdentifier];
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reUseIdentifier];
    }
    NSDictionary *dict = self.dataArray[indexPath.row];
    NSString *videoName = [dict valueForKey:@"name"];
    cell.textLabel.text = videoName;
    
    return cell;
}

#pragma makr - getters and setters
- (UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] init];
        _tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _tableView.rowHeight = 44;
        _tableView.tableFooterView = [[UIView alloc] init];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
