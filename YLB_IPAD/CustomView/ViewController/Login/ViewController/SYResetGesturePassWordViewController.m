//
//  SYResetGesturePassWordViewController.m
//  YLB
//
//  Created by YAYA on 2017/4/11.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYResetGesturePassWordViewController.h"
#import "SYChangePwOldPWViewController.h"
#import "SYSettingViewController.h"

#import "PCCircleViewConst.h"
#import "PCLockLabel.h"
#import "PCCircleInfoView.h"

@interface SYResetGesturePassWordViewController ()<CircleViewDelegate>
@property (nonatomic, assign) CircleViewType circleViewType;
@property (nonatomic, retain) PCLockLabel *msgLabel;
@property (nonatomic, assign) BOOL isShowPWLogin;   //是否显示密码登录按钮
@end

@implementation SYResetGesturePassWordViewController

- (instancetype)initWithCircleViewType:(CircleViewType)type ShowPWBtn:(BOOL)isShowPWLogin{
    if (self = [super init]) {
        self.circleViewType = type;
        self.isShowPWLogin = isShowPWLogin;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)hiddenNavBar{
    return self.isHideNavigationBar;
}

- (BOOL)panBackGestureEnable{
    return NO;
}

- (NSString *)backBtnTitle{
    return @"修改手势密码";
}


#pragma mark - private
- (void)initUI{
    
    //解锁界面
    PCCircleView *lockView = [[PCCircleView alloc] initWithType:self.circleViewType clip:YES arrow:YES];
    lockView.center = CGPointMake(self.view.width_sd * 0.5, self.view.height_sd * 0.5);
    lockView.delegate = self;
    lockView.isOpenTracks = [SYLoginInfoModel shareUserInfo].isShowGesturePath;
    [self.view addSubview:lockView];
    
    //提示lab
    self.msgLabel = [[PCLockLabel alloc] initWithFrame:CGRectMake(0, lockView.top_sd - 40, kScreenWidth, 20)];
    self.msgLabel.font = [UIFont systemFontOfSize:16];
    if (self.circleViewType == CircleViewTypeSetting) {
        [self.msgLabel showNormalMsg:gestureTextBeforeSet];
        [PCCircleViewConst saveGesture:nil Key:gestureOneSaveKey];
//        [PCCircleViewConst saveGesture:nil Key:gestureFinalSaveKey];
    }else{
        [self.msgLabel showNormalMsg:@"请输入原手势密码"];
    }
    [self.view addSubview:self.msgLabel];
    

    //====登录密码验证===
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(30, self.view.height_sd - 100, 100, 30);
    [btn setTitle:@"登录密码验证" forState:UIControlStateNormal];
    [btn setTitleColor:UIColorFromRGB(0xd23023) forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.center = CGPointMake(self.view.width_sd * 0.5, btn.centerY);
    [self.view addSubview:btn];
    btn.hidden = !self.isShowPWLogin;
}


#pragma mark - event
- (void)btnClick:(UIButton *)btn{
    
    SYChangePwOldPWViewController *vc = [[SYChangePwOldPWViewController alloc] init];
    vc.isJumpNewPWVC = NO;
    [FrameManager pushViewController:vc animated:YES];
}


#pragma mark - CircleViewDelegate
//============CircleViewType == CircleViewTypeSetting时调用==============
// 连线个数少于4个时，通知代理
- (void)circleView:(PCCircleView *)view type:(CircleViewType)type connectCirclesLessThanNeedWithGesture:(NSString *)gesture{
    NSLog(@"连线个数少于4个时，通知代理=====%@",gesture);
    
    [self.msgLabel showWarnMsgAndShake:gestureTextConnectLess];
}

//连线个数多于或等于4个，获取到第一个手势密码时通知代理
- (void)circleView:(PCCircleView *)view type:(CircleViewType)type didCompleteSetFirstGesture:(NSString *)gesture{
    NSLog(@"连线个数多于或等于4个，获取到第一个手势密码时通知代理=====%@",gesture);
    
    [self.msgLabel showNormalMsg:gestureTextDrawAgain];
}

// 获取到第二个手势密码时通知代理
- (void)circleView:(PCCircleView *)view type:(CircleViewType)type didCompleteSetSecondGesture:(NSString *)gesture result:(BOOL)equal{
    NSLog(@"获取到第二个手势密码时通知代理==%@  ==%i",gesture, equal);
    
    if (equal) {
        [Common showAlert:self.view alertText:@"手势密码设置成功" afterDelay:1.0];
        
        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:1.0f];
    }
    else{
        [self.msgLabel showWarnMsgAndShake:gestureTextDrawAgainError];
    }
}

- (void)delayMethod
{
    for (UIViewController *temp in [FrameManager rootViewController].viewControllers) {
        if ([temp isKindOfClass:[SYSettingViewController class]]) {
            
            [FrameManager popToViewController:temp animated:YES];
        }
    }
}

//==============================================================================

//============CircleViewType == CircleViewTypeLogin  or CircleViewTypeVerify 时调用==============    ,
// 登陆或者验证手势密码输入完成时的代理方法
- (void)circleView:(PCCircleView *)view type:(CircleViewType)type didCompleteLoginGesture:(NSString *)gesture result:(BOOL)equal{
    NSLog(@" 登陆或者验证手势密码输入完成时的代理方法=====%@  ==%i",gesture, equal);
    
    int count = [[[NSUserDefaults standardUserDefaults] objectForKey:@"passwordFailCount"] intValue];
    
    
    
    if (equal) {
        if (self.isResetGesturePW) {
            SYResetGesturePassWordViewController *vc = [[SYResetGesturePassWordViewController alloc] initWithCircleViewType:CircleViewTypeSetting ShowPWBtn:NO];
            vc.isResetGesturePW = YES;
            [FrameManager pushViewController:vc animated:YES];
        }
        else{
            [FrameManager popToRootViewControllerAnimated:YES];
        }
    }
    else{
        count--;
        //[self.msgLabel showWarnMsgAndShake:gestureTextGestureVerifyError];
        [self.msgLabel showWarnMsgAndShake:[NSString stringWithFormat:@"手势密码错误，还可以输入%d次",count]];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",count] forKey:@"passwordFailCount"];
        
        if (count == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"手势密码错误，请重新登入程序" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

#pragma mark -- alertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    exit(0);
}

@end
