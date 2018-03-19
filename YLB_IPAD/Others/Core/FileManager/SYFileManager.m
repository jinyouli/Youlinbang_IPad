//
//  SYFileManager.m
//  YLB
//
//  Created by chenjiangchuan on 16/11/3.
//  Copyright © 2016年 Sayee Intelligent Technology. All rights reserved.
//

#import "SYFileManager.h"

@implementation SYFileManager

/**
 *  添加文件到指定路径
 *
 *  @param fileName 文件名
 *  @param path     路径名
 *
 *  @return 成功返回YES
 */
+ (BOOL)fileManagerSaveFile:(NSString *)fileName withPath:(NSString *)path withContents:(NSData *)data{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:path
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
    return [fileManager createFileAtPath:
            [path stringByAppendingString:fileName]
                                contents:data
                              attributes:nil];
}

/**
 *  在沙盒中的document文件夹中创建多级文件夹或文件
 *
 *  @param fileFullPath 完整路径+文件名
 *  @param data         写入的数据
 */
+ (NSString *)fileManagerCreateFileWithFullPath:(NSString *)fileFullPath withContents:(NSData *)data {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 沙盒中的document目录
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    // 最终完整的文件路径+文件名
    NSString *finalFilePath = [NSString stringWithFormat:@"%@", documentPath];
    // 切割传进来的文件路径
    NSArray *pathArray = [fileFullPath componentsSeparatedByString:@"/"];
    
    for (NSInteger i = 0; i < pathArray.count; i++) {
        NSString *fileOrPath = pathArray[i];
        finalFilePath = [finalFilePath stringByAppendingPathComponent:fileOrPath];
        if ([fileOrPath containsString:@"."]) {
            [fileManager createFileAtPath:finalFilePath contents:data attributes:nil];
        } else {
            if (![fileManager fileExistsAtPath:finalFilePath isDirectory:nil]) {
                [fileManager createDirectoryAtPath:finalFilePath withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }
    }
    NSLog(@"finalFilePath = %@", finalFilePath);
    return finalFilePath;
}

/**
 *  在沙盒中的document文件夹中查找文件或者文件夹下列的所有文件
 *
 *  @param filePath 文件名或者路径名
 *
 *  @return NSString或者NSArray
 */
+ (id)fileManagerSearchFileWithPath:(NSString *)filePath {
    // 沙盒中的document目录
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    // 最终完整的文件路径+文件名
    NSString *finalFilePath = [NSString stringWithFormat:@"%@", documentPath];
    // 切割传进来的文件路径
    NSArray *pathArray = [filePath componentsSeparatedByString:@"/"];
    // 文件的名称
    NSString *fileName = nil;
    
    for (NSInteger i = 0; i < pathArray.count; i++) {
        NSString *fileOrPath = pathArray[i];
        if ([fileOrPath containsString:@"."]) {
            fileName = fileOrPath;
            break;
        } else {
            finalFilePath = [finalFilePath stringByAppendingPathComponent:fileOrPath];
        }
    }
    
    NSMutableArray *array = [self fileManagerAllFilesAtPath:finalFilePath];
    if (!fileName) {
        return array;
    } else {
        for (NSString *file in array) {
            // 这里一定要做个判断。如果file为NSArray，说明是下一级目录，可以忽略
            if (![file isKindOfClass:[NSString class]]) continue;
                
            if ([[file lastPathComponent] isEqualToString:fileName]) {
                return file;
            }
        }
    }
    return nil;
}

/**
 *  创建缓存文件
 *
 *  @param fileName 文件名
 *
 */
+ (NSString *)fileManagerCreateCacheFile:(NSString *)fileName withContents:(NSData *)data {
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"cache"];
    BOOL result;
    if (data) {
        result = [self fileManagerSaveFile:[NSString stringWithFormat:@"/%@", fileName] withPath:path withContents:data];
    } else {
        result = [self fileManagerSaveFile:fileName withPath:path withContents:data];
    }
    if (result) {
        NSLog(@"创建%@文件成功", fileName);
        return [path stringByAppendingPathComponent:fileName];
    } else {
        NSLog(@"创建%@文件失败", fileName);
        return nil;
    }
}

/**
 *  读取缓存文件
 *
 *  @param fileName 文件名
 *
 */
+ (NSString *)fileManagerReadCacheFile:(NSString *)fileName {
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"cache"];
    NSMutableArray *array = [self fileManagerAllFilesAtPath:path];
    NSLog(@"读取的文件:%@", fileName);
    for (NSString *file in array) {
        if ([[file lastPathComponent] isEqualToString:fileName]) {
            return file;
        }
    }
    return nil;
}

/**
 *  删除指定路径的文件
 *
 *  @param fileName 文件名
 *  @param path     路径名
 *
 *  @return 成功返回YES
 */
+ (BOOL)fileManagerDeleteFile:(NSString *)fileName withPath:(NSString *)path {
    
//    NSLog(@"删除指定路径的文件，fileName = %@, path = %@", fileName, path);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (!fileName) {
        return [fileManager removeItemAtPath:path error:nil];
    } else {
        return [fileManager removeItemAtPath:[path stringByAppendingString:fileName] error:nil];
    }
}

/**
 *  遍历目录下所有的文件
 *
 *  @param path 路径
 *
 *  @return 所有的文件
 */
+ (NSMutableArray *)fileManagerAllFilesAtPath:(NSString *)path {
    
    NSMutableArray *pathArray = [NSMutableArray array];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *tempArray = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for (NSString *fileName in tempArray) {
        BOOL flag = YES;
        NSString *fullPath = [path stringByAppendingPathComponent:fileName];
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&flag]) {
            if (!flag) {
                // ignore .DS_Store
                if (![[fileName substringToIndex:1] isEqualToString:@"."]) {
                    [pathArray addObject:fullPath];
                }
            }
            else {
                [pathArray addObject:[self fileManagerAllFilesAtPath:fullPath]];
            }
        }
    }
    
    return pathArray;
}

/**
 *  在沙盒Document中移动文件
 *
 *  @param files   从哪个路径下移动
 *  @param toPath 到哪个路径
 */
+ (void)fileManagerMoveFile:(id)files toPath:(NSString *)toPath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // 1.先创建toPath文件夹
    NSString *fileName = [self fileManagerCreateFileWithFullPath:toPath withContents:nil];
    
    if ([files isKindOfClass:[NSString class]]) {
        fileName = [fileName stringByAppendingPathComponent:[files lastPathComponent]];
        [fileManager moveItemAtPath:files toPath:fileName error:nil];
    } else if ([files isKindOfClass:[NSArray class]]) { // 多个文件移动到toPath中
        for (NSString *file in files) {
            [self fileManagerMoveFile:file toPath:toPath];
        }
    }
}

/**
 *  重命名文件夹
 *
 *  @param folderName 重命名后的名字
 *  @param beforeName 重命名前的名字
 */
+ (void)fileManagerChangeFolderName:(NSString *)folderName beforeName:(NSString *)beforeName {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *beforeFolder = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(),beforeName];
    NSString *afterFolder = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(),folderName];
    
    NSLog(@"beforeFolder = %@, afterFolder = %@", beforeFolder, afterFolder);
    
    [fm createDirectoryAtPath:afterFolder withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:beforeFolder];
    NSLog(@"dirEnum = %@", dirEnum);
    NSString *path;
    while ((path = [dirEnum nextObject]) != nil) {
        [fm moveItemAtPath:[NSString stringWithFormat:@"%@/%@",beforeFolder,path]
                    toPath:[NSString stringWithFormat:@"%@/%@",afterFolder,path]
                     error:NULL];
    }
    
    id instance = [self fileManagerSearchFileWithPath:beforeFolder];
    // 这里不能传afterFolder，因为fileManagerMoveFile中有对路径进行拼接
    [self fileManagerMoveFile:instance toPath:folderName];
    
    [fm removeItemAtPath:beforeFolder error:nil];
}

@end
