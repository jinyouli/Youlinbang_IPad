//
//  SYChangePwNewPWViewController.m
//  YLB
//
//  Created by YAYA on 2017/3/19.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYChangePwNewPWViewController.h"
#import "SYLoginViewController.h"
#import "SYLoginHttpDAO.h"

@interface SYChangePwNewPWViewController ()
@property (nonatomic ,strong) UITextField *confirmPwTextField;
@property (nonatomic ,strong) UITextField *pwTextField;
@property (nonatomic ,strong) UITextField *accountTextField;

@property (nonatomic ,copy) NSString *phone;
@end

@implementation SYChangePwNewPWViewController


- (instancetype)initWithPhone:(NSString *)phone{
    
    if (self = [super init]) {
        self.phone = phone;
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

#pragma mark - ovewrite
- (NSString *)backBtnTitle{
    return @"重设密码";
}


#pragma mark - private
- (void)initUI{
    
    self.view.backgroundColor = UIColorFromRGB(0xebebeb);
    
    UIView *pwAndAccountView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.width_sd, 123)];
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
    self.accountTextField.text = self.phone;
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
    self.pwTextField.placeholder = @"请输入新密码";
    self.pwTextField.leftViewMode = UITextFieldViewModeAlways;
    self.pwTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [passwordView addSubview:self.pwTextField];
    
    
    line = [[UIView alloc] initWithFrame:CGRectMake(0, passwordView.bottom_sd, accountView.width_sd - 20, 1)];
    line.backgroundColor = UIColorFromRGB(0x999999);
    line.center = CGPointMake(accountView.width_sd * 0.5, line.centerY);
    [pwAndAccountView addSubview:line];
    
    
    //确认密码
    UIView *confirmPasswordView = [[UIView alloc] initWithFrame:CGRectMake(0, line.bottom_sd, self.view.width_sd, 40)];
    [pwAndAccountView addSubview:confirmPasswordView];
    
    //UITextField leftview
    img = [UIImage imageNamed:@"sy_login_icon_pwd"];
    leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, img.size.width + 10, img.size.height)];
    leftImgView = [[UIImageView alloc] initWithImage:img];
    leftImgView.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    [leftView addSubview:leftImgView];
    
    self.confirmPwTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, self.accountTextField.width_sd, self.accountTextField.height_sd)];
    self.confirmPwTextField.leftView = leftView;
    self.confirmPwTextField.secureTextEntry = YES;
    self.confirmPwTextField.placeholder = @"请再次输入新密码";
    self.confirmPwTextField.leftViewMode = UITextFieldViewModeAlways;
    self.confirmPwTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [confirmPasswordView addSubview:self.confirmPwTextField];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(0, confirmPasswordView.bottom_sd, accountView.width_sd - 20, 1)];
    line.backgroundColor = UIColorFromRGB(0x999999);
    line.center = CGPointMake(accountView.width_sd * 0.5, line.centerY);
    [pwAndAccountView addSubview:line];

    
    //===登录===
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setTitle:@"确认修改" forState:UIControlStateNormal];
    loginBtn.backgroundColor = UIColorFromRGB(0xd23023);
    loginBtn.frame = CGRectMake(10, pwAndAccountView.bottom_sd + 20, self.view.width_sd - 20, 40);
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
}


#pragma mark -
- (void)btnClick:(UIButton *)btn{

    [self.accountTextField resignFirstResponder];
    [self.pwTextField resignFirstResponder];
    [self.confirmPwTextField resignFirstResponder];
    
    if ([SYAppConfig contactIsEmpty:self.pwTextField.text] || [SYAppConfig contactIsEmpty:self.confirmPwTextField.text]) {
        [self showMessageWithContent:@"请输入正确密码" duration:1];
        return;
    }
    
    if (self.confirmPwTextField.text.length == 0 || self.pwTextField.text == 0) {
        [self showMessageWithContent:@"密码不能为空" duration:1];
        return;
    }

    if (self.pwTextField.text.length < 6 || self.confirmPwTextField.text.length < 6) {
        [self showMessageWithContent:@"密码不少于6位" duration:1];
        return;
    }
    
    if (![self.pwTextField.text isEqualToString:self.confirmPwTextField.text]) {
        [self showErrorWithContent:@"两次填写的密码不一致" duration:1];
        return;
    }
    
    
    WEAK_SELF;
    SYLoginHttpDAO *loginHttpDAO = [[SYLoginHttpDAO alloc] init];
    //登录页点击忘记密码后进来
    if (self.isChangeNewPWWithVerifyCode) {
        [loginHttpDAO changeNewPWWithVerifyCode:self.changeNewPWWithVerifyCode WithUsername:self.accountTextField.text WithNewPassword:self.confirmPwTextField.text Succeed:^{
            
            [weakSelf showSuccessWithContent:@"修改成功" duration:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                SYLoginViewController *loginVC = [[SYLoginViewController alloc] initWithShowLaunchViewAnim:NO];
                [FrameManager pushViewController:loginVC animated:NO];
            });
        } fail:^(NSError *error) {
             [weakSelf showErrorWithContent:[error.userInfo objectForKey:@"NSLocalizedDescription"] duration:1];
        }];
    }
    else{
        [loginHttpDAO changeNewPWWithOldPassword:[SYAppConfig shareInstance].password WithUsername:self.phone WithNewPassword:self.confirmPwTextField.text Succeed:^{
            
            [weakSelf showSuccessWithContent:@"修改成功" duration:1];
            //修改成功后返回登录页
            [[SYLinphoneManager instance] removeAccount];   //sip登出
            [SYLoginInfoModel loginOut];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                SYLoginViewController *loginVC = [[SYLoginViewController alloc] initWithShowLaunchViewAnim:NO];
                [FrameManager pushViewController:loginVC animated:NO];
            });
        } fail:^(NSError *error) {
            [weakSelf showErrorWithContent:[error.userInfo objectForKey:@"NSLocalizedDescription"] duration:1];
        }];
    }
}




#pragma mark - touch delegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.accountTextField resignFirstResponder];
    [self.pwTextField resignFirstResponder];
    [self.confirmPwTextField resignFirstResponder];
}

@end
