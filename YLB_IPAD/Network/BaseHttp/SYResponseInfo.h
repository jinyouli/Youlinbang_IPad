//
//  SYResponseInfo.h
//  YLB
//
//  Created by YAYA on 2017/3/7.
//  Copyright © 2017年 Sayee Intelligent Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SYResponseSuccessCode (0)
#define SYResponseIdentifyAuthenticationErrorCode (3) //身份验证失败

@interface SYResponseInfo : NSObject

@property (nonatomic,assign) NSInteger code;
@property (nonatomic,copy) NSString *msg;
@property (nonatomic,strong) id result;

//ituns 返回的数据（用于版本更新）
@property (nonatomic,assign) NSInteger resultCount;
@property (nonatomic,strong) id results;
@end
