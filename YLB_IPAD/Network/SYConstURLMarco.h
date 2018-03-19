//
//  SYConstURLMarco.h
//  YLB
//
//  Created by YAYA on 2017/3/13.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#ifndef SYConstURLMarco_h
#define SYConstURLMarco_h


#endif /* SYConstURLMarco_h */

#pragma mark - 一级平台接口
//获取短信验证码
#define SY_Send_Verify_Code_Message @"/users/send_verify_code_message.json"
//获取APP应用列表
#define SY_Get_Appmanage_List @"/tenement_user/get_appmanage_list.json"
//获取用户个人设置信息
#define SY_Get_UserConfigInfo @"/config/get_userConfigInfo.json"
//设置用户个人设置信息
#define SY_Set_UserConfigInfo @"/upload/set_userConfigInfo.json"
//旧TOKEN更换新TOKEN
#define SY_Get_New_Token @"/fir_platform/get_token_by_old_token.json"
//保存用户绑定小区信息
#define SY_Save_Nei_Binding_User @"/users/save_nei_binding_user.json"
//修改密码（通过原密码）
#define SY_Change_PW_By_Old_PW @"/users/change_pwd_by_old_pwd.json"
//修改密码（通过短信验证码）
#define SY_Change_PW_By_Verify_Code @"/users/change_pwd_by_verify_code.json"
//注册
#define SY_Regester @"/users/register_user.json"
//登录
#define SY_Login @"/users/login.json"
// 登陆后获取社区列表以及ip    //安装APP，首次登录成功后 获取的社区列表
#define SY_Get_Nei_IP_List @"/users/get_nei_ip_list.json"
//验证账户有效性
#define SY_User_Exists @"/users/user_exists.json"
//保存标签与clientId关系（一级平台）
#define SY_Save_Tag_Cid @"/push_msg/save_tag_cid.json"
//pad端获取二维码接口
#define SY_GetUnionCode @"/pad/get_pad_key.json"

#pragma mark - 二级平台接口
//获取广告信息        首页上面的banner广告图
#define SY_Get_Advertisment @"/users/get_mobile_adpublish_list.json"

#define SY_Pad_Logout @"/pad/user_logout_pad.json"

//获取推荐列表
#define SY_Get_RecommendList @"/users/get_recommended_adpublish_and_todaynews.json"

//获取小区信息    (我的社区)
#define SY_Get_Neibor_Msg @"/tenement/get_neibor_msg.json"
// 获取工单列表  物业报修和物业投诉
#define SY_Get_Repairs_List @"/tenement_user/get_repairs_list.json"
//用户配置信息 -- 获取房产列表（房产列表页面）
#define SY_My_Config_Info @"/config/my_config_info.json"
//获取工单评论 (物业报修)
#define SY_Get_Work_Order_Details @"/tenement/get_work_order_details.json"
//门禁解锁(app请求门口机开锁)
#define SY_Remote_Unlock @"/device/remote_unlock.json"
//使用分页获取公告信息(返回结果与时间参数获取公告一样)  navigationbar右上角的消息
#define SY_Get_NoticeByPager @"/device/get_NoticeByPager.json"
//获取七牛上传凭证(token)
#define SY_Get_QiNiu_Token @"/upload/get_upload_token.json"
//获取头条
#define SY_Get_TodayNews @"/config/get_todayNews.json"

//ipad登录
#define SY_Get_IPADLogin @"/device/login.json"

//用户获取预约随机密码
#define SY_Random_Password @"/users/random_password.json"
#define SY_QiFuRandom_Password @"/users/get_qifu_password.json"
//提交报修单
#define SY_Submit_New_Repair @"/upload/save_repairs.json"
// 设置房屋免打扰
#define SY_Update_OF_Disturbing @"/users/update_of_disturbing.json"
// 获取房屋子账号（子账号管理列表）
#define SY_Get_House_Subaccount @"/config/get_house_subaccount.json"
//设定房屋被叫号码（子账号管理详情）
#define SY_Set_Called_Number @"/config/set_called_number.json"
//添加(修改)/删除子账号
#define SY_Set_House_Subaccount @"/config/set_house_subaccount.json"
//催单
#define SY_Update_Of_Reminder @"/tenement_user/update_of_reminder.json"
//保存工单相关信息记录（回复、评论[用户确认完成]、转单提醒记录、转单结果记录、完成工单，用户返单、用户取消工单）
#define SY_Save_Repairs_Record @"/upload/save_repairs_record.json"
//用户确认完成工单   (由于接口设计问题，用户点击确认完成的时候需要调用两个接口，一个保存用户评论内容（/tenement/save_repairs_record.json），本接口更新工单状态以及评分)
#define SY_Update_Repairs_To_Finish @"/tenement_user/update_repairs_to_finish.json"
//保存反馈意见
#define SY_Save_Feedback @"/tenement_user/save_feedback.json"
// 判断用户是否可以绑定该小区
#define SY_Is_Can_Binding @"/users/is_can_binding.json"
//请求锁列表 (常用门禁列表)
#define SY_My_Lock_List @"/config/my_lock_list.json"
//物业动态列表获取
#define SY_Tenement_Msg_List @"/tenement/get_push_msg_list.json"

