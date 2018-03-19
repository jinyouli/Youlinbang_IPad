//
//  SYSubAccountInfoViewController.h
//  YLB
//
//  Created by sayee on 17/3/29.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseViewController.h"
@class SYSubAccountModel;
@class SipInfoModel;

@interface SYSubAccountInfoViewController : BaseViewController

- (instancetype)initWithSipInfoModel:(SYSubAccountModel *)model SipInfoModel:(SipInfoModel *)sipInfoModel;
- (instancetype)initWithNickName:(NSString *)nickName PhoneNumber:(NSString *)phoneNumber SipInfoModel:(SipInfoModel *)sipInfoModel;
@end
