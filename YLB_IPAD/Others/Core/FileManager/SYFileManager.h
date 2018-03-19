//
//  SYFileManager.h
//  YLB
//
//  Created by chenjiangchuan on 16/11/3.
//  Copyright © 2016年 Sayee Intelligent Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYFileManager : NSObject

/**
 *  添加文件到指定路径
 *
 *  @param fileName 文件名
 *  @param path     路径名
 *  @param data     文件流
 *
 *  @return 成功返回YES
 */
+ (BOOL)fileManagerSaveFile:(NSString *)fileName withPath:(NSString *)path withContents:(NSData *)data;

/**
 *  在沙盒中的document文件夹中创建多级文件夹或文件
 *
 *  @param fileFullPath 完整路径+文件名
 *  @param data         写入的数据
 */
+ (NSString *)fileManagerCreateFileWithFullPath:(NSString *)fileFullPath withContents:(NSData *)data;

/**
 *  在沙盒中的document文件夹中查找文件或者文件夹下列的所有文件
 *
 *  @param filePath 文件名或者路径名
 *
 *  @return NSString或者NSArray
 */
+ (id)fileManagerSearchFileWithPath:(NSString *)filePath;

/**
 *  创建缓存文件
 *
 *  @param fileName 文件名
 *
 */
+ (NSString *)fileManagerCreateCacheFile:(NSString *)fileName withContents:(NSData *)data;

/**
 *  读取缓存文件
 *
 *  @param fileName 文件名
 *
 */
+ (NSString *)fileManagerReadCacheFile:(NSString *)fileName;

/**
 *  删除指定路径的文件
 *
 *  @param fileName 文件名
 *  @param path     路径名
 *
 *  @return 成功返回YES
 */
+ (BOOL)fileManagerDeleteFile:(NSString *)fileName withPath:(NSString *)path;

/**
 *  遍历目录下所有的文件
 *
 *  @param direString 路径
 *
 *  @return 所有的文件
 */
+ (NSMutableArray *)fileManagerAllFilesAtPath:(NSString *)path;

/**
 *  移动文件
 *
 *  @param file   从哪个路径下移动
 *  @param toPath 到哪个路径
 */
+ (void)fileManagerMoveFile:(id)files toPath:(NSString *)toPath;

/**
 *  重命名文件夹
 *
 *  @param folderName 重命名后的名字
 *  @param beforeName 重命名前的名字
 */
+ (void)fileManagerChangeFolderName:(NSString *)folderName beforeName:(NSString *)beforeName;

@end
