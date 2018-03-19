//
//  SYMyMessageDetailViewController.h
//  YLB
//
//  Created by sayee on 17/4/7.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseViewController.h"

//类型    1：我的消息  2：社区消息  3：物业动态列表
typedef enum : NSUInteger {
    MyMessageType = 1,
    NeighborMessageType,
    TenementMessageType,
} SYMyMessageNoticeType;


@class SYNoticeByPagerModel;

@interface SYMyMessageDetailViewController : BaseViewController

- (instancetype)initWithModel:(SYNoticeByPagerModel *)model WithType:(SYMyMessageNoticeType)type;
@end
