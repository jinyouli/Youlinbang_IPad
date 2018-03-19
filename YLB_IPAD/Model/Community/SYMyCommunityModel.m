//
//  SYMyCommunityModel.m
//  YLB
//
//  Created by sayee on 17/4/1.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYMyCommunityModel.h"
#import "MJExtension.h"

@implementation SYMyCommunityModel

+(NSDictionary *)mj_objectClassInArray{
    return @{
             @"html_list" : @"SYMyCommunityHTMLModel",
             @"neighbor_msg_list" : @"SYNeighborMsgModel",
             @"imag_list" : @"SYImagpathModel"
             };
}
@end


@implementation SYMyCommunityHTMLModel 

@end

@implementation SYNeighborMsgModel

@end

@implementation SYImagpathModel
@end
