//
//  SYNewRepairViewController.h
//  YLB
//
//  Created by sayee on 17/4/6.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseViewController.h"
#import "SYPropertyRepairView.h"    //只是用RepairListOrderType

@interface SYNewRepairViewController : BaseViewController

- (instancetype)initWithRepairListOrderType:(RepairListOrderType)type WithTitle:(NSString *)title;
@end
