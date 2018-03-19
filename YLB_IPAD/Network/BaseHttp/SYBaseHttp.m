//
//  SYBaseHttp.m
//  YLB
//
//  Created by YAYA on 2017/3/7.
//  Copyright © 2017年 Sayee Intelligent Technology. All rights reserved.
//

#import "SYBaseHttp.h"
#import "AFHTTPSessionManager.h"

@implementation SYBaseHttp

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - public
+ (void)requestWithInfo:(SYRequestInfo *)requestInfo
        completeHandler:(SYCompleteHandler)completeHandler
            failHandler:(SYFailHandler)failHandler{

    SYBaseHttp *baseHttp = [[SYBaseHttp alloc] init];
    [baseHttp requestWithInfo:requestInfo completeBlock:^(SYResponseInfo *responseInfo) {
        
        if (completeHandler) {
            completeHandler(responseInfo);
        }
        
        //token过期
        if (responseInfo.code == SYResponseIdentifyAuthenticationErrorCode) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"alreadyLogin"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_ResponseIdentifyAuthenticationErrorCode object:nil];
            });
        }
    } errorBlock:^(NSError *error) {
        
        NSLog(@"错误信息==%@",error);
        NSString *errMsg = [NSString stringWithFormat:@"%zd",error.code];
        if ([errMsg isEqualToString:@"-1009"]) {
            
            [Common addAlertWithTitle:@"网络连接失败"];
            NSDictionary *dic = [NSDictionary dictionaryWithObject:@"" forKey:NSLocalizedDescriptionKey];
            NSError *err = [NSError errorWithDomain:NSURLErrorDomain code:-1009 userInfo:dic];

            if (failHandler) {
                failHandler(err);
            }
        }else{
            if (failHandler) {
                failHandler(error);
            }
        }
    }];
}


#pragma mark - private
- (void)requestWithInfo:(SYRequestInfo *)requestInfo
          completeBlock:(SYCompleteHandler)completeBlock
             errorBlock:(SYFailHandler)errorBlock{
 
    AFHTTPSessionManager *afHttpManager = [AFHTTPSessionManager manager];
    //[afHttpManager.requestSerializer setValue:[SYAppConfig syUUID] forHTTPHeaderField:@"uuid"];
    
    [afHttpManager.requestSerializer setValue:@"ipad_ios" forHTTPHeaderField:@"device"];
    [afHttpManager.requestSerializer setValue:[SYLoginInfoModel shareUserInfo].userInfoModel.username forHTTPHeaderField:@"username"];
    
    [afHttpManager.requestSerializer setValue:[SYLoginInfoModel shareUserInfo].userInfoModel.token forHTTPHeaderField:@"token"];
    
    // 设置超时时间
    [afHttpManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    afHttpManager.requestSerializer.timeoutInterval = 10.f;
    [afHttpManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];

    requestInfo.baseHost = [requestInfo.baseHost stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([requestInfo.baseHost isEqualToString:@""] || requestInfo.baseHost.length == 0 || requestInfo.baseHost == nil) {
        return;
    }
    
    NSLog(@"token==%@",[SYLoginInfoModel shareUserInfo].userInfoModel.token);
    NSString *requestURL = [NSString stringWithFormat:@"%@%@",requestInfo.baseHost, requestInfo.path];
    NSLog(@"URL===%@,%@",requestURL,requestInfo.bodyInfo);
    
    if (requestInfo.requestType == SYRequest_Get) {
        [afHttpManager GET:requestURL parameters:requestInfo.bodyInfo progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            SYResponseInfo *responseInfo = [SYResponseInfo mj_objectWithKeyValues:responseObject];
            NSLog(@"Request_Get path:%@, - ResponseInfo, code:%@, msg:%@, result:%@", requestInfo.path, @(responseInfo.code), responseInfo.msg, responseInfo.result);

            if (completeBlock) {
                completeBlock(responseInfo);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (errorBlock) {
                errorBlock(error);
            }
            NSLog(@"path:%@, - error:%@", requestInfo.path, error.domain);
        }];
    }
    else if (requestInfo.requestType == SYRequest_Post){
        [afHttpManager POST:requestURL parameters:requestInfo.bodyInfo progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            SYResponseInfo *responseInfo = [SYResponseInfo mj_objectWithKeyValues:responseObject];
            NSLog(@"Request_Post path:%@, - ResponseInfo, code:%@, msg:%@, data:%@", requestInfo.path, @(responseInfo.code), responseInfo.msg, responseInfo.result);
            
            if (completeBlock) {
                completeBlock(responseInfo);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (errorBlock) {
                errorBlock(error);
            }
            NSLog(@"path:%@, - error:%@", requestInfo.path, error.domain);
        }];
    }
    else{
        if (errorBlock) {
            NSDictionary *dic = [NSDictionary dictionaryWithObject:@"请求失败，requestType错误" forKey:NSLocalizedDescriptionKey];
            NSError *err = [NSError errorWithDomain:@"请求失败，requestType错误" code:-1 userInfo:dic];
            errorBlock(err);
            NSLog(@"path:%@, - error:%@", requestInfo.path, err.domain);
        }
    }
}
@end
