//
//  SYGestureUnlockViewController.h
//  YLB
//
//  Created by YAYA on 2017/3/29.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseViewController.h"
#import "PCCircleView.h"

@interface SYGestureUnlockViewController : BaseViewController

@property (nonatomic, assign) BOOL isHideNavigationBar;   

- (instancetype)initWithCircleViewType:(CircleViewType)type;
@end
