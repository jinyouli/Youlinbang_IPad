//
//  SYBaseHttp.h
//  YLB
//
//  Created by YAYA on 2017/3/7.
//  Copyright © 2017年 Sayee Intelligent Technology. All rights reserved.
//  http://www.jianshu.com/p/11bb0d4dc649

#import <Foundation/Foundation.h>
#import "SYResponseInfo.h"
#import "SYRequestInfo.h"
#import "MJExtension.h"

@interface SYBaseHttp : NSObject

typedef void (^SYCompleteHandler)(SYResponseInfo *responseInfo);
typedef void (^SYFailHandler)(NSError *error);

+ (void)requestWithInfo:(SYRequestInfo *)requestInfo
                 completeHandler:(SYCompleteHandler)completeHandler
                     failHandler:(SYFailHandler)failHandler;
@end
