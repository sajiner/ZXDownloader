//
//  ZXDownloader.h
//  ZXDownloaderLib
//
//  Created by sajiner on 2017/2/5.
//  Copyright © 2017年 sajiner. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZXDownloadState) {
    ZXDownloadStatePause,
    ZXDownloadStateDownloading,
    ZXDownloadStateSuccess,
    ZXDownloadStateFailed
};

typedef void(^DownloadInfoType)(long long totalSize);
typedef void(^ProgressBlockType)(CGFloat progress);
typedef void(^SuccessBlockType)(NSString *filePath);
typedef void(^FailedBlockType)();
typedef void(^StateChangeType)(ZXDownloadState state);

@interface ZXDownloader : NSObject

- (void)download: (NSURL *)url downloadInfo: (DownloadInfoType)downloadInfo progress: (ProgressBlockType)progressBlock success: (SuccessBlockType)successBlock failed: (FailedBlockType)failedBlock;

/**
 根据url地址下载资源
 @param url 资源路径
 */
- (void)downloader: (NSURL *)url;

/**
 暂停任务
 特别注意：
 - 如果调用了几次继续，将会调用几次暂停才可以暂停
 - 解决方案：引入状态
 */
- (void)pauseCurrentTask;


/**
 继续下载任务
 */
- (void)resumeCurrentTask;

/**
 取消当前任务
 */
- (void)cancleCurrentTask;

/**
 取消并清理资源
 */
- (void)cancleAndClean;

@property (nonatomic, assign, readonly) ZXDownloadState state;
@property (nonatomic, assign, readonly) CGFloat progress;

@property (nonatomic, copy) DownloadInfoType downloadInfo;
@property (nonatomic, copy) ProgressBlockType progressBlock;
@property (nonatomic, copy) SuccessBlockType successBlock;
@property (nonatomic, copy) FailedBlockType failedBlock;
@property (nonatomic, copy) StateChangeType stateChange;

@end
