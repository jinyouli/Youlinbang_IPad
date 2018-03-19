//
//  SYResetGesturePassWordViewController.h
//  YLB
//
//  Created by YAYA on 2017/4/11.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseViewController.h"
#import "PCCircleView.h"

@interface SYResetGesturePassWordViewController : BaseViewController

@property (nonatomic, assign) BOOL isHideNavigationBar;
@property (nonatomic, assign) BOOL isResetGesturePW;    //是否是个人设置页修改手势密码。是的话，修改完成后，就返回个人设置页

- (instancetype)initWithCircleViewType:(CircleViewType)type ShowPWBtn:(BOOL)isShowPWLogin;
@end
