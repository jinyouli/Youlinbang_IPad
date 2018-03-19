//
//  SYChangePwOldPWViewController.h
//  YLB
//
//  Created by YAYA on 2017/3/19.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseViewController.h"

@interface SYChangePwOldPWViewController : BaseViewController
@property (nonatomic, assign) BOOL isJumpNewPWVC;   //是否跳重设密码页面（因为跟重设手势密码页面公用，重设手势密码页不需要跳SYChangePwNewPWViewController）
@end
