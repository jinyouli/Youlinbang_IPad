//
//  SYRepairOrderCompleteViewController.h
//  YLB
//
//  Created by sayee on 17/4/13.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseViewController.h"
#import "SYPropertyRepairView.h"

typedef enum : NSUInteger {
    RepairOrderCompleteYesType, //工单确认
    RepairOrderCompleteBackType    //工单反单
} RepairOrderCompleteType;   // 工单确认和工单反单

@interface SYRepairOrderCompleteViewController : BaseViewController

- (instancetype)initWithRepairID:(NSString *)repairID RepairOrderCompleteType:(RepairOrderCompleteType)type;
@end
