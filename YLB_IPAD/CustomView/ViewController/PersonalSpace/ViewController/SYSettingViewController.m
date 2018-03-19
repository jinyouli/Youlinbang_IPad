//
//  SYSettingViewController.m
//  YLB
//
//  Created by YAYA on 2017/3/18.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYSettingViewController.h"
#import "SYSettingTableViewCell.h"
#import "SYChangePwOldPWViewController.h"
#import "SYGesturePWViewController.h"
#import "SYLoginViewController.h"
#import "GeTuiSdk.h"

@interface SYSettingViewController ()<UITableViewDelegate, UITableViewDataSource, SYSettingTableViewCellDelegate>

@property (nonatomic, retain) UITableView *tableView;

@end

@implementation SYSettingViewController

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
    return @"个人设置";
}


#pragma mark - private
- (void)initUI{
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = UIColorFromRGB(0xebebeb);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, SYSettingTableViewCellHeight)];
 
    UIButton *loginOutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginOutBtn.frame = CGRectMake(10, 0, footerView.width - 20, footerView.height);
    [loginOutBtn setTitle:@"退出" forState:UIControlStateNormal];
    loginOutBtn.backgroundColor = UIColorFromRGB(0xd23023);
    [loginOutBtn addTarget:self action:@selector(loginOutClick:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:loginOutBtn];
    
    self.tableView.tableFooterView = footerView;
}


#pragma mark - event
- (void)loginOutClick:(UIButton *)btn{
    [[SYLinphoneManager instance] removeAccount];   //sip登出
    [SYLoginInfoModel loginOut];
    
    SYLoginViewController *loginVC = [[SYLoginViewController alloc] initWithShowLaunchViewAnim:NO];
    [FrameManager pushViewController:loginVC animated:NO];
}


#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SYSettingTableViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 3) {
        return 8;
    }
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (section == 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identify = @"SYSettingTableViewCell";
    SYSettingTableViewCell *settingableViewCell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!settingableViewCell) {
        settingableViewCell = [[SYSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        settingableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        settingableViewCell.delegate = self;
    }
    
    settingableViewCell.rectCell = CGRectMake(screenWidth - dockWidth - 70, 0, 70, 50);
    //update data
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [settingableViewCell updateLeftInfo:@"允许消息推送" Type:switchType];
        }else{
            [settingableViewCell updateLeftInfo:@"勿扰模式" Type:arrowType];
        }
    }else if (indexPath.section == 1){
        [settingableViewCell updateLeftInfo:@"修改密码" Type:arrowType];
    }else if (indexPath.section == 2){
        [settingableViewCell updateLeftInfo:@"手势" Type:arrowType];
    }else if (indexPath.section == 3) {
        [settingableViewCell updateLeftInfo:@"绑定手机" Type:phoneType];
    }else if (indexPath.section == 4){
        [settingableViewCell updateLeftInfo:@"蓝牙开锁" Type:arrowType];
    }
    
    return settingableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 0:{
            if (indexPath.row == 1) {
                [self showMessageWithContent:@"功能没开通" duration:1];
            }
        }
            break;
        case 1:{
            SYChangePwOldPWViewController *oldPWViewController = [[SYChangePwOldPWViewController alloc] init];
            oldPWViewController.isJumpNewPWVC = YES;
            [FrameManager pushViewController:oldPWViewController animated:YES];
        }
            break;
        case 2:{
            SYGesturePWViewController *gesturePWViewController = [[SYGesturePWViewController alloc] init];
            [FrameManager pushViewController:gesturePWViewController animated:YES];
        }
        case 4:{
            SYGesturePWViewController *gesturePWViewController = [[SYGesturePWViewController alloc] init];
            [FrameManager pushViewController:gesturePWViewController animated:YES];
        }
            break;
        default:
            break;
    }
}


#pragma - mark SYSettingTableViewCellDelegate
- (void)switchChange:(BOOL)change{

    [SYLoginInfoModel shareUserInfo].isAllowPushMessage = change;
    [SYLoginInfoModel saveWithSYLoginInfo];
    //[GeTuiSdk setPushModeForOff:!change];   //是否开启个推推送
    [GeTuiSdk setPushModeForOff:NO];
}
@end
