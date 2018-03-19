//
//  SYGuardMonitorViewController.h
//  YLB
//
//  Created by sayee on 17/4/1.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseViewController.h"

@interface SYGuardMonitorViewController : BaseViewController

@property (nonatomic,copy) NSString *monitorStatus;

- (instancetype)initWithCall:(SYLinphoneCall *)call GuardInfo:(SYLockListModel *)model InComingCall:(BOOL)isInComingCall;
@end
