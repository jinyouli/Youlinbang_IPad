//
//  SYLoginViewController.m
//  YLB
//
//  Created by YAYA on 2017/3/29.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYLoginViewController.h"
#import "SYLoginNormalViewController.h"
#import "SYLoginHttpDAO.h"
#import "SYRegisterViewController.h"

typedef enum : NSUInteger {
    loginTag = 0,
    registerTag
} btnTag;

@interface SYLoginViewController ()<UIAlertViewDelegate>

@property (nonatomic, retain) UIImageView *iconImgView;
@property (nonatomic, retain) UIButton *loginBtn;
@property (nonatomic, retain) UIButton *registerBtn;
@property (nonatomic, retain) UILabel *appVersionLab;
@property (retain, nonatomic) UIView *launchView;   //闪屏动画页
@property (retain, nonatomic) UIImageView *bgImgView;   //背景图

@property (nonatomic, copy) NSString *strIP;
@property (nonatomic, assign) BOOL isShowLaunchViewAnimation;   //首次打开APP显示的登录页时，显示闪屏页动画
@end

@implementation SYLoginViewController

- (instancetype)initWithShowLaunchViewAnim:(BOOL)isShowLaunchViewAnimation{
    if (self = [super init]) {
        self.isShowLaunchViewAnimation = isShowLaunchViewAnimation;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
    [self starLaunchViewAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - overwrite
- (BOOL)hiddenNavBar{
    return YES;
}

- (BOOL)panBackGestureEnable{
    return NO;
}


#pragma mark - private
- (void)initUI{

    self.bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sy_login_BG"]];
    self.bgImgView.frame = self.view.bounds;
    [self.view addSubview:self.bgImgView];
    
    UIImage *img = [UIImage imageNamed:@"sy_iconImage"];
    self.iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.height_sd * 0.3f, img.size.width, img.size.height)];
    self.iconImgView.image = img;
    self.iconImgView.userInteractionEnabled = YES;
    self.iconImgView.center = CGPointMake(self.view.width_sd * 0.5f, self.iconImgView.centerY);
    [self.view addSubview:self.iconImgView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconImgViewClick)];
    tap.numberOfTapsRequired = 6;
    [self.iconImgView addGestureRecognizer:tap];

    self.loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginBtn.frame = CGRectMake(0, self.view.height_sd * 0.65f, self.view.width_sd - 80, 40);
    [self.loginBtn setTitleColor:UIColorFromRGB(0xD23023) forState:UIControlStateNormal];
    self.loginBtn.layer.borderWidth = 1;
    self.loginBtn.layer.borderColor = UIColorFromRGB(0xD23023).CGColor;
    self.loginBtn.layer.cornerRadius = self.loginBtn.height * 0.5f;
    self.loginBtn.tag = loginTag;
    [self.loginBtn setTitle:@"手机号登录" forState:UIControlStateNormal];
    self.loginBtn.center = CGPointMake(self.view.width_sd * 0.5f, self.loginBtn.centerY);
    [self.loginBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginBtn];
    
    self.registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.registerBtn.frame = CGRectMake(0, self.loginBtn.bottom_sd + 20, self.view.width_sd - 80, 40);
    [self.registerBtn setTitleColor:UIColorFromRGB(0xD23023) forState:UIControlStateNormal];
    self.registerBtn.layer.borderWidth = 1;
    self.registerBtn.layer.borderColor = UIColorFromRGB(0xD23023).CGColor;
    self.registerBtn.layer.cornerRadius = self.registerBtn.height * 0.5f;
    self.registerBtn.tag = registerTag;
    [self.registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    self.registerBtn.center = CGPointMake(self.view.width_sd * 0.5f, self.registerBtn.centerY);
    [self.registerBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.registerBtn];
    
    self.appVersionLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.height - 30, self.view.width_sd, 30)];
    self.appVersionLab.textColor = [UIColor grayColor];
    self.appVersionLab.font = [UIFont systemFontOfSize:12];
    self.appVersionLab.textAlignment = NSTextAlignmentCenter;
    self.appVersionLab.text = [NSString stringWithFormat:@"版本号: %@",[SYAppConfig appVersion]];
    [self.view addSubview:self.appVersionLab];
    
    
    //==============闪屏动画===========
    self.launchView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIImageView *launchImgView = [[UIImageView alloc] initWithFrame:self.launchView.bounds];
    launchImgView.image = [UIImage imageNamed:@"LaunchImage_HD"];
    [self.launchView addSubview:launchImgView];
    [self.view addSubview:self.launchView];
    self.launchView.hidden = YES;
}

//闪屏页的动画
- (void)starLaunchViewAnimation{
    
    if (!self.isShowLaunchViewAnimation) {
        return;
    }
    
    self.launchView.hidden = NO;
    WEAK_SELF;
    [UIView animateWithDuration:1 animations:^{
        weakSelf.launchView.frame = (CGRect){{0, -weakSelf.launchView.bounds.size.height}, weakSelf.launchView.frame.size};
    } completion:^(BOOL finished) {
        weakSelf.launchView = nil;
    }];

    // 设定为缩放
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    // 动画选项设定
    animation.duration = 1.0; // 动画持续时间
    animation.repeatCount = 0; // 重复次数
    
    // 缩放倍数
    animation.fromValue = [NSNumber numberWithFloat:1.5]; // 开始时的倍率
    animation.toValue = [NSNumber numberWithFloat:1.0]; // 结束时的倍率
    
    // 添加动画
    [self.bgImgView.layer addAnimation:animation forKey:@"scale-layer"];
}


#pragma mark - event
- (void)btnClick:(UIButton *)btn{

    if (btn.tag == loginTag) {
        SYLoginNormalViewController *loginVC = [[SYLoginNormalViewController alloc] init];
        [FrameManager pushViewController:loginVC animated:YES];
    }else{
        SYRegisterViewController *vc = [[SYRegisterViewController alloc] init];
        [FrameManager pushViewController:vc animated:YES];
    }
}

- (void)iconImgViewClick{
    self.strIP = [SYAppConfig baseURL];
    if ([[SYAppConfig shareInstance].base_url isEqualToString:@"https://gdsayee.cn:28884"]) {
        self.strIP = @"https://api.sayee.cn:28084";
        //self.strIP = @"https://gdsayee.cn:28084";
    }else{
        self.strIP = @"https://gdsayee.cn:28884";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更换IP" message:self.strIP delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
    [alert show];
}



#pragma mark - UIAlertView delegete
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:self.strIP forKey:@"base_url"];
        [SYAppConfig shareInstance].base_url = self.strIP;
    }
}
@end
