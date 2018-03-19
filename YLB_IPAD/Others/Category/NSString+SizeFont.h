//
//  NSString+SizeFont.h
//  YLB
//
//  Created by YAYA on 2017/3/18.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SizeFont)

- (CGSize)sizeWithFont:(UIFont *)font andSize:(CGSize)cSize;

- (NSString *)md5;
@end
