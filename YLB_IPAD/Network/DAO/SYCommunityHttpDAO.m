//
//  SYCommunityHttpDAO.m
//  YLB
//
//  Created by sayee on 17/3/27.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYCommunityHttpDAO.h"

@implementation SYCommunityHttpDAO


- (void)getMyLockListWithNeigborID:(NSString *)neigborID WithUsername:(NSString *)username Succeed:(void(^)(NSArray *modelArr))successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
    if (neigborID) {
        [tmpDic setObject:neigborID forKey:@"neigbor_id"];
    }
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_My_Lock_List RequestType:SYRequest_Get Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            NSArray *lockListArr = nil;
            if ([responseInfo.result isKindOfClass:[NSDictionary class]]) {
                lockListArr = [(NSDictionary *)responseInfo.result objectForKey:@"lockList"];
            }
            NSArray *modelArr = [SYLockListModel mj_objectArrayWithKeyValuesArray:lockListArr];
            
            // 门口机呼过来没有domain_sn  解锁接口必须带domain_sn, 所以请求全部门禁列表里面，用sipnumber找对应的domain_sn
            NSMutableDictionary *dicTmp = [[NSMutableDictionary alloc] init];
            for (SYLockListModel *model in modelArr) {
                
                //删除全部门禁里面没有的已选择的门禁
                [dicTmp setObject:model forKey:model.sip_number];
            }
            
            NSMutableArray *arrTmp = [[NSMutableArray alloc] init];
            [[SYAppConfig shareInstance].selectedGuardMArr enumerateObjectsUsingBlock:^(SYLockListModel *lockModel, NSUInteger idx, BOOL * _Nonnull stop) {
                
                for (SYLockListModel *model in modelArr) {
                    
                    //删除全部门禁里面没有的已选择的门禁
                    if ([lockModel.sip_number isEqualToString:model.sip_number]) {
                        [arrTmp addObject:model];
                        continue;
                    }
                    
                }
            }];
            @synchronized ([SYAppConfig shareInstance].selectedGuardMArr) {
                [[SYAppConfig shareInstance].selectedGuardMArr removeAllObjects];
                [[SYAppConfig shareInstance].selectedGuardMArr addObjectsFromArray:arrTmp];
            }
            
            @synchronized ([SYAppConfig shareInstance].selectedGuardMArr) {
                [[SYAppConfig shareInstance].myNeighborLockList removeAllObjects];
                [[SYAppConfig shareInstance].myNeighborLockList addObjectsFromArray:modelArr];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_REFRESH_GUARD object:nil];
            [SYAppConfig saveUserLoginInfo];
            
            if (successBlock) {
                successBlock(modelArr);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"获取解锁权限列表失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)getMyConfigInfoWithNeigborID:(NSString *)neigborID WithUsername:(NSString *)username Succeed:(void(^)(SYConfigInfoModel *configInfo))successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
    if (neigborID) {
        [tmpDic setObject:neigborID forKey:@"neigbor_id"];
    }
    [tmpDic setObject:@(2) forKey:@"type"];  //客户端类型  可选（1为安卓，2为Ios） int
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_My_Config_Info RequestType:SYRequest_Get Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            SYConfigInfoModel *model = [SYConfigInfoModel mj_objectWithKeyValues:responseInfo.result];
            
            if (successBlock) {
                successBlock(model);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"用户获取配置信息获取房产列表失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)updateDisturbingWithHouseID:(NSString *)houseID WithDisturbing:(int)disturbing Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock{
   
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (houseID) {
        [tmpDic setObject:houseID forKey:@"house_id"];
    }
    [tmpDic setObject:@(disturbing) forKey:@"is_disturbing"];
    
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Update_OF_Disturbing RequestType:SYRequest_Get Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            if (successBlock) {
                successBlock();
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"用户设置房间免打扰失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)setCalledNumberWithCalledNumber:(NSString *)calledNumber WithUsername:(NSString *)username WithHouseID:(NSString *)houseID Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (calledNumber) {
        [tmpDic setObject:calledNumber forKey:@"called_number"];
    }
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
    if (houseID) {
        [tmpDic setObject:houseID forKey:@"house_id"];
    }
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Set_Called_Number RequestType:SYRequest_Post Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            if (successBlock) {
                successBlock();
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"设定房屋被叫号码失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)setHouseSubAccountWithCalledNumber:(NSString *)subAccount WithUsername:(NSString *)username WithHouseID:(NSString *)houseID WithAlias:(NSString *)alias WithIsAdd:(BOOL)isAdd WithIsCalledNumber:(BOOL)isCalledNumber Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (subAccount) {
        [tmpDic setObject:subAccount forKey:@"sub_account"];
    }
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
    if (houseID) {
        [tmpDic setObject:houseID forKey:@"house_id"];
    }
    if (alias) {
        [tmpDic setObject:alias forKey:@"alias"];
    }
    if (isCalledNumber) {
        [tmpDic setObject:@"true" forKey:@"is_called_number"];
    }else{
        [tmpDic setObject:@"false" forKey:@"is_called_number"];
    }
    if (isAdd) {
        [tmpDic setObject:@"true" forKey:@"is_add"];
    }else{
        [tmpDic setObject:@"false" forKey:@"is_add"];
    }
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Set_House_Subaccount RequestType:SYRequest_Post Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;// @"http://192.168.1.15:23456";//
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            if (successBlock) {
                successBlock();
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"添加/删除子账号失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)getHouseSubaccountWithHouseID:(NSString *)houseID WithUsername:(NSString *)username Succeed:(void(^)(NSArray *arrModel))successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
    if (houseID) {
        [tmpDic setObject:houseID forKey:@"house_id"];
    }
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Get_House_Subaccount RequestType:SYRequest_Post Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            NSArray *arrModel = [SYSubAccountModel mj_objectArrayWithKeyValuesArray:responseInfo.result];
            if (successBlock) {
                successBlock(arrModel);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"获取房屋子账号失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)getNeiIPListWithUsername:(long)userID Succeed:(void(^)(NSArray *neiIPList))successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    [tmpDic setObject:@(userID) forKey:@"user_id"];
    [tmpDic setObject:@1 forKey:@"is_new_list"];
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Get_Nei_IP_List RequestType:SYRequest_Get Body:tmpDic];
    
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            NSArray *subAccountArr = [SYNeiIPListModel mj_objectArrayWithKeyValuesArray:responseInfo.result];
            if (successBlock) {
                successBlock(subAccountArr);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"设登陆后获取社区列表以及ip失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)getCanBindingWithNeiName:(NSString *)neiName WithUsername:(NSString *)username WithUserID:(long)userID URL:(NSString *)url Succeed:(void(^)(SYCanBindingModel *canBindingModel))successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (neiName) {
        [tmpDic setObject:neiName forKey:@"nei_name"];
    }
    NSLog(@"neiName = %@",neiName);
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
    [tmpDic setObject:@(userID) forKey:@"user_id"];
    
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Is_Can_Binding RequestType:SYRequest_Get Body:tmpDic];
    if (url) {
        resuestInfo.baseHost = url;
    }
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            SYCanBindingModel *canBindingModel = [SYCanBindingModel mj_objectWithKeyValues:responseInfo.result];
            if (successBlock) {
                successBlock(canBindingModel);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"判断用户是否可以绑定该小区失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)saveNeiBindingUserWithNeighborHoodsID:(NSString *)neighborHoodsID WithUserID:(int)userID Succeed:(void(^)(NSString *resultID))successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (neighborHoodsID) {
        [tmpDic setObject:neighborHoodsID forKey:@"ip_id"];
    }
    [tmpDic setObject:@(userID) forKey:@"user_id"];
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Save_Nei_Binding_User RequestType:SYRequest_Post Body:tmpDic];
    
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            NSString *resultID = responseInfo.result;
            if (successBlock) {
                successBlock(resultID);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"保存用户绑定小区信息失败" code:responseInfo.code userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)getTodayNewsWithNeigborID:(NSString *)neigborID WithUsername:(NSString *)username WithStartTime:(NSString *)startTime WithEndTime:(NSString *)endTime WithIsPage:(int)isPager WithCurrentPage:(int)currentPage WithPageSize:(int)pageSize Succeed:(void(^)(NSArray *modelArr))successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (neigborID) {
        [tmpDic setObject:neigborID forKey:@"neigbor_id"];
    }
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
    if (startTime) {
        [tmpDic setObject:startTime forKey:@"start_time"];
    }
    if (endTime) {
        [tmpDic setObject:endTime forKey:@"end_time"];
    }
    [tmpDic setObject:@(isPager) forKey:@"is_pager"];
    [tmpDic setObject:@(currentPage) forKey:@"current_page"];
    [tmpDic setObject:@(pageSize) forKey:@"page_size"];
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Get_TodayNews RequestType:SYRequest_Get Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            NSArray *model = [SYTodayNewsModel mj_objectArrayWithKeyValuesArray:responseInfo.result];
   
            if (successBlock) {
                successBlock(model);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"获取头条失败" code:responseInfo.code userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)getAdvertismentWithNeighborID:(NSString *)neigborID WithUserName:(NSString *)username Succeed:(void(^)(NSArray *modelArr))successBlock fail:(void(^)(NSError *error))errorBlock{

    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    
    if (neigborID) {
        [tmpDic setObject:neigborID forKey:@"neigbor_id"];
    }
    
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
    
    [tmpDic setObject:@(2) forKey:@"app_type"];
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Get_Advertisment RequestType:SYRequest_Get Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {

            NSArray *model = [SYAdvertInfoListModel mj_objectArrayWithKeyValuesArray:responseInfo.result];
            if (successBlock) {
                successBlock(model);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"获取广告失败" code:responseInfo.code userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

//获取推荐列表
- (void)getRecommendListWithNeighborID:(NSString *)neigborID Succeed:(void(^)(NSArray *modelArr))successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    
    if (neigborID) {
        [tmpDic setObject:neigborID forKey:@"neigbor_id"];
    }
        
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Get_RecommendList RequestType:SYRequest_Get Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            NSArray *model = [SYAdpublishModel mj_objectArrayWithKeyValuesArray:responseInfo.result];
            if (successBlock) {
                successBlock(model);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"获取推荐列表失败" code:responseInfo.code userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)getNeiborMsgWithDepartmentID:(NSString *)departmentID Succeed:(void(^)(SYMyCommunityModel *model))successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (departmentID) {
        [tmpDic setObject:departmentID forKey:@"department_id"];
    }
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Get_Neibor_Msg RequestType:SYRequest_Get Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            SYMyCommunityModel *model = [SYMyCommunityModel mj_objectWithKeyValues:responseInfo.result];
            
            if (successBlock) {
                successBlock(model);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"获取小区信息失败" code:responseInfo.code userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)getRepairsListWithCurrentPage:(int)currentPage WithOrderType:(int)orderType WithPageSize:(int)pageSize WithStatus:(int)status WithRoomIDs:(NSString *)roomIDs Succeed:(void(^)(NSArray *modelArr))successBlock fail:(void(^)(NSError *error))errorBlock;{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (roomIDs) {
        [tmpDic setObject:roomIDs forKey:@"room_ids"];
    }
    [tmpDic setObject:@([SYLoginInfoModel shareUserInfo].userInfoModel.user_id) forKey:@"user_id"];
    [tmpDic setObject:@(currentPage) forKey:@"current_page"];
    [tmpDic setObject:@(orderType) forKey:@"order_type"];
    [tmpDic setObject:@(pageSize) forKey:@"page_size"];
    [tmpDic setObject:@(status) forKey:@"status"];
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Get_Repairs_List RequestType:SYRequest_Get Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            NSArray *model = [SYPropertyRepairModel mj_objectArrayWithKeyValuesArray:responseInfo.result];
            
            if (successBlock) {
                successBlock(model);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"获取工单列表失败" code:responseInfo.code userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)getWorkOrderDetailsWithCurrentPage:(int)currentPage WithRepairsID:(NSString *)repairsID WithPageSize:(int)pageSize Succeed:(void(^)(NSArray *modelArr))successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (repairsID) {
        [tmpDic setObject:repairsID forKey:@"repairs_id"];
    }
    [tmpDic setObject:@(currentPage) forKey:@"current_page"];
    [tmpDic setObject:@(pageSize) forKey:@"page_size"];
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Get_Work_Order_Details RequestType:SYRequest_Get Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            NSArray *model = [SYRepairOrderCommentModel mj_objectArrayWithKeyValuesArray:responseInfo.result];
            
            if (successBlock) {
                successBlock(model);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"获取工单评论失败" code:responseInfo.code userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)remoteUnlockWithUserName:(NSString *)username DomainSN:(NSString *)domainSN WithType:(NSString *)type WithTime:(long long)time Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock{

    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
    if (domainSN) {
        [tmpDic setObject:domainSN forKey:@"domain_sn"];
    }
    if (type) {
        [tmpDic setObject:type forKey:@"type"];
    }
    [tmpDic setObject:@(time) forKey:@"time"];
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Remote_Unlock RequestType:SYRequest_Post Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {

        if (responseInfo.code == SYResponseSuccessCode) {

            if (successBlock) {
                successBlock();
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"门禁解锁失败" code:responseInfo.code userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)getNewTokenWithOldToken:(NSString *)token WithUsername:(NSString *)username Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
    if (token) {
        [tmpDic setObject:token forKey:@"token"];
    }
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Get_New_Token RequestType:SYRequest_Get Body:tmpDic];
    
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            SYUserInfoModel *model = [SYUserInfoModel mj_objectWithKeyValues:responseInfo.result];
            
            [SYLoginInfoModel shareUserInfo].userInfoModel.token = model.token;
            [SYLoginInfoModel shareUserInfo].userInfoModel.token_timeout = model.token_timeout;
            [SYLoginInfoModel saveWithSYLoginInfo];
            
            if (successBlock) {
                successBlock();
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"token更换失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)submitNewRepairWithUserID:(long)userID WithOrderNature:(int)orderNature WithImageURL:(NSString *)imageURL WithLinkMan:(NSString *)linkMan WithPhone:(NSString *)phone WithRoomID:(NSString *)roomID WithServiceContent:(NSString *)serviceContent Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (imageURL) {
        [tmpDic setObject:imageURL forKey:@"image"];
    }
    if (linkMan) {
        [tmpDic setObject:linkMan forKey:@"linkman"];
    }
    [tmpDic setObject:@(orderNature) forKey:@"order_nature"];
    if (phone) {
        [tmpDic setObject:phone forKey:@"phone"];
    }
    if (roomID) {
        [tmpDic setObject:roomID forKey:@"room_id"];
    }
    if (serviceContent) {
        [tmpDic setObject:serviceContent forKey:@"servicecontent"];
    }
    [tmpDic setObject:@(userID) forKey:@"user_id"];
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Submit_New_Repair RequestType:SYRequest_Post Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {

            if (successBlock) {
                successBlock();
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"token更换失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)reminderWithRepairsID:(NSString *)repairsID WithUserID:(long)userID Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock{

    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (repairsID) {
        [tmpDic setObject:repairsID forKey:@"repairs_id"];
    }
    [tmpDic setObject:@(userID) forKey:@"user_id"];
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Update_Of_Reminder RequestType:SYRequest_Get Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
        
            if (successBlock) {
                successBlock();
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"催单失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)saveRepairsRecordWithUserID:(long)userID WithType:(int)type WithRepairsID:(NSString *)repairsID WithContent:(NSString *)content WithOwner:(int)owner WithImageURL:(NSString *)imageURL Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (imageURL) {
        [tmpDic setObject:imageURL forKey:@"image"];
    }
    if (repairsID) {
        [tmpDic setObject:repairsID forKey:@"repairs_id"];
    }
    if (content) {
        [tmpDic setObject:content forKey:@"content"];
    }
    [tmpDic setObject:@(owner) forKey:@"owner"];
    [tmpDic setObject:@(type) forKey:@"type"];
    [tmpDic setObject:@(userID) forKey:@"user_id"];
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Save_Repairs_Record RequestType:SYRequest_Post Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            if (successBlock) {
                successBlock();
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_RepairOrderComplete object:nil];
            });
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"保存工单相关信息记录失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)updateRepairsToFinishWithUserID:(long)userID WithRepairsID:(NSString *)repairsID WithScore:(int)score Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (repairsID) {
        [tmpDic setObject:repairsID forKey:@"repairs_id"];
    }
    [tmpDic setObject:@(score) forKey:@"score"];
    [tmpDic setObject:@(userID) forKey:@"user_id"];
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Update_Repairs_To_Finish RequestType:SYRequest_Get Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            if (successBlock) {
                successBlock();
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_RepairOrderComplete object:nil];
            });
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"用户确认完成工单失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

//iPad退出登录
- (void)padLogoutWithUserName:(NSString *)username Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
        
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Pad_Logout RequestType:SYRequest_Post Body:tmpDic];
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            NSLog(@"结果==%@",responseInfo.result);

            if (successBlock) {
                successBlock();
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"iPad退出登录失败" code:responseInfo.code userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
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
