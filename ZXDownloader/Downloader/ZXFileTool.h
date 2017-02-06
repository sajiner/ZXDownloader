//
//  ZXFileTool.h
//  ZXDownloaderLib
//
//  Created by sajiner on 2017/2/5.
//  Copyright © 2017年 sajiner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZXFileTool : NSObject


/**
 文件路径是否存在

 @param filePath 文件路径
 @return YES-存在，NO-不存在
 */
+ (BOOL)fileExists: (NSString *)filePath;


/**
 根据路径获取文件大小

 @param filePath 文件路径
 @return 文件大小
 */
+ (long long)fileSize: (NSString *)filePath;


/**
 移动路径

 @param fromPath 原始路径
 @param toPath 目标路径
 */
+ (void)moveFile: (NSString *)fromPath toPath: (NSString *)toPath;


/**
 移除路径

 @param filePath 要移除的路径
 */
+ (void)removeFile: (NSString *)filePath;

@end
