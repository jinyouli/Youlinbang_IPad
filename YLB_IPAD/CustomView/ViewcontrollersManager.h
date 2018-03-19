//
//  ViewcontrollersManager.h
//  YLB_IPAD
//
//  Created by jinyou on 2017/7/7.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewcontrollersManager : NSObject

+ (ViewcontrollersManager*)shareMgr;

+ (void)setViewcontroller:(UIViewController*)vc;

+ (UIViewController*)getInsetViewcontroller;

@property (nonatomic,strong) UIViewController *insetVC;

@end
