//
//  SYDiscoverHttpDAO.m
//  YLB
//
//  Created by YAYA on 2017/4/4.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYDiscoverHttpDAO.h"

@implementation SYDiscoverHttpDAO

- (void)getAppManageListSucceed:(void(^)(NSArray *modelArr))successBlock fail:(void(^)(NSError *error))errorBlock{

    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Get_Appmanage_List RequestType:SYRequest_Get Body:nil];
    
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            NSArray *model = [SYAppManageListModel mj_objectArrayWithKeyValuesArray:responseInfo.result];
            if (successBlock) {
                successBlock(model);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"获取APP应用列表失败" code:responseInfo.code  userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)getNoticeByPagerWithNeigborID:(NSString *)neigborID WithUsername:(NSString *)username WithNoticeType:(int)noticeType WithAppType:(int )appType WithCurrentPage:(int)currentPage WithPageSize:(int)pageSize Succeed:(void(^)(NSArray *modelArr))successBlock fail:(void(^)(NSError *error))errorBlock{
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (neigborID) {
        [tmpDic setObject:neigborID forKey:@"neigbor_id"];
    }
    if (username) {
        [tmpDic setObject:username forKey:@"username"];
    }
    if (noticeType > 0) {
        [tmpDic setObject:@(noticeType) forKey:@"notice_type"];
    }
    [tmpDic setObject:@(2) forKey:@"app_type"];
    [tmpDic setObject:@(currentPage) forKey:@"current_page"];
    [tmpDic setObject:@(pageSize) forKey:@"page_size"];
    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Get_NoticeByPager RequestType:SYRequest_Get Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            NSArray *model = [SYNoticeByPagerModel mj_objectArrayWithKeyValuesArray:responseInfo.result];
            
            if (successBlock) {
                successBlock(model);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"使用分页获取公告信息失败" code:responseInfo.code userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)checkUpdateWithAppID:(NSString *)appID Succeed:(void(^)())successBlock fail:(void(^)(NSError *error))errorBlock{

    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (appID) {
        [tmpDic setObject:appID forKey:@"id"];
    }

    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:@"/lookup" RequestType:SYRequest_Get Body:tmpDic];
    resuestInfo.baseHost = @"http://itunes.apple.com";
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {

            BOOL isUpdate = NO;
            NSArray *resultsArr = (NSArray *)responseInfo.results;
            if ([resultsArr isKindOfClass:[NSArray class]] && resultsArr.count > 0) {
                NSDictionary *dic = resultsArr.firstObject;
                NSString * version = [dic objectForKey:@"version"];

                //以"."分隔数字然后分配到不同数组
                NSArray * serverArray = [version componentsSeparatedByString:@"."];
                NSArray * localArray = [[SYAppConfig appVersion] componentsSeparatedByString:@"."];
                
                for (int i = 0; i < localArray.count; i++) {

                    int nLocalVersion = [[localArray objectAtIndex:i] intValue];
                    int nServerVersion = 0;
                    if (serverArray.count > i) {
                        nServerVersion =  [[serverArray objectAtIndex:i] intValue];
                    }
                    else{
                        //版本错误
                        isUpdate = NO;
                        break;
                    }
                    
                    if (nServerVersion > nLocalVersion) {
                        //有新版本，提示！
                        isUpdate = YES;
                        break;
                    }else if (nServerVersion < nLocalVersion){
                        break;
                    }
                }
            }

            if (isUpdate) {
                if (successBlock) {
                    successBlock();
                }
            }else{
                if (errorBlock) {
                    NSError *err = [NSError errorWithDomain:@"没有有版本更新" code:0 userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                    errorBlock(err);
                }
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"获取是否有版本更新" code:responseInfo.resultCount userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
                errorBlock(err);
            }
        }
    } failHandler:^(NSError *error) {
        if (errorBlock) {
            errorBlock(error);
        }
    }];
}

- (void)getTenementMsgListWithWorkerID:(NSString *)workerID WithUserID:(unsigned long long)userID Succeed:(void(^)(NSArray *modelArr))successBlock fail:(void(^)(NSError *error))errorBlock{

    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
    if (workerID) {
        [tmpDic setObject:workerID forKey:@"worker_id"];
    }
    [tmpDic setObject:@(userID) forKey:@"user_id"];

    
    SYRequestInfo *resuestInfo = [SYRequestInfo requestInfoWithPath:SY_Tenement_Msg_List RequestType:SYRequest_Get Body:tmpDic];
    resuestInfo.baseHost = [SYAppConfig shareInstance].secondPlatformIPStr;
    [SYBaseHttp requestWithInfo:resuestInfo completeHandler:^(SYResponseInfo *responseInfo) {
        
        if (responseInfo.code == SYResponseSuccessCode) {
            
            NSArray *model = [SYNoticeByPagerModel mj_objectArrayWithKeyValuesArray:responseInfo.result];
            
            if (successBlock) {
                successBlock(model);
            }
        }
        else{
            if (errorBlock) {
                NSError *err = [NSError errorWithDomain:@"物业动态列表获取失败" code:responseInfo.code userInfo:@{NSLocalizedDescriptionKey:responseInfo.msg ? : @""}];
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
