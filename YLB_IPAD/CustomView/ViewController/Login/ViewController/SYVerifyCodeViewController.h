//
//  SYVerifyCodeViewController.h
//  YLB
//
//  Created by YAYA on 2017/4/12.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseViewController.h"

@interface SYVerifyCodeViewController : BaseViewController

@property (nonatomic ,assign) BOOL isRegister;  //是否是点注册按钮进来，是的话直接注册

- (instancetype)initWithPhone:(NSString *)phone WithPassword:(NSString *)password;
@end
