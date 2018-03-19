//
//  SYImageCompress.h
//  YLB
//
//  Created by chenjiangchuan on 16/12/5.
//  Copyright © 2016年 Sayee Intelligent Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYImageCompress : NSObject

/**
 *  压图片质量
 *
 *  @param image image
 *  @return Data
 */
+ (NSData *)zipImageWithImage:(UIImage *)image;

/**
 *  等比缩放本图片大小
 *
 *  @param newImageWidth 缩放后图片宽度，像素为单位
 *
 *  @return self-->(image)
 */
+ (UIImage *)compressImage:(UIImage *)image newWidth:(CGFloat)newImageWidth;

/**
 *  动态发布图片压缩
 *
 *  @param source_image 原图image
 *  @param maxSize      限定的图片大小
 *
 *  @return 返回处理后的图片数据流
 */
+ (NSData *)resetSizeOfImageData:(UIImage *)source_image maxSize:(NSInteger)maxSize;

@end
