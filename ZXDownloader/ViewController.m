//
//  ViewController.m
//  ZXDownloader
//
//  Created by sajiner on 2017/2/6.
//  Copyright © 2017年 sajiner. All rights reserved.
//

#import "ViewController.h"
#import "ZXDownloaderManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)start:(UIButton *)sender {
    
    [[ZXDownloaderManager shareInstance] download:[NSURL URLWithString:@"http://free2.macx.cn:8281/tools/photo/SnapNDragPro418.dmg"] downloadInfo:^(long long totalSize) {
        NSLog(@"totalSize === %lld", totalSize);
    } progress:^(CGFloat progress) {
        NSLog(@"progress ===== %f", progress);
    } success:^(NSString *filePath) {
        NSLog(@"filePath = %@", filePath);
    } failed:^{
        NSLog(@"shibao");
    }];
    
    [[ZXDownloaderManager shareInstance] download:[NSURL URLWithString:@"http://free2.macx.cn:8281/tools/photo/Sip44.dmg"] downloadInfo:^(long long totalSize) {
        NSLog(@"下载信息--%lld", totalSize);
    } progress:^(CGFloat progress) {
        NSLog(@"下载进度--%f", progress);
    } success:^(NSString *filePath) {
        NSLog(@"下载成功--路径:%@", filePath);
    } failed:^{
        NSLog(@"下载失败了");
    }];
}

- (IBAction)pause:(UIButton *)sender {
//    [[ZXDownloaderManager shareInstance] pauseWithUrl:[NSURL URLWithString:@"http://free2.macx.cn:8281/tools/photo/SnapNDragPro418.dmg"]];
    [[ZXDownloaderManager shareInstance] pauseAll];
}

- (IBAction)cancle:(UIButton *)sender {
    [[ZXDownloaderManager shareInstance] cancleWithUrl:[NSURL URLWithString:@"http://free2.macx.cn:8281/tools/photo/SnapNDragPro418.dmg"]];
}

- (IBAction)resume:(UIButton *)sender {
    [[ZXDownloaderManager shareInstance] resumeAll];
}

@end
