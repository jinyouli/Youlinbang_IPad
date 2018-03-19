//
//  SYLoginNormalViewController.m
//  YLB
//
//  Created by YAYA on 2017/3/30.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYLoginNormalViewController.h"
#import "SYLoginHttpDAO.h"
#import "SYProvisionViewController.h"
#import "SYPersonalSpaceHttpDAO.h"
#import "SYGestureUnlockViewController.h"
#import "SYNeighborListViewController.h"
#import "PCCircleViewConst.h"
#import "SYVerifyCodeViewController.h"

typedef enum : NSUInteger {
    loginTag = 0,
    noticeTag,
    forgetPWTag,
    moreAccountTag,
    noticeDetailTag
} BtnTag;

@interface SYLoginNormalViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic ,assign) BOOL noticeMsgSlected;
@property (nonatomic ,strong) UIImageView *noticeImgView;
@property (nonatomic ,strong) UITextField *pwTextField;
@property (nonatomic ,strong) UITextField *accountTextField;
@property (nonatomic ,strong) UIButton *noticeBtn;
@property (nonatomic, strong) UIView *addressMoreView;  //显示更多地址的下拉view

@property (nonatomic ,assign) float tableViewNumber;
@end

@implementation SYLoginNormalViewController


- (void)dealloc{
    NSLog(@"SYLoginNormalViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readProvisionNoti) name:SYNOTICE_ReadedProvisionNotification object:nil];
    
    self.tableViewNumber = [SYAppConfig getUserLoginInfoAccountAndPassword].count;
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
    
    self.accountTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, accountView.width_sd - 100, accountView.height_sd)];
    self.accountTextField.placeholder = @"手机号";
    self.accountTextField.leftView = leftView;
    self.accountTextField.delegate = self;
    self.accountTextField.leftViewMode = UITextFieldViewModeAlways;
    self.accountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    if ([SYAppConfig getUserLoginInfoAccountAndPassword] > 0) {
        NSArray *arrAccount = ((NSDictionary *)[SYAppConfig getUserLoginInfoAccountAndPassword].firstObject).allKeys;
        if (arrAccount.count > 0) {
            self.accountTextField.text = [NSString stringWithFormat:@"%@",arrAccount.firstObject];
        }
    }
    [accountView addSubview:self.accountTextField];
    
    UIImage *moreAccountImg = [UIImage imageNamed:@"sy_login_icon_userhistory_hidden"];
    UIImageView *moreImgView = [[UIImageView alloc] initWithFrame:CGRectMake(accountView.width_sd - moreAccountImg.size.width - 20, 0, moreAccountImg.size.width, moreAccountImg.size.height)];
    moreImgView.image = moreAccountImg;
    moreImgView.center = CGPointMake(moreImgView.centerX, accountView.height_sd * 0.5);
    [accountView addSubview:moreImgView];

    UIButton *moreAccountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreAccountBtn.tag = moreAccountTag;
    moreAccountBtn.backgroundColor = [UIColor clearColor];
    moreAccountBtn.frame = CGRectMake(0, 0, accountView.height_sd, accountView.height);
    [moreAccountBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    moreAccountBtn.center = moreImgView.center;
    [accountView addSubview:moreAccountBtn];
    
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
    self.pwTextField.placeholder = @"密码";
    self.pwTextField.leftView = leftView;
    self.pwTextField.secureTextEntry = YES;
//    if (self.tableViewNumber > 0) {
//        NSArray *arrPW = ((NSDictionary *)[SYAppConfig getUserLoginInfoAccountAndPassword].firstObject).allValues;
//        if (arrPW.count > 0) {
//            self.pwTextField.text = [NSString stringWithFormat:@"%@",arrPW.firstObject];
//        }
//    }
    self.pwTextField.leftViewMode = UITextFieldViewModeAlways;
    self.pwTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [passwordView addSubview:self.pwTextField];
    
    UIButton *forgetPWBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [forgetPWBtn setTitle:@"忘记密码?" forState:UIControlStateNormal];
    forgetPWBtn.tag = forgetPWTag;
    forgetPWBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    forgetPWBtn.frame = CGRectMake(passwordView.width_sd - 90, 0, 80, passwordView.height_sd);
    [forgetPWBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [forgetPWBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [passwordView addSubview:forgetPWBtn];

    line = [[UIView alloc] initWithFrame:CGRectMake(0, passwordView.bottom_sd, accountView.width_sd - 20, 1)];
    line.backgroundColor = UIColorFromRGB(0x999999);
    line.center = CGPointMake(accountView.width_sd * 0.5, line.centerY);
    [pwAndAccountView addSubview:line];
    
    
    //===登录===
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    loginBtn.tag = loginTag;
    loginBtn.backgroundColor = UIColorFromRGB(0xd23023);
    loginBtn.frame = CGRectMake(10, pwAndAccountView.bottom_sd + 20, self.view.width_sd - 20, 40);
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    
    //===条款===
    UIImage *noticeImg = [UIImage imageNamed:@"sy_login_check_click"];
    self.noticeImgView = [[UIImageView alloc] initWithFrame:CGRectMake(loginBtn.left_sd, loginBtn.bottom_sd + 20, noticeImg.size.width, noticeImg.size.height)];
    self.noticeImgView.image = noticeImg;
    [self.view addSubview:self.noticeImgView];
    self.noticeMsgSlected = YES;
    
    self.noticeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.noticeBtn.tag = noticeTag;
    self.noticeBtn.frame = CGRectMake(0, 0, noticeImg.size.width + 20, noticeImg.size.height + 20);
    self.noticeBtn.center = self.noticeImgView.center;
    [self.noticeBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.noticeBtn];
    
    
    UILabel *noticeDetailLab = [[UILabel alloc] initWithFrame:CGRectMake(self.noticeBtn.right_sd + 5, self.noticeBtn.top_sd, self.view.width_sd - self.noticeBtn.right_sd - 30, 20)];
    noticeDetailLab.textColor = UIColorFromRGB(0x999999);
    noticeDetailLab.center = CGPointMake(noticeDetailLab.centerX, self.noticeBtn.centerY);
    noticeDetailLab.text = @"我已阅读并同意相关服务条款";
    [self.view addSubview:noticeDetailLab];
    
    UIButton *noticeDetailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    noticeDetailBtn.tag = noticeDetailTag;
    noticeDetailBtn.frame = noticeDetailLab.frame;
    [noticeDetailBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:noticeDetailBtn];
    

    //历史账号
    float fAddressMoreViewHeight = (self.tableViewNumber <= 3 ? self.tableViewNumber : 3) * 40.0;
    self.addressMoreView = [[UIView alloc] initWithFrame:CGRectMake(10, pwAndAccountView.bottom_sd - passwordView.height_sd + 3, pwAndAccountView.width_sd - 20, fAddressMoreViewHeight)];
    self.addressMoreView.backgroundColor = [UIColor whiteColor];
    self.addressMoreView.layer.borderColor = UIColorFromRGB(0x999999).CGColor;
    self.addressMoreView.layer.borderWidth = 1;
    self.addressMoreView.hidden = YES;
    [self.view addSubview:self.addressMoreView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,self.addressMoreView.width_sd, self.addressMoreView.height_sd) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.addressMoreView addSubview:tableView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - event
- (void)btnClick:(UIButton *)btn{

    if (btn.tag == loginTag) {
        
        if (self.accountTextField.text.length == 0 || self.pwTextField.text == 0) {
            [self showMessageWithContent:@"账号或者密码不能为空" duration:1];
            return;
        }
        
        if (!self.noticeMsgSlected) {
            [self showMessageWithContent:@"请阅读并同意相关服务条款" duration:1];
            return;
        }
        
        [self showWithContent:nil];

        WEAK_SELF;
        SYLoginHttpDAO *loginHttpDAO = [[SYLoginHttpDAO alloc] init];
        [loginHttpDAO loiginWithPassword:self.pwTextField.text WithUsername:self.accountTextField.text Succeed:^(SYUserInfoModel *model) {
            
            if (!model) {
                [weakSelf showErrorWithContent:@"登录失败啦" duration:1];
                return ;
            }
            
            //手势密码
            [[NSUserDefaults standardUserDefaults] setObject:model.gestire_pwd forKey:gestureFinalSaveKey];
            [[NSUserDefaults standardUserDefaults] synchronize];

            //获取用户个人设置信息
            SYPersonalSpaceHttpDAO *personalSpaceHttpDAO = [[SYPersonalSpaceHttpDAO alloc] init];
            [personalSpaceHttpDAO getUserConfigInfoWithUserName:model.username Succeed:^(SYPersonalSpaceModel *model) {

            } fail:^(NSError *error) {
    
            }];

            [SYLinphoneManager instance].nExpires = model.registrationTimeout * 60 > 0 ? : 120 * 60;
            
//            NSString *name = @"1002";
//            NSString *password = @"wjp3557730";
//            NSString *domain = @"120.24.209.114";
//                        [[SYLinphoneManager instance] addProxyConfig:name password:password displayName:model.username domain:domain port:model.fs_port withTransport:model.transport];
            // sip登录
            [[SYLinphoneManager instance] addProxyConfig:model.user_sip password:model.user_password displayName:model.username domain:model.fs_ip port:model.fs_port withTransport:model.transport];
            
            //未绑定小区  (安装APP，首次登录成功后 获取的社区列表)
            if (![SYAppConfig shareInstance].bindedModel) {

                SYNeighborListViewController *vc = [[SYNeighborListViewController alloc] init];
                [FrameManager pushViewController:vc animated:YES];
                
                //没有手势密码则跳去设置页
                if (![[NSUserDefaults standardUserDefaults] objectForKey:gestureFinalSaveKey]) {
                    SYGestureUnlockViewController *loginVC = [[SYGestureUnlockViewController alloc] initWithCircleViewType:CircleViewTypeSetting];
                    loginVC.isHideNavigationBar = YES;
                    [FrameManager pushViewController:loginVC animated:NO];
                }
            }
            else{
                [FrameManager popToRootViewControllerAnimated:YES];
            }
            [FrameManager changeTabbarIndex:1];
            
            [weakSelf dismissHud:NO];
        } fail:^(NSError *error) {
            [weakSelf showErrorWithContent:[error.userInfo objectForKey:@"NSLocalizedDescription"] duration:1];
        }];
    }
    else if (btn.tag == noticeTag){
        self.noticeMsgSlected = !self.noticeMsgSlected;
        
        [self changeNoticeImg];
    }
    else if (btn.tag == forgetPWTag){
        
        if (self.accountTextField.text.length == 0) {
            [self showMessageWithContent:@"账号不能为空" duration:1];
            return;
        }
        SYVerifyCodeViewController *vc = [[SYVerifyCodeViewController alloc] initWithPhone:self.accountTextField.text WithPassword:nil];
        [FrameManager pushViewController:vc animated:YES];
    }
    else if (btn.tag == moreAccountTag){
        self.addressMoreView.hidden = !self.addressMoreView.hidden;
    }
    else if (btn.tag == noticeDetailTag){
        SYProvisionViewController *vc = [[SYProvisionViewController alloc] init];
        [FrameManager pushViewController:vc animated:YES];
    }
    
    [self.accountTextField resignFirstResponder];
    [self.pwTextField resignFirstResponder];
}

- (void)changeNoticeImg{
    UIImage *img = [UIImage imageNamed:@"sy_login_check_click"];
    if (!self.noticeMsgSlected) {
        img = [UIImage imageNamed:@"sy_login_check"];
    }
    self.noticeImgView.image = img;
}


#pragma mark - notification
- (void)readProvisionNoti{
    self.noticeMsgSlected = YES;

    [self changeNoticeImg];
}


#pragma mark - touch delegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    self.addressMoreView.hidden = YES;
}


#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.tableViewNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identify = @"UITableViewCell";
    UITableViewCell *settingableViewCell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!settingableViewCell) {
        settingableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        settingableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        settingableViewCell.textLabel.textColor = UIColorFromRGB(0x999999);
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 39, tableView.width_sd, 1)];
        [settingableViewCell.contentView addSubview:line];
    }
    
    if (self.tableViewNumber > indexPath.row) {
        NSDictionary *dic = [[SYAppConfig getUserLoginInfoAccountAndPassword] objectAtIndex:indexPath.row];
        settingableViewCell.textLabel.text = dic.allKeys.firstObject;
    }
    
    return settingableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tableViewNumber > indexPath.row) {
        NSDictionary *dic = [[SYAppConfig getUserLoginInfoAccountAndPassword] objectAtIndex:indexPath.row];;
        self.accountTextField.text = dic.allKeys.firstObject;
        self.pwTextField.text = @"";//dic.allValues.firstObject;
    }
    self.addressMoreView.hidden = YES;
}


#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    self.pwTextField.text = @"";
    return YES;
}

@end
