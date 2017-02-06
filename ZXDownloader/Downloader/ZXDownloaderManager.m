//
//  ZXDownloaderManager.m
//  ZXDownloaderLib
//
//  Created by sajiner on 2017/2/5.
//  Copyright © 2017年 sajiner. All rights reserved.
//

#import "ZXDownloaderManager.h"
#import "NSString+ZXMD5.h"
#import "ZXDownloader.h"

@interface ZXDownloaderManager ()<NSCopying, NSMutableCopying>

@property (nonatomic, strong) NSMutableDictionary *downLoadInfo;

@end

@implementation ZXDownloaderManager

static ZXDownloaderManager *_shareInstance;

+ (instancetype)shareInstance {
    if (!_shareInstance) {
        _shareInstance = [[self alloc] init];
    }
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _shareInstance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _shareInstance;
}

- (void)download:(NSURL *)url downloadInfo:(DownloadInfoType)downloadInfo progress:(ProgressBlockType)progressBlock success:(SuccessBlockType)successBlock failed:(FailedBlockType)failedBlock {
    NSString *urlMd5 = [url.absoluteString md5];
    ZXDownloader *downloader = self.downLoadInfo[urlMd5];
    if (!downloader) {
        downloader = [[ZXDownloader alloc] init];
        self.downLoadInfo[urlMd5] = downloader;
    }
    __weak typeof(self) weakSelf = self;
    [downloader download:url downloadInfo:downloadInfo progress:progressBlock success:^(NSString *filePath) {
        [weakSelf.downLoadInfo removeObjectForKey:urlMd5];
        successBlock(filePath);
    } failed:failedBlock];
}

- (void)pauseWithUrl:(NSURL *)url {
    NSString *urlMd5 = [url.absoluteString md5];
    ZXDownloader *downloader = self.downLoadInfo[urlMd5];
    [downloader pauseCurrentTask];
}

- (void)resumeWithUrl:(NSURL *)url {
    NSString *urlMd5 = [url.absoluteString md5];
    ZXDownloader *downloader = self.downLoadInfo[urlMd5];
    [downloader resumeCurrentTask];
}

- (void)cancleWithUrl:(NSURL *)url {
    NSString *urlMd5 = [url.absoluteString md5];
    ZXDownloader *downloader = self.downLoadInfo[urlMd5];
    [downloader cancleCurrentTask];
}

- (void)pauseAll {
    for (ZXDownloader *downloader in self.downLoadInfo.allValues) {
        [downloader performSelector:@selector(pauseCurrentTask) withObject:nil];
    }
}

- (void)resumeAll {
    for (ZXDownloader *downloader in self.downLoadInfo.allValues) {
        [downloader performSelector:@selector(resumeCurrentTask) withObject:nil];
    }
}

#pragma mark - lazy
// key: md5(url)  value: XMGDownLoader
- (NSMutableDictionary *)downLoadInfo {
    if (!_downLoadInfo) {
        _downLoadInfo = [NSMutableDictionary dictionary];
    }
    return _downLoadInfo;
}

@end
