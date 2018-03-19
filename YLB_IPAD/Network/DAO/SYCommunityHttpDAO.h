//
//  SYCommunityHttpDAO.h
//  YLB
//
//  Created by sayee on 17/3/27.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYBaseHttp.h"
#import "SYConfigInfoModel.h"
#import "SYSubAccountModel.h"
#import "SYNeiIPListModel.h"
#import "SYCanBindingModel.h"
#import "SYTodayNewsModel.h"
#import "SYAdvertInfoListModel.h"
#import "SYMyCommunityModel.h"
#import "SYPropertyRepairModel.h"
#import "SYRecommendModel.h"

@interface SYCommunityHttpDAO : NSObject


/**
 *  获取解锁权限列表(全部门禁) get /config/my_lock_list.json    二级平台
 *
 *  @param neigborID        社区ID
 *  @param username   用户名
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)getMyLockListWithNeigborID:(NSString *)neigborID WithUsername:(NSString *)username Succeed:(void(^)(NSArray *modelArr))successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  用户获取配置信息获取房产列表（所有门禁） get /config/my_config_info.json      二级平台
 *
 *  @param neigborID        社区ID
 *  @param username   用户名
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)getMyConfigInfoWithNeigborID:(NSString *)neigborID WithUsername:(NSString *)username Succeed:(void(^)(SYConfigInfoModel *configInfo))successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  用户设置房间免打扰 get /users/update_of_disturbing.json  二级平台
 *
 *  @param houseID        房间id
 *  @param disturbing   将设置的状态  1为免打扰，0为可打扰（房间是否免打扰固定判断是否等于1，获取用户配置信息的时候该字段可能为空）  int
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)updateDisturbingWithHouseID:(NSString *)houseID WithDisturbing:(int)disturbing Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  设定房屋被叫号码 post /config/set_called_number.json    二级平台
 *
 *  @param calledNumber        被叫号码
 *  @param username   用户名
 *  @param houseID   房屋ID
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)setCalledNumberWithCalledNumber:(NSString *)calledNumber WithUsername:(NSString *)username WithHouseID:(NSString *)houseID Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  添加/删除子账号 post /config/set_house_subaccount.json 二级平台
 *
 *  @param subAccount        子账号
 *  @param username   用户名
 *  @param houseID   房屋ID
 *  @param alias   别名   添加子账号时必填
 *  @param isAdd   添加/删除    BOOL
 *  @param isCalledNumber   是否被叫号码  可选，默认为false
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)setHouseSubAccountWithCalledNumber:(NSString *)subAccount WithUsername:(NSString *)username WithHouseID:(NSString *)houseID WithAlias:(NSString *)alias WithIsAdd:(BOOL)isAdd WithIsCalledNumber:(BOOL)isCalledNumber Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  获取房屋子账号 post config/get_house_subaccount.json    二级平台
 *
 *  @param username   用户名
 *  @param houseID   房屋ID
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)getHouseSubaccountWithHouseID:(NSString *)houseID WithUsername:(NSString *)username Succeed:(void(^)(NSArray *arrModel))successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  登陆后获取社区列表以及ip get /users/get_nei_ip_list.json
 *
 *  @param userID   账号id    int
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)getNeiIPListWithUsername:(long)userID Succeed:(void(^)(NSArray *neiIPList))successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  判断用户是否可以绑定该小区 get /users/is_can_binding.json  二级平台（请求的IP和端口由服务器返回）  
 *
 *  @param username   用户名
 *  @param neiName   社区名字
 *  @param userID    登陆用户id
 *  @param url    二级平台url
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)getCanBindingWithNeiName:(NSString *)neiName WithUsername:(NSString *)username WithUserID:(long)userID URL:(NSString *)url Succeed:(void(^)(SYCanBindingModel *canBindingModel))successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  保存用户绑定小区信息 post save_nei_binding_user.json
 *
 *  @param neighborHoodsID   社区列表中返回的id
 *  @param userID    账号id
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)saveNeiBindingUserWithNeighborHoodsID:(NSString *)neighborHoodsID WithUserID:(int)userID Succeed:(void(^)(NSString *resultID))successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  社区头条 get /config/get_todayNews.json     二级平台
 *
 *  @param neigborID   社区id
 *  @param username    username
 *  @param startTime    开始时间    格式 yyyyMMddHHmmss
 *  @param endTime    结束时间   格式 yyyyMMddHHmmss
 *  @param isPager   是否开启分页 0不分页  1分页
 *  @param currentPage    当前页
 *  @param pageSize    每页数
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)getTodayNewsWithNeigborID:(NSString *)neigborID WithUsername:(NSString *)username WithStartTime:(NSString *)startTime WithEndTime:(NSString *)endTime WithIsPage:(int)isPager WithCurrentPage:(int)currentPage WithPageSize:(int)pageSize Succeed:(void(^)(NSArray *modelArr))successBlock fail:(void(^)(NSError *error))errorBlock;



/**
 *  获取广告信息 get /device/get_Advert.json      二级平台
 *
 *  @param neigborID   社区ID
 *  @param username    username
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)getAdvertismentWithNeighborID:(NSString *)neigborID WithUserName:(NSString *)username Succeed:(void(^)(NSArray *modelArr))successBlock fail:(void(^)(NSError *error))errorBlock;



/**
 *  获取小区信息 get /tenement/get_neibor_msg.json      二级平台
 *
 *  @param departmentID   物业公司id
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)getNeiborMsgWithDepartmentID:(NSString *)departmentID Succeed:(void(^)(SYMyCommunityModel *model))successBlock fail:(void(^)(NSError *error))errorBlock;



/**
 *  获取工单列表  物业报修和物业投诉 get /tenement_user/get_repairs_list.json      二级平台
 *
 *  @param currentPage   拿第几页数据 
 *  @param orderType    工单类型 '物业报修 = 1'  '物业投诉 = 2'
 *  @param status        1 待处理   2 正在处理   3 待确认  4 已完结
 *  @param pageSize    每页显示xx条
 *  @param roomIDs    roomIDs  //SY_My_Config_Info接口的SYConfigInfoModel里面的sipInfoList的所有house_id拼接;
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)getRepairsListWithCurrentPage:(int)currentPage WithOrderType:(int)orderType WithPageSize:(int)pageSize WithStatus:(int)status WithRoomIDs:(NSString *)roomIDs Succeed:(void(^)(NSArray *modelArr))successBlock fail:(void(^)(NSError *error))errorBlock;

//获取推荐列表
- (void)getRecommendListWithNeighborID:(NSString *)neigborID Succeed:(void(^)(NSArray *modelArr))successBlock fail:(void(^)(NSError *error))errorBlock;

//iPad退出登录
- (void)padLogoutWithUserName:(NSString *)username Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock;

/**
 *  获取工单评论  物业报修  get /tenement/get_work_order_details.json      二级平台
 *
 *  @param currentPage   拿第几页数据
 *  @param repairsID    工单ID
 *  @param pageSize    每页显示xx条
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)getWorkOrderDetailsWithCurrentPage:(int)currentPage WithRepairsID:(NSString *)repairsID WithPageSize:(int)pageSize Succeed:(void(^)(NSArray *modelArr))successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  门禁解锁(app请求门口机开锁)  POST /device/remote_unlock.json      二级平台
 *
 *  @param username   username
 *  @param domainSN   域sn
 *  @param time    时间戳
 *  @param type    开锁类型 0：直接开锁  1：通话中开锁
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)remoteUnlockWithUserName:(NSString *)username DomainSN:(NSString *)domainSN WithType:(NSString *)type WithTime:(long long)time Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  旧TOKEN更换新TOKEN GET /fir_platform/get_token_by_old_token.json
 *
 *  @param token     就的token
 *  @param username   用户名
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)getNewTokenWithOldToken:(NSString *)token WithUsername:(NSString *)username Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  提交报修单 POST /upload/save_repairs.json  二级平台
 *
 *  @param orderNature     工单类型'物业报修 = 1'  '物业投诉 = 2'
 *  @param imageURL   工单图片url  上传七牛后返回的url
 *  @param linkMan   联系人
 *  @param userID  userID
 *  @param roomID   roomID
 *  @param serviceContent   工单内容
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)submitNewRepairWithUserID:(long)userID WithOrderNature:(int)orderNature WithImageURL:(NSString *)imageURL WithLinkMan:(NSString *)linkMan WithPhone:(NSString *)phone WithRoomID:(NSString *)roomID WithServiceContent:(NSString *)serviceContent Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  物业报修 催单 GET /tenement_user/update_of_reminder.json   二级平台
 *
 *  @param repairsID     工单id
 *  @param userID   用户is
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)reminderWithRepairsID:(NSString *)repairsID WithUserID:(long)userID Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  保存工单相关信息记录（回复、评论、转单提醒记录、转单结果记录、完成工单，用户返单、用户取消工单） POST /upload/save_repairs_record.json  二级平台
 *
 *  @param content     回复内容
 *  @param repairsID   工单id
 *  @param owner   是否是业主 1业主 2非业主（用户端也可调用该接口保存回复）
 *  @param userID  userID
 *  @param imageURL   图片url 上传七牛后返回的url
 *  @param type   1表示工单回复，2表示工单评论，3表示处理人提醒转单记录，4表示派单人转单记录 5表示完成订单信息记录，6用户返单 ，7表示用户取消工单
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)saveRepairsRecordWithUserID:(long)userID WithType:(int)type WithRepairsID:(NSString *)repairsID WithContent:(NSString *)content WithOwner:(int)owner WithImageURL:(NSString *)imageURL Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  用户确认完成工单 GET /tenement_user/update_repairs_to_finish.json  二级平台
 *
 *  @param score     评分
 *  @param repairsID   工单id
 *  @param userID  userID
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)updateRepairsToFinishWithUserID:(long)userID WithRepairsID:(NSString *)repairsID WithScore:(int)score Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock;


@end
