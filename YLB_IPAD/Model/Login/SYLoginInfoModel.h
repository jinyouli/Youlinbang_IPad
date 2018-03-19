//
//  SYLoginInfoModel.h
//  YLB
//
//  Created by YAYA on 2017/3/8.
//  Copyright © 2017年 Sayee Intelligent Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYNeiborIDListModel.h"
#import "SYCanBindingModel.h"
#import "SYConfigInfoModel.h"
#import "SYPersonalSpaceModel.h"
#import "SYUserInfoModel.h"

@interface SYLoginInfoModel : NSObject

//第一次登录
@property (nonatomic,copy) NSString *random_num;   //第一次登录返回的随机码

//第二次登录
@property (nonatomic,strong) SYUserInfoModel *userInfoModel;

//获取短信验证码  (不需要存本地)
@property (nonatomic,assign) BOOL isphone_existed;  //手机号是否存在

//缓存
@property (nonatomic,strong) SYConfigInfoModel *configInfoModel;    //用户获取配置信息 (房产管理列表)
@property (nonatomic,strong) SYPersonalSpaceModel *personalSpaceModel;  //个人信息
@property (nonatomic,assign) BOOL isLogin;
@property (nonatomic,assign) NSTimeInterval lastTimeChangeToken;    //上次更新token的时间
@property (nonatomic,assign) BOOL isShowGesturePath;  //是否显示手势密码轨迹
@property (nonatomic,copy) NSString *geTuiClientID; //个推client_id   在登录接口中用，可选
@property (nonatomic,assign) BOOL isAllowPushMessage;    //是否允许消息推送
@property (nonatomic, assign) BOOL isAllowNoDusturbMode; //是否打开勿扰模式
@property (nonatomic, assign) BOOL isAllowHardDusturbMode; //是否打开勿扰模式


//从USERDEFAULT拿登录信息
+ (SYLoginInfoModel *)shareUserInfo;

//将登陆信息存到USERDEFAULT
+ (void)saveWithSYLoginInfo;

+ (void)loginOut;   //退出登录

+ (BOOL)isLogin;//登录状态
@end
