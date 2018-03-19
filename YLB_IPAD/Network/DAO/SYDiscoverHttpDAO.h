//
//  SYDiscoverHttpDAO.h
//  YLB
//
//  Created by YAYA on 2017/4/4.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYBaseHttp.h"
#import "SYAppManageListModel.h"
#import "SYNoticeByPagerModel.h"

@interface SYDiscoverHttpDAO : NSObject

/**
 *  获取APP应用列表 get /tenement_user/get_appmanage_list.json    一级平台
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)getAppManageListSucceed:(void(^)(NSArray *modelArr))successBlock fail:(void(^)(NSError *error))errorBlock;



/**
 *  使用分页获取公告信息(返回结果与时间参数获取公告一样)  navigationbar右上角的消息 get /device/get_NoticeByPager.json    二级平台
 *  @param currentPage   当前页
 *  @param pageSize  每页显示数
 *  @param username   用户名
 *  @param neigborID   社区ID
 *  @param noticeType   类型    1：我的消息  2：社区消息  3：系统消息      不带参数查询全部
 *  @param appType   应用类型     1：门口机   2：移动端APP
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)getNoticeByPagerWithNeigborID:(NSString *)neigborID WithUsername:(NSString *)username WithNoticeType:(int)noticeType WithAppType:(int )appType WithCurrentPage:(int)currentPage WithPageSize:(int)pageSize Succeed:(void(^)(NSArray *modelArr))successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  获取是否有版本更新 get http://itunes.apple.com/xxxxxxx
 *  @param appID  appID
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)checkUpdateWithAppID:(NSString *)appID Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock;


/**
 *  物业动态列表获取 get /tenement/get_push_msg_list.json
 *  @param workerID  workerID
 *  @param userID  userID
 *  @param successBlock 成功回调
 *  @param errorBlock   失败回调
 *
 */
- (void)getTenementMsgListWithWorkerID:(NSString *)workerID WithUserID:(unsigned long long)userID Succeed:(void(^)(NSArray *modelArr))successBlock fail:(void(^)(NSError *error))errorBlock;
@end
