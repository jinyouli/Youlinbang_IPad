//
//  SYPersonalSpaceHttpDAO.m
//  YLB
//
//  Created by YAYA on 2017/4/4.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYPersonalSpaceHttpDAO.h"

@implementation SYPersonalSpaceHttpDAO

- (void)getUserConfigInfoWithUserName:(NSString *)username Succeed:(void(^)(SYPersonalSpaceModel *model))successBlock fail:(void(^)(NSError *error))errorBlock{

    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }

    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Get_UserConfigInfo RequestType:SYRequest_Get Body:tmpDic];

    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            SYPersonalSpaceModel *model = [SYPersonalSpaceModel mj_objectWithKeyValues:responseInfo.result];
            model.headerImg = [SYLoginInfoModel shareUserInfo].personalSpaceModel.headerImg;
            [SYLoginInfoModel shareUserInfo].personalSpaceModel = model;
            [SYLoginInfoModel saveWithSYLoginInfo];
            
            if (successBlock) {
                successBlock(model);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_REFLASH_PERSONAL_INFO object:nil];
            });
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"获取用户个人设置信息失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)setUserConfigInfoWithUserName:(NSString *)username WithAlias:(NSString *)alias WithMotto:(NSString *)motto WithHeadUrl:(NSString *)headUrl WithEmail:(NSString *)email WithGesturePwd:(NSString *)gesturePwd Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
    if (alias) {
        [tmpDic setObject:alias forKey:@"alias"];
    }
    if (motto) {
        [tmpDic setObject:motto forKey:@"motto"];
    }
    if (headUrl) {
        [tmpDic setObject:headUrl forKey:@"head_url"];
    }
    if (email) {
        [tmpDic setObject:email forKey:@"email"];
    }
    if (gesturePwd) {
        [tmpDic setObject:gesturePwd forKey:@"gesture_pwd"];
    }

    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Set_UserConfigInfo RequestType:SYRequest_Post Body:tmpDic];
    
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            if (successBlock) {
                successBlock();
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"设置用户个人设置信息失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)getQiniuTokenSucceed:(void(^)(NSString *token))successBlock fail:(void(^)(NSError *error))errorBlock{
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Get_QiNiu_Token RequestType:SYRequest_Get Body:nil];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            SYPersonalSpaceModel *model = [SYPersonalSpaceModel mj_objectWithKeyValues:responseInfo.result];

            if (successBlock) {
                successBlock(model.upload_token);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"获取七牛上传凭证(token)失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)uploadImgToQiniuWithImgArr:(NSArray *)imgArr Succeed:(void(^)(QNResponseInfo *info, NSString *key, NSDictionary *resp))successBlock fail:(void(^)(NSError *error))errorBlock{
    
    if (!imgArr || imgArr.count == 0) {
        if (errorBlock) {
            errorBlock(nil);
        }
        return;
    }
    
    [self getQiniuTokenSucceed:^(NSString *token) {
        
        if (!token) {
            return ;
        }
        
        QNUploadManager *upManager = [[QNUploadManager alloc] init];
        
        for (UIImage *newImage in imgArr) {
            
            NSData *data = UIImageJPEGRepresentation(newImage, 1.0);
            
            NSString *keyHeader = [NSMutableString stringWithFormat:@"ios/ylb"];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:[NSString stringWithFormat:@"yyyyMMddHHmmss"]];
            NSString *keyTime = [formatter stringFromDate:[NSDate date]];
            
            NSString *kRandomAlphabet = @"0123456789";
            NSMutableString *randomString = [NSMutableString stringWithCapacity:10];
            for (int i = 0; i < 10; i++) {
                [randomString appendFormat: @"%C", [kRandomAlphabet characterAtIndex:arc4random_uniform((u_int32_t)[kRandomAlphabet length])]];
            }
            NSString *keyRandom = randomString;
            NSString *keyString = [NSString stringWithFormat:@"%@/%@/%@.png", keyHeader, keyTime, keyRandom];
            
            // key为图片的名字
            [upManager putData:data key:keyString token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                
                if (info.isOK) {
                    if (successBlock) {
                        successBlock(info, key, resp);
                    }
                }
                else{
                    if (errorBlock) {
                        errorBlock(info.error);
                    }
                }
                NSLog(@"path:%@, - ResponseInfo, code:%@, msg:%@, result:%@", info.host, @(info.statusCode), key, info.error.userInfo);
            } option:nil];
        }

    } fail:^(NSError *error) {
        
    }];
}

- (void)saveFeedbackWithUserID:(long)userID WithContent:(NSString *)content Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (content) {
        [tmpDic setObject:content forKey:@"content"];
    }
    [tmpDic setObject:@(userID) forKey:@"user_id"];
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Save_Feedback RequestType:SYRequest_Post Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {

            if (successBlock) {
                successBlock();
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"提交反馈意见失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
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
