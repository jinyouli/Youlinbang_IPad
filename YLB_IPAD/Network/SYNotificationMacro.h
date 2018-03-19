//
//  SYNotificationMacro.h
//  YLB
//
//  Created by YAYA on 2017/3/13.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#ifndef SYNotificationMacro_h
#define SYNotificationMacro_h


#endif /* SYNotificationMacro_h */

#pragma mark - notification

#define SYNOTICE_ReadedProvisionNotification @"sy_SYReadedProvision"  //已读登录页的条款
#define SYNOTICE_LOGIN_CHANGED     @"sy_userlogin_changed"
#define SYNOTICE_REFRESH_GUARD     @"sy_addGuard_refresh"   //添加了新门禁后，刷新HOME页面的门禁列表
#define SYNOTICE_REFLASH_PERSONAL_INFO     @"sy_reflash_personal_info"  //刷新个人信息
#define SYNOTICE_WECHAT_SHARE     @"sy_weixin_share"  //微信分享通知
#define SYNOTICE_QQ_SHARE     @"sy_qq_share"  //QQ分享通知
#define SYNOTICE_REFLASH_HOUSE_SUBACCOUNT     @"sy_Reflash_House_SubAccount"  //刷新房屋子账号通知
#define SYNOTICE_ResponseIdentifyAuthenticationErrorCode @"sy_esponseIdentifyAuthenticationErrorCode"  //身份认证失败
#define SYNOTICE_RepairsGetNotification @"sy_RepairsGetNotification"   // 接单
#define SYNOTICE_RepairsReplyNotification  @"sy_RepairsReplyNotification"// 回复
#define SYNOTICE_RepairsCompleteNotification @"sy_RepairsCompleteNotification"// 完成工单
#define SYNOTICE_OTHERUSERLOGIN  @"sy_OTHERUSERLOGIN"  // 用户被踢推送
#define SYNOTICE_MessageNotification  @"sy_MessageNotification" // 推送信息
#define SYNOTICE_ADNotification @"sy_ADNotification"  // 广告推送
#define SYNOTICE_NewsVersionNotification @"sy_NewsVersionNotification"// 新版本推送
#define SYNOTICE_TodayHeadlineNotification @"sy_TodayHeadlineNotification"// 今日头条
#define SYNOTICE_RepairOrderComplete @"sy_SYNOTICE_RepairOrderComplete" //确认工单
#define SYNOTICE_RepairOrderGetBack  @"sy_SYNOTICE_RepairOrderGetBack" //返单
#define SYNOTICE_Binded_Neighbor @"sy_SYNOTICE_Binded_Neighbor"    //绑定了社区后，要刷新二级IP和对应的数据
#define SYNOTICE_Update_NewRepair @"sy_Update_NewRepair"  //新建工单后刷新列表

#define SYNOTICE_Close_SYGuardMonitorViewController @"sy_Close_SYGuardMonitorViewController"  //当没有网络或者呼叫错误的时候，收到这个通知就关闭视频对话页
#define SYNOTICE_NetworkStateChanged @"sy_networkStateChanged" //网络状态改变

#define SYNOTICE_ShowReflashingLinphone @"sy_ShowReflashingLinphone" //视频监控门口机不在线时，主线程会卡死，必须等Linphone视频监控结束，所以现在退出视频监控页，在主页显示菊花

#define SYNOTICE_DissMissGuardView @"sy_DissMissGuardView"  //有呼叫进来后，如果之前正在显示监控弹框，就删掉弹框
