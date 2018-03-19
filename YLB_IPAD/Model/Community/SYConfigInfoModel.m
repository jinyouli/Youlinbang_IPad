//
//  SYConfigInfo.m
//  YLB
//
//  Created by sayee on 17/3/27.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYConfigInfoModel.h"
#import "MJExtension.h"

@implementation SYConfigInfoModel

+(NSDictionary *)mj_objectClassInArray{
    return @{
             @"sipInfoList" : @"SipInfoModel"
             };
}

@end

@implementation SipInfoModel

MJCodingImplementation
@end

