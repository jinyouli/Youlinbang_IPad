//
//  ViewcontrollersManager.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/7/7.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "ViewcontrollersManager.h"

@implementation ViewcontrollersManager

+ (ViewcontrollersManager*)shareMgr
{
    static ViewcontrollersManager* instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[ViewcontrollersManager alloc] init];
        instance.insetVC = nil;
    });
    
    return instance;
}

+ (void)setViewcontroller:(UIViewController*)vc
{
    [ViewcontrollersManager shareMgr].insetVC = vc;
}

+ (UIViewController*)getInsetViewcontroller
{
    return [ViewcontrollersManager shareMgr].insetVC;

}

@end
