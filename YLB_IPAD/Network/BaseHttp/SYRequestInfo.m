//
//  SYRequestInfo.m
//  YLB
//
//  Created by YAYA on 2017/3/7.
//  Copyright © 2017年 Sayee Intelligent Technology. All rights reserved.
//

#import "SYRequestInfo.h"
#import "SYAppConfig.h"

@implementation SYRequestInfo

+ (SYRequestInfo *)requestInfoWithPath:(NSString *)path RequestType:(SYRequestType)type Body:(NSDictionary *)bodyInfo{

    SYRequestInfo *requestInfo = [[SYRequestInfo alloc] init];
    requestInfo.baseHost = [SYAppConfig baseURL];
    requestInfo.path = path;
    requestInfo.requestType = type;
    requestInfo.bodyInfo = bodyInfo;
    return requestInfo;
}
@end
