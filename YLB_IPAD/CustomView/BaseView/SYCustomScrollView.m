//
//  SYCustomScrollView.m
//  YLB
//
//  Created by YAYA on 2017/4/2.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYCustomScrollView.h"

@implementation SYCustomScrollView

//自定义ScrollView，解决向右滑动手势冲突问题
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    if (![panGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    CGPoint velocity = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
    if (self.contentOffset.x <= 0 && velocity.x > 0) {
        return NO;
    } else {
        return YES;
    }
}

@end
