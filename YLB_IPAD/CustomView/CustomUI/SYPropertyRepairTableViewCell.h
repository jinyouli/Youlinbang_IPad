//
//  SYPropertyRepairTableViewCell.h
//  YLB
//
//  Created by YAYA on 2017/4/2.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYPropertyRepairModel.h"
#import "SYPropertyRepairView.h"    //导入是为了使用PropertyRepairType  RepairListOrderType

#define kNameWidth (kScreenWidth - 20 - 18 - 40 - 18 - 10)

typedef enum : NSUInteger {
    PropertyCancelType = 0, //取消
    PropertyUrgeType,   //催单
    PropertyCommentType,   //评论
    PropertExtensionType,   //展开
    PropertyBackType,   //返单
    PropertConfirmType,   //确认
    PropertHistoryCommentType //历史评论
} PropertyBtnClickType;

@protocol SYPropertyRepairTableViewCellDelegate <NSObject>

- (void)propertyBtnClickType:(PropertyBtnClickType)type IndexPath:(NSIndexPath *)indexPath Button:(UIButton *)btn;
@end


@interface SYPropertyRepairTableViewCell : UITableViewCell

//刷新数据
- (void)setDataWithPropertyRepairType:(PropertyRepairType)type OrderType:(RepairListOrderType)oderType PropertyRepairModel:(SYPropertyRepairModel *)repairModel;

@property (nonatomic, weak) id<SYPropertyRepairTableViewCellDelegate> delegate;
@property (nonatomic, retain) NSIndexPath *indexPath;

@end
