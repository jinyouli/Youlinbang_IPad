//
//  SYChangePwOldPWViewController.m
//  YLB
//
//  Created by YAYA on 2017/3/19.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYChangePwOldPWViewController.h"
#import "SYChangePwNewPWViewController.h"
#import "SYResetGesturePassWordViewController.h"

@interface SYChangePwOldPWViewController ()
@property (nonatomic ,strong) UITextField *pwTextField;
@property (nonatomic ,strong) UITextField *accountTextField;

@end

@implementation SYChangePwOldPWViewController

- (instancetype)initWithJumpNewPWVC:(BOOL)isJumpNewPWVC{
    if (self = [super init]) {
        self.isJumpNewPWVC = isJumpNewPWVC;
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

- (NSString *)backBtnTitle{
    return @"登录密码验证";
}


#pragma mark - private
- (void)initUI{
    self.view.backgroundColor = UIColorFromRGB(0xebebeb);
    
    UIView *pwAndAccountView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.width_sd, 82)];
    [self.view addSubview:pwAndAccountView];
    
    //====账号区域===
    UIView *accountView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width_sd, 40)];
    [pwAndAccountView addSubview:accountView];
    
    //UITextField leftview
    UIImage *img = [UIImage imageNamed:@"sy_login_icon_phone"];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, img.size.width + 10, img.size.height)];
    UIImageView *leftImgView = [[UIImageView alloc] initWithImage:img];
    leftImgView.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    [leftView addSubview:leftImgView];
    
    self.accountTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, accountView.width_sd - 20, accountView.height_sd)];
    self.accountTextField.leftView = leftView;
    self.accountTextField.enabled = NO;
    self.accountTextField.text = [SYLoginInfoModel shareUserInfo].userInfoModel.username;
    self.accountTextField.leftViewMode = UITextFieldViewModeAlways;
    self.accountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [accountView addSubview:self.accountTextField];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, accountView.bottom_sd, accountView.width_sd - 20, 1)];
    line.backgroundColor = UIColorFromRGB(0x999999);
    line.center = CGPointMake(accountView.width_sd * 0.5, line.centerY);
    [pwAndAccountView addSubview:line];
    
    
    //===密码区域===
    UIView *passwordView = [[UIView alloc] initWithFrame:CGRectMake(0, line.bottom_sd, self.view.width_sd, 40)];
    [pwAndAccountView addSubview:passwordView];
    
    //UITextField leftview
    img = [UIImage imageNamed:@"sy_login_icon_pwd"];
    leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, img.size.width + 10, img.size.height)];
    leftImgView = [[UIImageView alloc] initWithImage:img];
    leftImgView.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    [leftView addSubview:leftImgView];
    
    self.pwTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, self.accountTextField.width_sd, self.accountTextField.height_sd)];
    self.pwTextField.leftView = leftView;
    self.pwTextField.secureTextEntry = YES;
    self.pwTextField.leftViewMode = UITextFieldViewModeAlways;
    self.pwTextField.placeholder = @"请输入原始密码";
    self.pwTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [passwordView addSubview:self.pwTextField];
    
    
    line = [[UIView alloc] initWithFrame:CGRectMake(0, passwordView.bottom_sd, accountView.width_sd - 20, 1)];
    line.backgroundColor = UIColorFromRGB(0x999999);
    line.center = CGPointMake(accountView.width_sd * 0.5, line.centerY);
    [pwAndAccountView addSubview:line];
    
    
    //===登录===
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setTitle:@"下一步" forState:UIControlStateNormal];
    loginBtn.backgroundColor = UIColorFromRGB(0xd23023);
    loginBtn.frame = CGRectMake(10, pwAndAccountView.bottom_sd + 20, self.view.width_sd - 20, 40);
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
}


#pragma mark - event
- (void)btnClick:(UIButton *)btn{
    
    [self.accountTextField resignFirstResponder];
    [self.pwTextField resignFirstResponder];
    

    if (self.accountTextField.text.length == 0 || self.pwTextField.text == 0) {
        [self showMessageWithContent:@"账号或者密码不能为空" duration:1];
        return;
    }
    
    if ([Common isIncludeSpecialCharact: self.pwTextField.text]) {
        [self showMessageWithContent:@"不能输入非法字符" duration:1];
        return;
    }
    
    if (![[SYAppConfig shareInstance].password isEqualToString:self.pwTextField.text]) {
        [self showErrorWithContent:@"原始密码不正确" duration:1];
        return;
    }

    if (self.isJumpNewPWVC) {
        //修改密码页
        SYChangePwNewPWViewController *vc = [[SYChangePwNewPWViewController alloc] initWithPhone:self.accountTextField.text];
        vc.isChangeNewPWWithVerifyCode = NO;
        [FrameManager pushViewController:vc animated:YES];
    }else{
        SYResetGesturePassWordViewController *vc = [[SYResetGesturePassWordViewController alloc] initWithCircleViewType:CircleViewTypeSetting ShowPWBtn:NO];
        vc.isResetGesturePW = YES;
        [FrameManager pushViewController:vc animated:YES];
    }
}




#pragma mark - touch delegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.accountTextField resignFirstResponder];
    [self.pwTextField resignFirstResponder];
}


@end
