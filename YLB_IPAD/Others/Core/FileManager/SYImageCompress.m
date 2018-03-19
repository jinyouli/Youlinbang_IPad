//
//  SYImageCompress.m
//  YLB
//
//  Created by chenjiangchuan on 16/12/5.
//  Copyright © 2016年 Sayee Intelligent Technology. All rights reserved.
//

#import "SYImageCompress.h"

@implementation SYImageCompress

/**
 压图片质量
 
 @param image image
 @return Data
 */
+ (NSData *)zipImageWithImage:(UIImage *)image
{
    if (!image) {
        return nil;
    }
    CGFloat maxFileSize = 32*1024;
    CGFloat compression = 0.5f;
    NSData *compressedData = UIImageJPEGRepresentation(image, compression);
    while ([compressedData length] > maxFileSize) {
        compression *= 0.5;
        compressedData = UIImageJPEGRepresentation([[self class] compressImage:image newWidth:image.size.width*compression], compression);
    }
    return compressedData;
}

/**
 *  等比缩放本图片大小
 *
 *  @param newImageWidth 缩放后图片宽度，像素为单位
 *
 *  @return self-->(image)
 */
+ (UIImage *)compressImage:(UIImage *)image newWidth:(CGFloat)newImageWidth
{
    if (!image) return nil;
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    float width = newImageWidth;
    float height = image.size.height/(image.size.width/width);
    
    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, imageWidth /heightScale , height)];
    }
    else {
        [image drawInRect:CGRectMake(0, 0, width , imageHeight /widthScale)];
    }
    
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return newImage;
}

/**
 *  动态发布图片压缩
 *
 *  @param source_image 原图image
 *  @param maxSize      限定的图片大小
 *
 *  @return 返回处理后的图片数据流
 */
+ (NSData *)resetSizeOfImageData:(UIImage *)source_image maxSize:(NSInteger)maxSize{
    //先调整分辨率
    CGSize newSize = CGSizeMake(source_image.size.width, source_image.size.height);
    
    CGFloat tempHeight = newSize.height / 1024;
    CGFloat tempWidth = newSize.width / 1024;
    
    if (tempWidth > 1.0 && tempWidth != tempHeight) {
        newSize = CGSizeMake(source_image.size.width / tempWidth, source_image.size.height / tempWidth);
    }
    
    UIGraphicsBeginImageContext(newSize);
    [source_image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    //调整大小
    NSData *imageData = UIImageJPEGRepresentation(newImage,1.0);
    NSUInteger sizeOrigin = [imageData length];
    NSUInteger sizeOriginKB = sizeOrigin / 1024;
    NSLog(@"sizeOriginKB === %ld",sizeOriginKB);
    if (sizeOriginKB > maxSize) {
        NSData *finallImageData = UIImageJPEGRepresentation(newImage,0.50);
        NSLog(@"finallImageDataKB === %ld",[finallImageData length]/1024);
        return finallImageData;
    }
    //    NSData *imageData = [PMRequest image:newImage maxSize:maxSize];
    NSLog(@"imageDataKB === %ld",[imageData length]/1024);
    return imageData;
}

@end
