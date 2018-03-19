//
//  FrameManager.m
//  YLB
//
//  Created by YAYA on 2017/3/12.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "FrameManager.h"
#import "SYDiscoverViewController.h"
#import "SYHomeViewController.h"
#import "SYPersonalSpaceViewController.h"
#import "BaseNavigationController.h"

static FrameManager *fMgr = nil;

@interface FrameManager ()

@property (strong, nonatomic) UITabBarController *tabBarVC;
@end;

@implementation FrameManager

#pragma mark - public
+ (FrameManager *)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fMgr = [[FrameManager alloc] init];
    });
    return fMgr;
}

+ (UIViewController *)initRootViewController{

    BaseNavigationController *rootVC = [[BaseNavigationController alloc] initWithRootViewController:[FrameManager configHomeTabBarController]];
    rootVC.navigationBar.barTintColor = UIColorFromRGB(0xd23023);
    return rootVC;
}

+ (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    UINavigationController *rootVC = [FrameManager rootViewController];
    [rootVC pushViewController:viewController animated:animated];
}

+ (void)popViewControllerAnimated:(BOOL)animated{
    UINavigationController *rootVC = [FrameManager rootViewController];
    [rootVC popViewControllerAnimated:animated];
}

+ (void)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    UINavigationController *rootVC = [FrameManager rootViewController];
    [rootVC popToViewController:viewController animated:animated];
}

+ (void)popToRootViewControllerAnimated:(BOOL)animated{
    UINavigationController *rootVC = [FrameManager rootViewController];
    [rootVC popToRootViewControllerAnimated:animated];
}

+ (void)changeTabbarIndex:(NSUInteger)index{
    [FrameManager sharedInstance].tabBarVC.selectedIndex = index;
}

+ (UIViewController *)tabBarViewController{
    return [FrameManager sharedInstance].tabBarVC;
}


#pragma mark - private
+ (UIViewController *)configHomeTabBarController{
    [FrameManager sharedInstance].tabBarVC = [[UITabBarController alloc] init];
    
    SYDiscoverViewController *discoverViewController = [[SYDiscoverViewController alloc] init];
    discoverViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"发现" image:[UIImage imageNamed:@"sy_home_find_normal"] selectedImage:[UIImage imageNamed:@"sy_home_find_selcected"]];
    
    SYHomeViewController *homeViewController = [[SYHomeViewController alloc] init];
    homeViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:[UIImage imageNamed:@"sy_home_community_normal"] selectedImage:[UIImage imageNamed:@"sy_home_community_selcected"]];
    
    SYPersonalSpaceViewController *personalSpaceViewController = [[SYPersonalSpaceViewController alloc] init];
    personalSpaceViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的" image:[UIImage imageNamed:@"sy_home_me_normal"] selectedImage:[UIImage imageNamed:@"sy_home_me_selcected"]];
    
    [FrameManager sharedInstance].tabBarVC.viewControllers = [NSArray arrayWithObjects:discoverViewController, homeViewController, personalSpaceViewController, nil];
    [FrameManager sharedInstance].tabBarVC.tabBar.translucent = NO;
    
    return [FrameManager sharedInstance].tabBarVC;
}

+ (UINavigationController *)rootViewController{
    BaseNavigationController *rootVC = (BaseNavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    return rootVC;
}

@end
