//
//  SYPropertyRepairModel.m
//  YLB
//
//  Created by YAYA on 2017/4/2.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYPropertyRepairModel.h"
#import "MJExtension.h"

@implementation SYPropertyRepairModel

+(NSDictionary *)mj_objectClassInArray{
    return @{
             @"repairs_imag_list" : @"SYRepairsImagListModel"
             };
}

@end

@implementation SYRepairsImagListModel
@end



@implementation SYRepairOrderCommentModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"commentID":@"id",@"record_new_name":@"new_name"};
}

+(NSDictionary *)mj_objectClassInArray{
    return @{
             @"record_imag_list" : @"SYRepairsImagListModel"
             };
}

@end
