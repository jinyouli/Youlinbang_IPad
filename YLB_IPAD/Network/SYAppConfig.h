//
//  SYAppConfig.h
//  YLB
//
//  Created by YAYA on 2017/3/13.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYCanBindingModel;

#define isAfteriOS7 (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0) //ios7之后 （包含IOS7）
#define isAfteriOS8 (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) //ios8之后
#define isAfteriOS9 (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_9_0) //ios9之后
#define isAfteriOS10 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height


//========== 第三方分享=========
#define WXAppID         @"wx4858adb4def0b0be"
#define WXSecret        @"235f76609e6d58cd23a938732823c925"
#define QQAppID         @"1105517726"
#define QQAppKey        @"KEYfR1qVRpg4RAWEooF"
#define SinaAppKey      @"664240183"
#define SinaAppSecret   @"60c41d0550a9f119736ad7b323ab53c4"
#define SinaRedirectURL @"http://sns.whalecloud.com/sina2/callback"

#define APPID   @"1127316147"

//========== 个推==========
#define kGtAppId        @"6jPFOPu4Rz7IG1iw21nHV7"
#define kGtAppKey       @"5lCLCzEbxn5XhjrLlNTFK9"
#define kGtAppSecret    @"oxlZuM5FIaAYpEUHS8bAA6"

//======版本号，用于是否显示新特性===========
#define NewFeatureVersionKey @"NewFeatureVersionKey"

//========== 个推==========
//个推对应的命令字，实际上就是cmd对应的字符串
/** 派单个推 */
#define SYREPAIRS_SEND @"0910"
/** 接单个推 */
#define SYREPAIRS_GET @"0911"
/** 完成工单个推 */
#define SYREPAIRS_COMPLETE @"0912"
/** 转单个推 */
#define SYREPAIRS_CHANGE @"0913"
/** 回复个推 */
#define SYREPAIRS_REPLY @"0914"
/** 评论个推 */
#define SYREPAIRS_COMMENT @"0915"
/** 提醒转单个推 */
#define SYREPAIRS_REMIND @"0916"
/** 系统结束工单个推 */
#define SYREPAIRS_FINISH @"0917"
/** 催单个推 */
#define SYREPAIRS_REMINDER @"0918"
/** 新建工单个推 */
#define SYREPAIRS_CREATE @"0919"
/** 返单个推 */
#define SYREPAIRS_RETURN @"0920"
/** 取消工单个推 */
#define SYREPAIRS_CANCEL @"0921"
/** 帐号在用户在其他设备登录提示 */
#define SYOTHERUSERLOGIN @"0819"
/** 推送信息 */
#define SYMESSAGE @"0711"
/** 推送信息之个人消息 */
#define SYMESSAGE_PERSONAL @"0810"
/** 推送信息之社区消息 */
#define SYMESSAGE_COMMUNITY @"0811"
/** 推送信息之系统消息 */
#define SYMESSAGE_SYSTEM @"0812"
/** 广告推送 */
#define SYAD @"0712"
/** 新版本推送 */
#define SYNEWSVERSION @"0815"
/** 今日头条 */
#define SYTODAYHEADLINE @"0818"

#define UserDefaultUserNameKey  @"ylb_UserDefaultUserNameKey_text11"   // 存放数组，每个数组存放一个字典，Key是userid value是字典，分别存账号，密码，绑定社区和选择的门禁
#import "SYLinphoneStatus.h"

@interface SYAppConfig : NSObject

@property (nonatomic, copy) NSString *base_url;
@property (nonatomic, assign) BOOL isSpeaker; //是否是扬声器
@property (nonatomic, assign) BOOL isSipLogined; //是否sip已经登录
@property (nonatomic, assign) BOOL isPlayingSipVideo; //是否视频监控中

//绑定的社区信息
@property (nonatomic,copy) NSString *fneibor_flag; //绑定的社区编号
@property (nonatomic,strong) SYCanBindingModel *bindedModel;    //绑定的社区
@property (nonatomic,strong) NSMutableArray *selectedGuardMArr;   //从全部门禁里面选择的门禁 （首页全部门禁上面）存放SYLockListModel
@property (nonatomic, assign) int nMessageNotificationState;
@property (nonatomic,copy) NSString *password;
@property (nonatomic,copy) NSString *account;
@property (nonatomic,copy) NSString *secondPlatformIPStr;   //二级平台URL

@property (nonatomic,strong) NSMutableArray *myNeighborLockList;    //全部门禁列表  存放SYLockListModel
@property (nonatomic, assign) SYConnectivityState networkState; //网络状态

@property (nonatomic, copy) NSString *guardDisplayName; //门口机呼叫过来的名字


+ (SYAppConfig *)shareInstance;

+ (NSString *)syUUID;

+ (NSString *)baseURL;

//=====历史账号和密码===
+ (NSArray *)getUserLoginInfoAccountAndPassword;
+ (BOOL)getUserLoginInfoWithUserID:(unsigned long)userID;    //通过USERID拿用户信息
+ (void)saveUserLoginInfo;

+ (BOOL)isSpeaker;

//历史所有门禁
//+ (void)saveMyNeighborList;

//在本机切换过的所有社区的以选择的门禁
+ (void)saveMyHistoryNeighborLockList;

+ (NSString *)appVersion;
+ (NSString *)appDisplayName;   //app name
+ (BOOL)isShowNewFeature;

+ (BOOL)isSipLogined;

//是否全部都是空格
+ (BOOL)contactIsEmpty:(NSString *) str;

+ (SYConnectivityState)networkState;

+ (BOOL)isPlayingSipVideo;//是否视频监控中

+ (NSString *)guardDisplayName;  //门口机呼叫过来的名字

@end
