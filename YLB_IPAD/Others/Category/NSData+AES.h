//
//  NSData+AES.h
//  YLB
//
//  Created by sayee on 17/4/11.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES)

/**
 * 加密 AES256
 * @param key 密钥
 */
- (NSData *)AES256EncryptWithKey:(NSString *)key;

/**
 * 解密 AES256
 * @param key 密钥
 */
- (NSData *)AES256DecryptWithKey:(NSString *)key;
@end
