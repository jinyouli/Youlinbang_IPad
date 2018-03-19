//
//  SYInComingCallViewController.h
//  YLB
//
//  Created by sayee on 17/4/12.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseViewController.h"

@interface SYInComingCallViewController : BaseViewController

@property (nonatomic, copy) NSString *sipNumber;

- (instancetype)initWithDisplayName:(NSString *)displayName WithCall:(SYLinphoneCall *)call;
@end
