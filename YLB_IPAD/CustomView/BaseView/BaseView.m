//
//  BaseView.m
//  YLB
//
//  Created by YAYA on 2017/3/12.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseView.h"
#import "MBProgressHUD.h"


@interface BaseView ()<MBProgressHUDDelegate>

@property (nonatomic,strong)MBProgressHUD *progressHud;
@end

@implementation BaseView

#pragma mark - MBProgressHUD
- (void)initHud{
    if (self.progressHud) {
        [self.progressHud removeFromSuperview];
        self.progressHud = nil;
    }
    self.progressHud = [[MBProgressHUD alloc] initWithView:self];
    self.progressHud.delegate = self;
    [self addSubview:self.progressHud];
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

@end
