//
//  BaseNavigationController.m
//  YLB
//
//  Created by YAYA on 2017/3/19.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseNavigationController.h"
#import "BaseViewController.h"

@interface BaseNavigationController () <UIGestureRecognizerDelegate>
@property (nonatomic, assign) BOOL enableRightGesture;
@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.enableRightGesture = YES;
    self.interactivePopGestureRecognizer.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//支持右滑返回和leftBarButtonItem
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.topViewController isKindOfClass:[BaseViewController class]]) {
        if ([self.topViewController respondsToSelector:@selector(panBackGestureEnable)]) {
            BaseViewController *vc = (BaseViewController *)self.topViewController;
            self.enableRightGesture = [vc panBackGestureEnable];
        }
    }
    return self.enableRightGesture;
}

@end
