//
//  SYRegisterViewController.m
//  YLB
//
//  Created by YAYA on 2017/4/12.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYRegisterViewController.h"
#import "SYVerifyCodeViewController.h"

@interface SYRegisterViewController ()
@property (nonatomic ,strong) UITextField *pwTextField;
@property (nonatomic ,strong) UITextField *accountTextField;
@end

@implementation SYRegisterViewController

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
    return @"注册";
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
    self.accountTextField.text = [SYLoginInfoModel shareUserInfo].userInfoModel.username;
    self.accountTextField.leftViewMode = UITextFieldViewModeAlways;
    self.accountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.accountTextField.placeholder = @"请输入手机号";
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
    self.pwTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.pwTextField.placeholder = @"请输入密码，不少于6位";
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
    
    if (self.accountTextField.text.length == 0 || self.pwTextField.text.length == 0) {
        [self showMessageWithContent:@"账号或者密码不能为空" duration:1];
        return;
    }
    
    if (self.pwTextField.text.length < 6) {
        [self showMessageWithContent:@"密码不少于6位" duration:1];
        return;
    }
    
    SYVerifyCodeViewController *vc = [[SYVerifyCodeViewController alloc] initWithPhone:self.accountTextField.text WithPassword:self.pwTextField.text];
    vc.isRegister = YES;
    [FrameManager pushViewController:vc animated:YES];
}




#pragma mark - touch delegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.accountTextField resignFirstResponder];
    [self.pwTextField resignFirstResponder];
}
@end
