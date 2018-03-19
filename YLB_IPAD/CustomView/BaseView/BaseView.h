//
//  BaseView.h
//  YLB
//
//  Created by YAYA on 2017/3/12.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseView : UIView

- (void)showWithContent:(NSString*)msg;
- (void)showErrorWithContent:(NSString *)string duration:(NSTimeInterval)duration;
- (void)showSuccessWithContent:(NSString *)string duration:(NSTimeInterval)duration;
- (void)showMessageWithContent:(NSString *)msg duration:(NSTimeInterval)duration;
- (void)dismissHudWithDelay:(NSTimeInterval)delay;
- (void)dismissHud:(BOOL)isAnimation;

@end
