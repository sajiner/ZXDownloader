//
//  ZXDownloaderManager.h
//  ZXDownloaderLib
//
//  Created by sajiner on 2017/2/5.
//  Copyright © 2017年 sajiner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZXDownloader.h"

@interface ZXDownloaderManager : NSObject

+ (instancetype)shareInstance;

- (void)download: (NSURL *)url downloadInfo: (DownloadInfoType)downloadInfo progress: (ProgressBlockType)progressBlock success: (SuccessBlockType)successBlock failed: (FailedBlockType)failedBlock;

- (void)pauseWithUrl: (NSURL *)url;
- (void)resumeWithUrl: (NSURL *)url;
- (void)cancleWithUrl: (NSURL *)url;

- (void)pauseAll;
- (void)resumeAll;

@end
