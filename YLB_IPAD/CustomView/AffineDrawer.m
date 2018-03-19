//
//  AffineDrawer.m
//  AFTransitionDemo
//
//  Created by jinyou on 2017/7/6.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "AffineDrawer.h"
#import "MainViewController.h"

#define ACNavBarDrawer_Duration     0.3f

@interface AffineDrawer ()
{
    /** 背景遮罩 */
    UIView            *_mainView;
}

@property (nonatomic,assign) CGRect rect;
@end

@implementation AffineDrawer

- (id)initWithView:(UIView *)theView menuView:(UIView*)menuView menuFrame:(CGRect)rect
{
    self = [super init];
    if (self)
    {
        // Initialization code
        
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        ;
        
        _isOpen = NO;
        
        _mask = [[UIControl alloc] initWithFrame:theView.bounds];
        
        [_mask setBackgroundColor:[UIColor blackColor]];
        [_mask addTarget:self action:@selector(closeDrawer) forControlEvents:UIControlEventTouchUpInside];
        [_mask setAlpha:0.0f];
        
        
        // 添加到窗口
       [theView addSubview:_mask];
        
        _mainView = theView;
        _menuView = menuView;
        self.rect = rect;
        //视图布局
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    _menuView.frame = self.rect;
    _menuView.hidden = YES;
    [_mainView addSubview:_menuView];
}

- (void)setContentView:(UIView*)menuView
{
    [_menuView removeFromSuperview];
    _menuView = nil;
    
    _menuView = menuView;
    [self initUI];
}

/**
 * 打开抽屉
 */
- (void)openDrawer
{
    _isOpen = YES;
    [_mask setAlpha:0.3f];
    
    
    [UIView animateWithDuration:ACNavBarDrawer_Duration animations:^{
        
        [self setCenter:CGPointMake( ([UIScreen mainScreen].bounds.size.width / 2),([UIScreen mainScreen].bounds.size.height / 2.f) )];
        
        _menuView.transform = CGAffineTransformMakeTranslation( -CGRectGetMaxX(_menuView.bounds), 0);
    }completion:^(BOOL finished) {
        
        _menuView.hidden = NO;
    }];
}

/**
 * 关起抽屉
 */
- (void)closeDrawer
{
    _isOpen = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeAdvertiseDrawer" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeInforDetail"
                                                        object:nil];
    
    [UIView animateWithDuration:ACNavBarDrawer_Duration animations:^{
        
        [self setCenter:CGPointMake( ([UIScreen mainScreen].bounds.size.width / 2), -([UIScreen mainScreen].bounds.size.height / 2.f) )];
        
        _menuView.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        [_mask setAlpha:0.0f];
        _menuView.hidden = YES;
        [_menuView removeFromSuperview];
        
        
    }];
}

@end
