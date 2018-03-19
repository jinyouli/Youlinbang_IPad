//
//  SYNeiIPListModel.m
//  YLB
//
//  Created by sayee on 17/3/27.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYNeiIPListModel.h"
#import "MJExtension.h"

@implementation SYNeiIPListModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"fid":@"id"};
}
@end
