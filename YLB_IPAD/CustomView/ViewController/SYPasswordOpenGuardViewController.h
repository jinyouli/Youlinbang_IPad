//
//  SYPasswordOpenGuardViewController.h
//  YLB
//
//  Created by YAYA on 2017/4/9.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseViewController.h"
@class SYLockListModel;

@interface SYPasswordOpenGuardViewController : BaseViewController

@property (nonatomic, retain) SYLockListModel *model;

- (instancetype)initWithGuardInfo:(SYLockListModel *)model;
@end
