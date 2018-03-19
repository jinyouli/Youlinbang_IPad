//
//  SYChangePwNewPWViewController.h
//  YLB
//
//  Created by YAYA on 2017/3/19.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseViewController.h"

@interface SYChangePwNewPWViewController : BaseViewController

- (instancetype)initWithPhone:(NSString *)phone;

@property (nonatomic ,assign) BOOL isChangeNewPWWithVerifyCode;
@property (nonatomic ,copy) NSString *changeNewPWWithVerifyCode;
@end
