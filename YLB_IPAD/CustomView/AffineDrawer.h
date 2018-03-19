//
//  AffineDrawer.h
//  AFTransitionDemo
//
//  Created by jinyou on 2017/7/6.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AffineDrawer : UIView

/** 抽屉视图是否已打开 */
@property (nonatomic) BOOL isOpen;
@property (nonatomic, strong) UIControl *mask;
@property (nonatomic, strong) UIView *menuView;

/**
 * 实例化抽屉视图
 * @param theView 指定的UIView
 */
- (id)initWithView:(UIView *)theView menuView:(UIView*)menuView menuFrame:(CGRect)rect;

- (void)setContentView:(UIView*)menuView;
/**
 * 打开抽屉
 */
- (void)openDrawer;

/**
 * 关起抽屉
 */
- (void)closeDrawer;

@end
