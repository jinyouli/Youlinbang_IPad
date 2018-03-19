//
//  SYMyMessageListView.h
//  YLB
//
//  Created by sayee on 17/4/7.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseView.h"
#import "SYMyMessageDetailViewController.h"
//typedef enum : NSUInteger {
//    MyMessageType = 1,
//    NeighborMessageType,
//    TenementMessageType,
//} SYMyMessageNoticeType;
//SYNoticeType;   //类型    1：我的消息  2：社区消息  3：物业动态列表

@interface SYMyMessageListView : BaseView

- (instancetype)initWithFrame:(CGRect)frame WithType:(SYMyMessageNoticeType) type;
@end
