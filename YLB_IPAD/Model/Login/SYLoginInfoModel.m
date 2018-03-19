//
//  SYLoginInfoModel.m
//  YLB
//
//  Created by YAYA on 2017/3/8.
//  Copyright © 2017年 Sayee Intelligent Technology. All rights reserved.
//

#import "SYLoginInfoModel.h"
#import "MJExtension.h"

#define SYLoginInfoStorageName (@"SYLoginInfoStorageName")

static SYLoginInfoModel *loginInfo = nil;

@implementation SYLoginInfoModel

- (instancetype)init{
    return [[self class] shareUserInfo];
}

- (instancetype)initPrivate {
    //调用父类init方法避免死循环
    if (self = [super init]) {

    }
    return self;
}

+ (void) saveWithSYLoginInfo
{
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];

    //第一次登录
    if (loginInfo.random_num != nil) {
        [tmpDic setValue:loginInfo.random_num forKey:@"random_num"];
    }
    
    //第二次登录
    NSDictionary *userInfoModelDic = loginInfo.userInfoModel.mj_keyValues;
    if (userInfoModelDic != nil) {
        [tmpDic setValue:userInfoModelDic forKey:@"userInfoModel"];
    }

    //缓存
    NSDictionary *configInfoModelDic = loginInfo.configInfoModel.mj_keyValues;
    if (configInfoModelDic != nil) {
        [tmpDic setValue:configInfoModelDic forKey:@"configInfoModel"];
    }
    NSData *personalSpaceModelData = [NSKeyedArchiver archivedDataWithRootObject:loginInfo.personalSpaceModel];
    if (personalSpaceModelData != nil) {
        [tmpDic setValue:personalSpaceModelData forKey:@"personalSpaceModel"];
    }
    [tmpDic setValue:@(loginInfo.lastTimeChangeToken) forKey:@"lastTimeChangeToken"];
    [tmpDic setValue:@(loginInfo.isShowGesturePath) forKey:@"isShowGesturePath"];
    [tmpDic setValue:@(loginInfo.isAllowPushMessage) forKey:@"isAllowPushMessage"];

    
    
    [tmpDic setValue:@(loginInfo.isLogin) forKey:@"isLogin"];

    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:tmpDic forKey:SYLoginInfoStorageName];
    [userDefault synchronize];
}

+ (SYLoginInfoModel *)shareUserInfo{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSDictionary *loginInfoDic = [userDefault objectForKey:SYLoginInfoStorageName];
        
        loginInfo = [[SYLoginInfoModel alloc] initPrivate];

        //第一次登录
        loginInfo.random_num = [loginInfoDic objectForKey:@"random_num"];
        
        //第二次登录
        loginInfo.userInfoModel = [SYUserInfoModel mj_objectWithKeyValues:[loginInfoDic objectForKey:@"userInfoModel"]];

        //缓存
        loginInfo.configInfoModel = [SYConfigInfoModel mj_objectWithKeyValues:[loginInfoDic objectForKey:@"configInfoModel"]];
        
        id personalSpaceModelData = [loginInfoDic objectForKey:@"personalSpaceModel"];
        if (personalSpaceModelData) {
            loginInfo.personalSpaceModel = [NSKeyedUnarchiver unarchiveObjectWithData:personalSpaceModelData];
        }
        loginInfo.lastTimeChangeToken = [[loginInfoDic objectForKey:@"lastTimeChangeToken"] doubleValue];
        if (![loginInfoDic objectForKey:@"isShowGesturePath"]) {
            loginInfo.isShowGesturePath = YES;
        }else{
            loginInfo.isShowGesturePath = [[loginInfoDic objectForKey:@"isShowGesturePath"] boolValue];
        }
        if (![loginInfoDic objectForKey:@"isAllowPushMessage"]) {
            loginInfo.isAllowPushMessage = YES;
        }else{
            loginInfo.isAllowPushMessage = [[loginInfoDic objectForKey:@"isAllowPushMessage"] boolValue];
        }
    
        

        loginInfo.isLogin = [[loginInfoDic objectForKey:@"isLogin"] boolValue]; //放最后
    });
    return loginInfo;
}

+ (void)loginOut{

    //第一次登录
    loginInfo.random_num = nil;

    //第二次登录
    loginInfo.userInfoModel = nil;
    
    //缓存
    [SYAppConfig shareInstance].bindedModel = nil;
    [SYAppConfig shareInstance].selectedGuardMArr = nil;
    [SYAppConfig shareInstance].password = nil;
    [SYAppConfig shareInstance].account = nil;
    
    loginInfo.configInfoModel = nil;
    loginInfo.personalSpaceModel = nil;
    loginInfo.isLogin = NO;
    loginInfo.lastTimeChangeToken = 0;
    loginInfo.isShowGesturePath = NO;
    loginInfo.isAllowPushMessage = YES;
    
    //二级平台URL
    [SYAppConfig shareInstance].secondPlatformIPStr = nil;

    [SYLoginInfoModel saveWithSYLoginInfo];

    //登录的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_LOGIN_CHANGED object:nil];
}

+ (BOOL)isLogin{
    return [SYLoginInfoModel shareUserInfo].isLogin;
}

- (void)setIsLogin:(BOOL)isLogin{
    _isLogin = isLogin;
    if (isLogin) {
        NSLog(@"=======login in=======");
    }
    else{
        NSLog(@"=======login out=======");
    }
}

@end
