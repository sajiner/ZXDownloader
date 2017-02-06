//
//  ZXDownloader.m
//  ZXDownloaderLib
//
//  Created by sajiner on 2017/2/5.
//  Copyright © 2017年 sajiner. All rights reserved.
//

#import "ZXDownloader.h"
#import "ZXFileTool.h"

#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTempPath NSTemporaryDirectory()

@interface ZXDownloader ()<NSURLSessionDataDelegate>
/// 文件下载完成后的存储路径
@property (nonatomic, copy) NSString *cachPath;
/// 文件临时缓存路径
@property (nonatomic, copy) NSString *tempPath;
/// 下载会话
@property (nonatomic, strong) NSURLSession *session;
/// 文件输出流
@property (nonatomic, strong) NSOutputStream *outputStream;
/// 当前下载任务
@property (nonatomic, weak) NSURLSessionDataTask *dataTask;

@end

@implementation ZXDownloader {
    /// 记录文件临时大小
    long long _tempSize;
    /// 记录文件总大小
    long long _totalSize;
}

- (void)download:(NSURL *)url downloadInfo:(DownloadInfoType)downloadInfo progress:(ProgressBlockType)progressBlock success:(SuccessBlockType)successBlock failed:(FailedBlockType)failedBlock {
    self.downloadInfo = downloadInfo;
    self.progressBlock = progressBlock;
    self.successBlock = successBlock;
    self.failedBlock = failedBlock;
    
    [self downloader:url];
}

- (void)downloader:(NSURL *)url {
    
    if ([url isEqual:self.dataTask.originalRequest.URL]) {
        if (self.state == ZXDownloadStatePause) {
            [self resumeCurrentTask];
            return;
        }
    }
    [self cancleCurrentTask];
    // 获取文件的缓存路径及临时路径
    NSString *fileName = url.lastPathComponent;
    self.cachPath = [kCachePath stringByAppendingPathComponent:fileName];
    self.tempPath = [kTempPath stringByAppendingPathComponent:fileName];
    
    if ([ZXFileTool fileExists:self.cachPath]) {
        self.state = ZXDownloadStateSuccess;
        return;
    }
    if (![ZXFileTool fileExists:self.tempPath]) {
        // 从头开始下载
        [self downloadWithUrl:url offset:0];
        return;
    }
    _tempSize = [ZXFileTool fileSize:self.tempPath];
    [self downloadWithUrl:url offset:_tempSize];
}

- (void)resumeCurrentTask {
    if (self.dataTask && self.state == ZXDownloadStatePause) {
        [self.dataTask resume];
        self.state = ZXDownloadStateDownloading;
    }
}

- (void)pauseCurrentTask {
    if (self.state == ZXDownloadStateDownloading) {
        self.state = ZXDownloadStatePause;
        [self.dataTask suspend];
    }
}

- (void)cancleCurrentTask {
    self.state = ZXDownloadStatePause;
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (void)cancleAndClean {
    [self cancleCurrentTask];
    [ZXFileTool removeFile:self.tempPath];
    self.progress = 0.0;
}

#pragma mark - private method
/**
 根据开始字节，请求资源

 @param url url
 @param offset 开始字节
 */
- (void)downloadWithUrl: (NSURL *)url offset: (long long)offset {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    self.dataTask = [self.session dataTaskWithRequest:request];
    [self resumeCurrentTask];
}

#pragma mark - delegate

/**
 第一次接受到响应的时候调用（响应头并没有具体的资源内容）
 通过这个方法，里面系统提供的回调代码块，可以控制：是继续请求还是取消本次请求

 @param session 会话
 @param dataTask 任务
 @param response 响应头信息
 @param completionHandler 系统回调代码块，通过它可以控制是否继续接收数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSHTTPURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler {
  
    _totalSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *contentRangeStr = response.allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length != 0) {
        _totalSize = [[contentRangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    if (self.downloadInfo) {
        self.downloadInfo(_totalSize);
    }
    if (_tempSize == _totalSize) {
        [ZXFileTool moveFile:self.tempPath toPath:self.cachPath];
        completionHandler(NSURLSessionResponseCancel);
        self.state = ZXDownloadStatePause;
        return;
    }
    if (_tempSize > _totalSize) {
        [ZXFileTool removeFile:self.tempPath];
        completionHandler(NSURLSessionResponseCancel);
        [self downloader:response.URL];
        return;
    }
    self.state = ZXDownloadStateDownloading;
    // 继续下载
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.tempPath append:YES];
    [self.outputStream open];
    completionHandler(NSURLSessionResponseAllow);
}


/**
 当用户确定继续接收数据的时候调用

 @param session 会话
 @param dataTask 任务
 @param data 接收的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    _tempSize += data.length;
    self.progress = 1.0 * _tempSize / _totalSize;
    [self.outputStream write:data.bytes maxLength:data.length];
}


/**
 请求完成时调用

 @param session 会话
 @param task 任务
 @param error 错误
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error == nil) {
        [ZXFileTool moveFile:self.tempPath toPath:self.cachPath];
        self.state = ZXDownloadStateSuccess;
    } else {
        if (error.code == -999) {
            self.state = ZXDownloadStatePause;
        } else {
            self.state = ZXDownloadStateFailed;
        }
    }
    [self.outputStream close];
}

#pragma mark - lazy
- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (void)setState:(ZXDownloadState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    if (self.stateChange) {
        self.stateChange(_state);
    }
    if (_state == ZXDownloadStateSuccess && self.successBlock) {
        self.successBlock(self.cachPath);
    }
    if (_state == ZXDownloadStateFailed && self.failedBlock) {
        self.failedBlock();
    }
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    if (self.progressBlock) {
        self.progressBlock(_progress);
    }
}


@end
