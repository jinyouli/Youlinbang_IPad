//
//  SYRequestInfo.h
//  YLB
//
//  Created by YAYA on 2017/3/7.
//  Copyright © 2017年 Sayee Intelligent Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SYRequest_Get=0,
    SYRequest_Post=1,
}SYRequestType;

@interface SYRequestInfo : NSObject

@property (nonatomic,copy) NSString *baseHost;
@property (nonatomic,copy) NSString *path;
@property (nonatomic,assign) SYRequestType requestType;
@property (nonatomic,strong) NSDictionary *bodyInfo;

+ (SYRequestInfo *)requestInfoWithPath:(NSString *)path RequestType:(SYRequestType)type Body:(NSDictionary *)bodyInfo;
@end
