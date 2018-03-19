//
//  SYVerifyCodeViewController.m
//  YLB
//
//  Created by YAYA on 2017/4/12.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYVerifyCodeViewController.h"
#import "SYLoginHttpDAO.h"
#import "SYChangePwNewPWViewController.h"
#import "SYLoginViewController.h"

typedef enum : NSUInteger {
    nextTag = 0,
    getVerifyCodeTag,
} BtnTag;

@interface SYVerifyCodeViewController ()
@property (nonatomic ,strong) UIButton *forgetPWBtn;
@property (nonatomic ,strong) UITextField *verifyCodeTextField;
@property (nonatomic ,copy) NSString *phone;
@property (nonatomic ,copy) NSString *password;
@end

@implementation SYVerifyCodeViewController

- (instancetype)initWithPhone:(NSString *)phone WithPassword:(NSString *)password{

    if (self = [super init]) {
        self.phone = phone;
        self.password = password;
    }
    return self;
}

- (void)dealloc{

    NSLog(@"====SYVerifyCodeViewController dealloc===========");
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
    return @"手机号验证";
}


#pragma mark - private
- (void)initUI{
    self.view.backgroundColor = UIColorFromRGB(0xebebeb);
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, self.view.width_sd, 20)];
    lab.textColor = UIColorFromRGB(0x999999);
    lab.font = [UIFont systemFontOfSize:14];
    lab.text = @"为了安全，我们会向你的手机发送短信验证码";
    [self.view addSubview:lab];
    
    //===验证码区域===
    UIView *verifyCodeView = [[UIView alloc] initWithFrame:CGRectMake(0, lab.bottom_sd + 20, self.view.width_sd, 40)];
    [self.view addSubview:verifyCodeView];
    
    //UITextField leftview
    UIImage *img = [UIImage imageNamed:@"sy_login_icon_verify_code"];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, img.size.width + 10, img.size.height)];
    UIImageView *leftImgView = [[UIImageView alloc] initWithImage:img];
    leftImgView.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    [leftView addSubview:leftImgView];
    
    self.verifyCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, verifyCodeView.width_sd - 100, verifyCodeView.height_sd)];
    self.verifyCodeTextField.leftView = leftView;
    self.verifyCodeTextField.leftViewMode = UITextFieldViewModeAlways;
    self.verifyCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [verifyCodeView addSubview:self.verifyCodeTextField];
    
    self.forgetPWBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forgetPWBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    self.forgetPWBtn.tag = getVerifyCodeTag;
    self.forgetPWBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    self.forgetPWBtn.frame = CGRectMake(verifyCodeView.width_sd - 90, 0, 80, verifyCodeView.height_sd);
    [self.forgetPWBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.forgetPWBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [verifyCodeView addSubview:self.forgetPWBtn];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, verifyCodeView.height_sd - 1, verifyCodeView.width_sd - 20, 1)];
    line.backgroundColor = UIColorFromRGB(0x999999);
    line.center = CGPointMake(verifyCodeView.width_sd * 0.5, line.centerY);
    [verifyCodeView addSubview:line];
    
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setTitle:@"下一步" forState:UIControlStateNormal];
    loginBtn.tag = nextTag;
    loginBtn.backgroundColor = UIColorFromRGB(0xd23023);
    loginBtn.frame = CGRectMake(10, verifyCodeView.bottom_sd + 20, self.view.width_sd - 20, 40);
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
}

- (void)timerOpen{
    
    self.forgetPWBtn.enabled = NO;
    
    WEAK_SELF;
    __block int timeout = 60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout <= 0){
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //倒计时结束
                [weakSelf.forgetPWBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                weakSelf.forgetPWBtn.enabled = YES;
            });
        }else{
//            int hours = timeout / 3600;
//            int minutes = (timeout - hours*3600) / 60;
//            int seconds = timeout % 60;
            //            NSString *strTime = [NSString stringWithFormat:@"%d时%d分%.2d秒后重新获取验证码",hours,minutes, seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.forgetPWBtn setTitle:[NSString stringWithFormat:@"重新发送 %.2d", timeout] forState:UIControlStateNormal];
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

- (void)sendVerifyCode{
    WEAK_SELF;
    SYLoginHttpDAO *loginHttpDAO = [[SYLoginHttpDAO alloc] init];
    [self showMessageWithContent:@"验证码已发送" duration:1];
    [self timerOpen];
    [loginHttpDAO getVerifyCodeWithMobilePhone:self.phone Succeed:^(SYLoginInfoModel *model) {
        
        [weakSelf dismissHud:YES];
        
    } fail:^(NSError *error) {
        [weakSelf showErrorWithContent:[NSString stringWithFormat:@"%@", [error.userInfo objectForKey:@"NSLocalizedDescription"]] duration:1];
    }];
}


#pragma mark - event
- (void)btnClick:(UIButton *)btn{
    [self.view endEditing:YES];
    
    if ([SYAppConfig networkState] == sy_none) {
        [self showErrorWithContent:@"请检查网络" duration:1];
        return;
    }
    
    WEAK_SELF;
    SYLoginHttpDAO *loginHttpDAO = [[SYLoginHttpDAO alloc] init];
    
    if (btn.tag == getVerifyCodeTag) {
        
        [self showWithContent:nil];
        //注册
//        if (self.isRegister) {
            [loginHttpDAO checkUserExistsWithMobilePhone:self.phone WithUsername:self.phone WithEmail:nil Succeed:^(SYUserExistModel *model) {
                //注册
                if (self.isRegister) {
                    if (model && (model.isusername_existed || model.isphone_existed)) {
                        [weakSelf showMessageWithContent:@"该手机已注册" duration:1];
                        return ;
                    }
                }
                else{
                    if (!model.isusername_existed && !model.isphone_existed) {
                        [weakSelf showMessageWithContent:@"该手机未注册" duration:1];
                        return;
                    }
                }
                [weakSelf sendVerifyCode];
            } fail:^(NSError *error) {
                [weakSelf sendVerifyCode];
            }];
//        }
//        else{
//            [self sendVerifyCode];
//        }
        
    }else if (btn.tag == nextTag) {
        
        if (self.verifyCodeTextField.text.length != 6) {
            [self showErrorWithContent:@"请输入正确的验证码" duration:1];
            return;
        }
        
        //注册
        if (self.isRegister) {
            [self showWithContent:@"注册中"];
            [loginHttpDAO registerWithPassword:self.password WithUsername:self.phone WithVerifyCode:self.verifyCodeTextField.text WithMobilePhone:self.phone Succeed:^{
                
                [weakSelf showSuccessWithContent:@"注册成功" duration:1];
                SYLoginViewController *loginViewController = [[SYLoginViewController alloc] initWithShowLaunchViewAnim:NO];
                [FrameManager pushViewController:loginViewController animated:YES];
            } fail:^(NSError *error) {
                [weakSelf showErrorWithContent:[NSString stringWithFormat:@"%@", [error.userInfo objectForKey:@"NSLocalizedDescription"]] duration:1];
            }];
            return;
        }
        
        //修改新密码
        SYChangePwNewPWViewController *vc = [[SYChangePwNewPWViewController alloc] initWithPhone:self.phone];
        vc.isChangeNewPWWithVerifyCode = YES;
        vc.changeNewPWWithVerifyCode = self.verifyCodeTextField.text;
        [FrameManager pushViewController:vc animated:YES];
    }
}


#pragma mark - touchesBegan delegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
@end
