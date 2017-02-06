//
//  NSString+ZXMD5.m
//  ZXDownloaderLib
//
//  Created by sajiner on 2017/2/5.
//  Copyright © 2017年 sajiner. All rights reserved.
//

#import "NSString+ZXMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (ZXMD5)

- (NSString *)md5 {
    const char *data = self.UTF8String;
    unsigned char md[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(data, (CC_LONG)strlen(data), md);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH *2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", md[i]];
    }
    return result;
}

@end
