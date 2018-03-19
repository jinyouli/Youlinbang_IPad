//
//  BaseViewController.h
//  YLB
//
//  Created by YAYA on 2017/3/12.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (nonatomic,assign) BOOL hiddenNavBar;

// 是否显示返回按钮
- (BOOL)showBackButton;

- (void)showWithContent:(NSString*)msg;
- (void)showErrorWithContent:(NSString *)string duration:(NSTimeInterval)duration;
- (void)showSuccessWithContent:(NSString *)string duration:(NSTimeInterval)duration;
- (void)showMessageWithContent:(NSString *)msg duration:(NSTimeInterval)duration;
- (void)dismissHudWithDelay:(NSTimeInterval)delay;
- (void)dismissHud:(BOOL)isAnimation;

// 默认返回为YES,表示支持右滑返回
- (BOOL)panBackGestureEnable;

- (NSString *)backBtnTitle;

- (void) backButtonClick;
@end
