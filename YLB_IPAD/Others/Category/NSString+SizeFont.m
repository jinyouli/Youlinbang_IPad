//
//  NSString+SizeFont.m
//  YLB
//
//  Created by YAYA on 2017/3/18.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "NSString+SizeFont.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (SizeFont)

- (CGSize)sizeWithFont:(UIFont *)font andSize:(CGSize)cSize{
    CGSize size=CGSizeZero;
#ifdef __IPHONE_7_0
        NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys: font, NSFontAttributeName, nil];
        CGRect rect = [self boundingRectWithSize:cSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil];
    size = rect.size;
#else
    size = [self sizeWithFont:font constrainedToSize:cSize];
#endif
    return size;
}

- (NSString *)md5{
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

@end
