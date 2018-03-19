//
//  SYNoticeByPagerModel.m
//  YLB
//
//  Created by sayee on 17/4/7.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYNoticeByPagerModel.h"

@implementation SYNoticeByPagerModel

+(NSDictionary *)mj_objectClassInArray{
    return @{
             @"multimedia" : @"SYNoticeInfoModel"
             };
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"msgID":@"id"};
}
@end

@implementation SYNoticeInfoModel

@end
