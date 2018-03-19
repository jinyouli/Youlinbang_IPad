//
//  SYLoginHttpDAO.m
//  YLB
//
//  Created by YAYA on 2017/3/9.
//  Copyright © 2017年 Sayee Intelligent Technology. All rights reserved.
//

#import "SYLoginHttpDAO.h"

@implementation SYLoginHttpDAO

- (void)getVerifyCodeWithMobilePhone:(NSString *)phone Succeed:(void(^)(SYLoginInfoModel *model))successBlock fail:(void(^)(NSError *error))errorBlock{

    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (phone) {
        [tmpDic setObject:phone forKey:@"mobile_phone"];
    }
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Send_Verify_Code_Message RequestType:SYRequest_Get Body:tmpDic];
    
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            SYLoginInfoModel *model = [SYLoginInfoModel mj_objectWithKeyValues:responseInfo.result];
            if (successBlock) {
                successBlock(model);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"获取验证码失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)getRandomPasswordWithSipNumber:(NSString *)number WithUsername:(NSString *)username Succeed:(void(^)(SYRandomPWModel *model))successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
    if (number) {
        [tmpDic setObject:number forKey:@"sip_number"];
    }
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Random_Password RequestType:SYRequest_Get Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            SYRandomPWModel *model = [SYRandomPWModel mj_objectWithKeyValues:responseInfo.result];
            if (successBlock) {
                successBlock(model);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"随机密码获取失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)getQiFuPasswordWithSipNumber:(NSString *)number neibor_id:(NSString *)neibor_id WithUsername:(NSString *)username Succeed:(void(^)(SYRandomPWModel *model))successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
    if (number) {
        [tmpDic setObject:number forKey:@"sip_number"];
    }
    if (neibor_id) {
        [tmpDic setObject:neibor_id forKey:@"neibor_id"];
    }
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_QiFuRandom_Password RequestType:SYRequest_Get Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            SYRandomPWModel *model = [SYRandomPWModel mj_objectWithKeyValues:responseInfo.result];
            if (successBlock) {
                successBlock(model);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"密码获取失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)loiginWithPassword:(NSString *)password WithUsername:(NSString *)username Succeed:(void(^)(SYUserInfoModel *model))successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
    [tmpDic setObject:@(time) forKey:@"tick"];
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Login RequestType:SYRequest_Post Body:tmpDic];
    
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            SYLoginInfoModel *model = [SYLoginInfoModel mj_objectWithKeyValues:responseInfo.result];
            
            //============第二次请求==============
            [tmpDic removeAllObjects];
            if (username) {
                [tmpDic setObject:username forKey:@"username"];
            }
            if (password) {
                NSString *md5Pw = [[NSString stringWithFormat:@"%@%@%@",model.random_num, @(time), [password md5]] md5];
                [tmpDic setObject:md5Pw forKey:@"password"];
            }
            [tmpDic setObject:@(time) forKey:@"tick"];
            [tmpDic setObject:@(4) forKey:@"client_type"];  //1.门口机 2.Android设备 3.管理机 4.IOS设备
            if ([SYLoginInfoModel shareUserInfo].geTuiClientID) {
                [tmpDic setObject:[SYLoginInfoModel shareUserInfo].geTuiClientID forKey:@"client_id"];
            }
            
            SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Login RequestType:SYRequest_Post Body:tmpDic];
            
            [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
                
                if (responseInfo.code == SYResponseSuccessCode) {
                    
                    SYUserInfoModel *userModel = [SYUserInfoModel mj_objectWithKeyValues:responseInfo.result];
                    
                    [SYLoginInfoModel shareUserInfo].isLogin = YES;
                    //更换token的更新时间
                    [SYLoginInfoModel shareUserInfo].lastTimeChangeToken = [[NSDate date] timeIntervalSince1970];
                    [SYLoginInfoModel shareUserInfo].userInfoModel = userModel;
                    [SYLoginInfoModel saveWithSYLoginInfo];
                    
                    [SYAppConfig getUserLoginInfoWithUserID:userModel.user_id];
                    [SYAppConfig shareInstance].account = userModel.username;
                    [SYAppConfig shareInstance].password = password;
                    [SYAppConfig saveUserLoginInfo];
                    
                    //登录的通知
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_LOGIN_CHANGED object:nil];
                    });
                    
                    if (successBlock) {
                        successBlock(userModel);
                    }
                }
                else{
                    if (errorBlock) {
                        NSError *err = [NSError errorWithDomain:@"第二次请求失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                        errorBlock(err);
                    }
                }
            } failHandler:^(NSError *error) {
                if (errorBlock) {
                    errorBlock(error);
                }
            }];
            //==================================
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"登录失败" code:responseInfo.code userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)registerWithPassword:(NSString *)password WithUsername:(NSString *)username WithVerifyCode:(NSString *)verifyCode WithMobilePhone:(NSString *)mobilePhone Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
    if (password) {
        [tmpDic setObject:[password md5] forKey:@"password"];
    }
    if (verifyCode) {
        [tmpDic setObject:verifyCode forKey:@"verify_code"];
    }
    if (mobilePhone) {
        [tmpDic setObject:mobilePhone forKey:@"mobile_phone"];
    }
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Regester RequestType:SYRequest_Post Body:tmpDic];
    
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            SYLoginInfoModel *model = [SYLoginInfoModel mj_objectWithKeyValues:responseInfo.result];
            if (successBlock) {
                successBlock(model);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"随机密码获取失败" code:responseInfo.code userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)changeNewPWWithOldPassword:(NSString *)oldPassword WithUsername:(NSString *)username WithNewPassword:(NSString *)newPassword Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
    if (oldPassword) {
        [tmpDic setObject:[oldPassword md5] forKey:@"old_password"];
    }
    if (newPassword) {
        [tmpDic setObject:[newPassword md5] forKey:@"new_password"];
    }
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Change_PW_By_Old_PW RequestType:SYRequest_Post Body:tmpDic];
    
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            if (successBlock) {
                successBlock();
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"修改密码（通过原密码）失败" code:responseInfo.code userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)changeNewPWWithVerifyCode:(NSString *)verifyCode WithUsername:(NSString *)username WithNewPassword:(NSString *)newPassword Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
    if (verifyCode) {
        [tmpDic setObject:verifyCode forKey:@"verify_code"];
    }
    if (newPassword) {
        [tmpDic setObject:[newPassword md5] forKey:@"new_password"];
    }
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Change_PW_By_Verify_Code RequestType:SYRequest_Post Body:tmpDic];
    
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            if (successBlock) {
                successBlock();
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"修改密码（通过验证码）失败" code:responseInfo.code userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)checkUserExistsWithMobilePhone:(NSString *)mobilePhone WithUsername:(NSString *)username WithEmail:(NSString *)email Succeed:(void(^)(SYUserExistModel *model))successBlock fail:(void(^)(NSError *error))errorBlock{

    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (mobilePhone) {
        [tmpDic setObject:mobilePhone forKey:@"mobile_phone"];
    }
    if (email) {
        [tmpDic setObject:email forKey:@"email"];
    }
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_User_Exists RequestType:SYRequest_Get Body:tmpDic];
    
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
        
            SYUserExistModel *model = [SYUserExistModel mj_objectWithKeyValues:responseInfo.result];
            
            if (successBlock) {
                successBlock(model);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"验证账户有效性失败" code:responseInfo.code userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)saveTagCidWithTagJson:(NSString *)tagJson WithCid:(NSString *)cid cidType:(int)cidType Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (tagJson) {
        [tmpDic setObject:tagJson forKey:@"tag_json"];
    }
    if (cid) {
        [tmpDic setObject:cid forKey:@"cid"];
    }
    
    if ([SYLoginInfoModel shareUserInfo].userInfoModel.username) {
        [tmpDic setObject:[SYLoginInfoModel shareUserInfo].userInfoModel.username forKey:@"username"];
    }
    
    [tmpDic setObject:@(cidType) forKey:@"cid_type"];
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Save_Tag_Cid RequestType:SYRequest_Post Body:tmpDic];
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            if (successBlock) {
                successBlock();
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"保存标签与clientId关系失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

#pragma mark -- pad端获取二维码接口
- (void)getUnionCode:(NSString *)secret_key successBlock:(void(^)(NSString *qr_code))successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (secret_key) {
        [tmpDic setObject:secret_key forKey:@"secret_key"];
    }
    
   // [tmpDic setObject:@"ipad_ios" forKey:@"device_type"];
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_GetUnionCode RequestType:SYRequest_Post Body:tmpDic];
    
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            if (successBlock) {
                successBlock(responseInfo.result[@"qr_code"]);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"获取二维码失败" code:responseInfo.code userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

@end
