# XXDownload

[![CI Status](http://img.shields.io/travis/acct<blob>=0xE7BE8AE5AD90/XXDownload.svg?style=flat)](https://travis-ci.org/acct<blob>=0xE7BE8AE5AD90/XXDownload)
[![Version](https://img.shields.io/cocoapods/v/XXDownload.svg?style=flat)](http://cocoapods.org/pods/XXDownload)
[![License](https://img.shields.io/cocoapods/l/XXDownload.svg?style=flat)](http://cocoapods.org/pods/XXDownload)
[![Platform](https://img.shields.io/cocoapods/p/XXDownload.svg?style=flat)](http://cocoapods.org/pods/XXDownload)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
#WHAT
XXDownload is a tool that can download task in foreground and background.
## Requirements
iOS8.0
## USEAGE
1.Import

```
#import <XXDownload.h>
```

2.In Appdelegate.m add the below code

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
// Override point for customization after application launch.
/*
Here the dbHelper can implement by yourself,it must conformsToProtocol XXDownloadDBDelegate
*/
[XXDownloadManager sharedManager].dbHelper = [[XXDownloadDBHelper alloc] init];

return YES;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {

[[XXDownloadManager sharedManager] addFinishBlock:completionHandler identifier:identifier];
}

```

3.Task Operation

a.add Task

```
XXDownloadTask *dTask = [XXDownloadTask taskWithId:taskId name:name type:type url:url size:0];

[[XXDownloadManager sharedManager] addTask:dTask];
```
b.start Task

```
[[XXDownloadManager sharedManager] startTask:task];
```
c.pause Task

```
[[XXDownloadManager sharedManager] pauseTask:task];
```
d.delete Task

```
[[XXDownloadManager sharedManager] deleteTask:model];
```

4.CallBack

Object that conforms XXDownloadTaskDelegate can show the downloading task`s progress and the downloading state.

Object that conforms XXDownloadTaskSetUpDelegate can configure the task before the task beginning.

## Detail USEAGE

[http://www.jianshu.com/p/e566bc3ac365](http://www.jianshu.com/p/e566bc3ac365)


## Installation

XXDownload is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'XXDownload',:git => 'https://github.com/XXDownload/XXDownload.git'
```
## Author

yangzi, 595919268@qq.com

## License

XXDownload is available under the MIT license. See the LICENSE file for more info.
