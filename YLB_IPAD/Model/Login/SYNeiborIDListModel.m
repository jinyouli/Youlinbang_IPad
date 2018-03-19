//
//  SYNeiborIDListModel.m
//  YLB
//
//  Created by sayee on 17/3/31.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYNeiborIDListModel.h"
#import "MJExtension.h"

@implementation SYNeiborIDListModel

+(NSDictionary *)mj_objectClassInArray{
    return @{
             @"lock_list" : @"SYLockListModel"
             };
}

@end
