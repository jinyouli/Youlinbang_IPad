//
//  SYPersonalSpaceHttpDAO.h
//  YLB
//
//  Created by YAYA on 2017/4/4.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYBaseHttp.h"
#import "SYPersonalSpaceModel.h"
#import "QiniuSDK.h"

@interface SYPersonalSpaceHttpDAO : NSObject

/**
 *  获取用户个人设置信息 get /config/get_userConfigInfo.json    一级平台
 *  @param username     username
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)getUserConfigInfoWithUserName:(NSString *)username Succeed:(void(^)(SYPersonalSpaceModel *model))successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  设置用户个人设置信息 post /upload/set_userConfigInfo.json    一级平台
 *  @param username     username
 *  @param alias     昵称
 *  @param motto     格言
 *  @param headUrl     头像URL  上传七牛后，返回的URL
 *  @param email     email
 *  @param gesturePwd     手势密码
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)setUserConfigInfoWithUserName:(NSString *)username WithAlias:(NSString *)alias WithMotto:(NSString *)motto WithHeadUrl:(NSString *)headUrl WithEmail:(NSString *)email WithGesturePwd:(NSString *)gesturePwd Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  获取七牛上传凭证(token) get /upload/get_upload_token.json    二级平台
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)getQiniuTokenSucceed:(void(^)(NSString *token))successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  上传多张图片数据到七牛
 *
 *  @param imgArr     图片的路径
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 */
- (void)uploadImgToQiniuWithImgArr:(NSArray *)imgArr Succeed:(void(^)(QNResponseInfo *info, NSString *key, NSDictionary *resp))successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  提交反馈意见 post /tenement_user/save_feedback.json   二级平台
 *  @param userID     userID
 *  @param content     content
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)saveFeedbackWithUserID:(long)userID WithContent:(NSString *)content Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock;

@end
