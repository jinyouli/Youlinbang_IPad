//
//  SYCustomAlertView.h
//  YLB
//
//  Created by sayee on 17/4/13.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseView.h"

typedef void(^CompleteBlock)();

@interface SYCustomAlertView : BaseView

@property (nonatomic,copy) CompleteBlock completeBlock;
//@property (copy) void (^onButtonTouchUpInside)(CustomAlertView *alertView, int buttonIndex);

- (void)showCustomAlertViewWithTitle:(NSString *)title CompleteBlock:(CompleteBlock)block;
@end
