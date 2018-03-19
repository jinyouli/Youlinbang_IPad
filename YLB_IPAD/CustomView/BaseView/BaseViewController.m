//
//  BaseViewController.m
//  YLB
//
//  Created by YAYA on 2017/3/12.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseViewController.h"
#import "MBProgressHUD.h"

@interface BaseViewController ()<MBProgressHUDDelegate>
@property (nonatomic,strong)MBProgressHUD *progressHud;
@end

@implementation BaseViewController

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:self.hiddenNavBar animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.view.backgroundColor = UIColorFromRGB(0xebebeb);
    
    //返回按钮
    if ([self showBackButton]) {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.titleLabel.font = [UIFont systemFontOfSize:14];
        CGSize size = [self.backBtnTitle sizeWithFont:backButton.titleLabel.font andSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        backButton.frame = CGRectMake(0, 7, 44 + size.width, 30);
        [backButton setTitle:self.backBtnTitle forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [backButton setImage:[UIImage imageNamed:@"sy_navigation_back"] forState:UIControlStateNormal];

        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44 + size.width, 44)];
        backView.backgroundColor = [UIColor clearColor];
        backView.clipsToBounds = YES;
        [backView addSubview:backButton];
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
        UIBarButtonItem *flexSpacerl = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
        flexSpacerl.width = -15;
        self.navigationItem.leftBarButtonItems = @[flexSpacerl, backItem];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - public
- (BOOL) showBackButton
{
    return YES;
}

- (BOOL)panBackGestureEnable {
    return YES;
}

- (NSString *)backBtnTitle{
    return @"";
}

#pragma mark - event
- (void) backButtonClick
{
    [FrameManager popViewControllerAnimated:YES];
}


#pragma mark - MBProgressHUD
- (void)initHud{
    if (self.progressHud) {
        [self.progressHud removeFromSuperview];
        self.progressHud = nil;
    }
    self.progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHud.delegate = self;
    [self.view addSubview:self.progressHud];
}

- (void)showMessageWithContent:(NSString *)msg duration:(NSTimeInterval)duration{
    
    if ([NSThread isMainThread]) {
        [self initHud];
        self.progressHud.mode = MBProgressHUDModeText;
        self.progressHud.label.text = msg;
        [self.progressHud showAnimated:YES];
        [self.progressHud hideAnimated:YES afterDelay:duration];
    }else{
        dispatch_sync(dispatch_get_main_queue(), ^(){
            [self initHud];
            self.progressHud.mode = MBProgressHUDModeText;
            self.progressHud.label.text = msg;
            [self.progressHud showAnimated:YES];
            [self.progressHud hideAnimated:YES afterDelay:duration];
        });
    }
}

-(void)showWithContent:(NSString*)msg{
    [self initHud];
    if (msg) {
        self.progressHud.label.text = msg;
    }
    [self.progressHud showAnimated:YES];
}

-(void)showSuccessWithContent:(NSString *)string duration:(NSTimeInterval)duration{
    if ([NSThread isMainThread]) {
        UIImageView *successImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_progresshub_success"]];
        [self showWithCustomView:successImg];
        self.progressHud.label.text = string ;
        [self.progressHud hideAnimated:YES afterDelay:duration];
    }else{
        dispatch_sync(dispatch_get_main_queue(), ^(){
            UIImageView *successImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_progresshub_success"]];
            [self showWithCustomView:successImg];
            self.progressHud.label.text = string ;
            [self.progressHud hideAnimated:YES afterDelay:duration];
        });
    }
}

-(void)showErrorWithContent:(NSString *)string duration:(NSTimeInterval)duration{
    if ([NSThread isMainThread]) {
        if (string.length == 0) {
            [self dismissHud:YES];
            return;
        }
        
        UIImageView *successImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_progresshub_error"]];
        [self showWithCustomView:successImg];
        self.progressHud.label.text = string ;
        [self.progressHud hideAnimated:YES afterDelay:duration];
    }else{
        dispatch_sync(dispatch_get_main_queue(), ^(){
            if (string.length == 0) {
                [self dismissHud:YES];
                return;
            }
            
            UIImageView *successImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_progresshub_error"]];
            [self showWithCustomView:successImg];
            self.progressHud.label.text = string ;
            [self.progressHud hideAnimated:YES afterDelay:duration];
        });
    }
}

- (void)showWithCustomView:(UIView *)customView{
    
    if ([NSThread isMainThread]) {
        [self initHud];
        self.progressHud.mode = MBProgressHUDModeCustomView;
        self.progressHud.customView = customView;
        [self.progressHud showAnimated:YES];
        [self.progressHud hideAnimated:YES afterDelay:1.5f];
        
    }else{
        dispatch_sync(dispatch_get_main_queue(), ^(){
            [self initHud];
            self.progressHud.mode = MBProgressHUDModeCustomView;
            [self.progressHud showAnimated:YES];
        });
    }
}

- (void)dismissHudWithDelay:(NSTimeInterval)delay {
    [self.progressHud hideAnimated:YES afterDelay:delay];
}

- (void)dismissHud:(BOOL)isAnimation{
    if (isAnimation) {
        [self.progressHud hideAnimated:YES afterDelay:1];
    }else{
        [self.progressHud hideAnimated:NO];
    }
}


#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
}


#pragma mark - gesture delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    BOOL ok = YES; // 默认为支持右滑反回
        if ([self respondsToSelector:@selector(panBackGestureEnable)]) {
            ok = [self panBackGestureEnable];
        }
    return ok;
}
@end
