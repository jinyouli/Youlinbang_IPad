//
//  SYPropertyRepairView.h
//  YLB
//
//  Created by YAYA on 2017/4/2.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseView.h"
#import "MJRefresh.h"
@class SYPropertyRepairModel;

//1表示工单回复，2表示工单评论，3表示处理人提醒转单记录，4表示派单人转单记录 5表示完成订单信息记录，6用户返单 ，7表示用户取消工单
typedef enum : NSUInteger {
    OrderResponse = 1,
    OrderComment,
    OrderNoticeGiveTheOtherRecord,
    OrderGiveGiveTheOtherRecord,
    OrderFinishRecord,
    OrderGetBack,
    OrderCancel
} SaveRepairsRecordType;


typedef enum : NSUInteger {
    propertyNoFixViewType = 1,
    propertyFixingiewType,
    propertyNoComfirmViewType,
    propertyFinishViewType
} PropertyRepairType;

typedef enum : NSUInteger {
    propertyRepairListType = 1, //物业报修 = 1
    propertyComplainListType    //物业投诉 = 2
} RepairListOrderType;   // 工单类型


@protocol SYPropertyRepairViewDelegate <NSObject>

- (void)commentBtnClickWithPropertyRepairType:(PropertyRepairType)propertyRepairType RepairListOrderType:(RepairListOrderType)orderType TableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath PropertyRepairModel:(SYPropertyRepairModel *)model;
@end

@interface SYPropertyRepairView : BaseView

@property (nonatomic, weak) id<SYPropertyRepairViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame WithType:(PropertyRepairType)type WithOderType:(RepairListOrderType)oderType;

- (void)updataTableView;
@end
