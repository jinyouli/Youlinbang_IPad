//
//  FrameManager.h
//  YLB
//
//  Created by YAYA on 2017/3/12.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FrameManager : NSObject


+ (UIViewController *)initRootViewController;
+ (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
+ (void)popViewControllerAnimated:(BOOL)animated;
+ (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
+ (void)popToRootViewControllerAnimated:(BOOL)animated;
+ (void)changeTabbarIndex:(NSUInteger)index;
+ (UIViewController *)tabBarViewController;
+ (UINavigationController *)rootViewController;
@end
