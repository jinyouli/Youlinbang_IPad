//
//  SYLoginHttpDAO.h
//  YLB
//
//  Created by YAYA on 2017/3/9.
//  Copyright © 2017年 Sayee Intelligent Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYBaseHttp.h"
#import "SYLoginInfoModel.h"
#import "SYRandomPWModel.h"
#import "SYUserExistModel.h"

@interface SYLoginHttpDAO : NSObject


/**
 *  获取短信验证码 get /users/send_verify_code_message.json
 *
 *  @param phone        获取验证码的号码
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)getVerifyCodeWithMobilePhone:(NSString *)phone Succeed:(void(^)(SYLoginInfoModel *model))successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  随机密码获取 get /users/random_password.json  二级平台
 *
 *  @param number        sip账号
 *  @param username   用户名
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)getRandomPasswordWithSipNumber:(NSString *)number WithUsername:(NSString *)username Succeed:(void(^)(SYRandomPWModel *model))successBlock fail:(void(^)(NSError *error))errorBlock;

- (void)getQiFuPasswordWithSipNumber:(NSString *)number neibor_id:(NSString *)neibor_id WithUsername:(NSString *)username Succeed:(void(^)(SYRandomPWModel *model))successBlock fail:(void(^)(NSError *error))errorBlock;

/**
 *  登录 post /users/login.json   一级平台
 *
 *  @param password     password
 *  @param username   用户名
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)loiginWithPassword:(NSString *)password WithUsername:(NSString *)username Succeed:(void(^)(SYUserInfoModel *model))successBlock fail:(void(^)(NSError *error))errorBlock;

- (void)saveTagCidWithTagJson:(NSString *)tagJson WithCid:(NSString *)cid cidType:(int)cidType Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  注册 post users/register_user.json
 *
 *  @param password     password
 *  @param username   用户名
 *  @param verifyCode     短信验证码
 *  @param mobilePhone //手机号
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)registerWithPassword:(NSString *)password WithUsername:(NSString *)username WithVerifyCode:(NSString *)verifyCode WithMobilePhone:(NSString *)mobilePhone  Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  更换密码（通过原密码） post /users/change_pwd_by_old_pwd.json    一级平台
 *
 *  @param oldPassword     oldPassword
 *  @param newPassword     newPassword
 *  @param username   用户名
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)changeNewPWWithOldPassword:(NSString *)oldPassword WithUsername:(NSString *)username WithNewPassword:(NSString *)newPassword Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  更换密码（通过短信验证码） post /users/change_pwd_by_verify_code.json    一级平台
 *
 *  @param verifyCode     验证码
 *  @param newPassword     newPassword
 *  @param username   用户名
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)changeNewPWWithVerifyCode:(NSString *)verifyCode WithUsername:(NSString *)username WithNewPassword:(NSString *)newPassword Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock;




/**
 *  验证账户有效性 get /users/user_exists.json    一级平台
 *  3个参数至少有一个参数
 *  @param mobilePhone     手机号
 *  @param email     email
 *  @param username   用户名
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)checkUserExistsWithMobilePhone:(NSString *)mobilePhone WithUsername:(NSString *)username WithEmail:(NSString *)email Succeed:(void(^)(SYUserExistModel *model))successBlock fail:(void(^)(NSError *error))errorBlock;

#pragma mark -- pad端获取二维码接口
- (void)getUnionCode:(NSString *)secret_key successBlock:(void(^)(NSString *qr_code))successBlock fail:(void(^)(NSError *error))errorBlock;

@end
