//
//  MyInfoViewController.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/7/3.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "MyInfoViewController.h"
#import "PersonalSettingCell.h"
#import "SYSettingTableViewCell.h"
#import "AffineDrawer.h"
#import "InfomationViewController.h"
#import "HouseManagementCell.h"

#import "RoomManageCtrl.h"
#import "DisturbManageSettingCtrl.h"
#import "DeviceSaveCtrl.h"
#import "ShareViewController.h"
#import "CheckUpdateViewController.h"
#import "AboutInfoViewController.h"
#import "HelpFeedBackCtrl.h"
#import "ApplyRecommand.h"
#import "SYShareViewController.h"
#import "SYAbountViewController.h"
#import "SYHelpViewController.h"
#import "SYGuardMonitorViewController.h"

@interface MyInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, strong) RoomManageCtrl *roomManageCtrl;
@property (nonatomic, strong) DisturbManageSettingCtrl *disturbManageSettingCtrl;
@property (nonatomic, strong) DeviceSaveCtrl *deviceSaveCtrl;
@property (nonatomic, strong) SYShareViewController *shareViewController;
@property (nonatomic, strong) CheckUpdateViewController *checkUpdateViewController;
@property (nonatomic, strong) SYAbountViewController *aboutInfoViewController;
@property (nonatomic, strong) SYHelpViewController *helpFeedBackCtrl;
@property (nonatomic, strong) ApplyRecommand *applyRecommandCtrl;

@property (nonatomic,strong) AffineDrawer *drawer;
@property (nonatomic,strong) AffineDrawer *feedBackdrawer;
@property (nonatomic, strong) UIView *HeadTopView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic,strong) MBProgressHUD *progressHud;
@property (nonatomic,strong) SYTextDescriptionViewController *textDescriptionViewController;
@property (nonatomic,strong) SYFeedbackViewController *feedBackCtrl;
@end

@implementation MyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(0xebebeb);
    [self initUI];
}

- (void)initUI
{
    UIView *HeadTopView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth - dockWidth, 50)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:HeadTopView.bounds];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel = titleLabel;
    titleLabel.text = @"个人设置";
    [HeadTopView addSubview:titleLabel];
    [self.view addSubview:HeadTopView];
    self.HeadTopView = HeadTopView;
    
    self.progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHud.mode = MBProgressHUDModeIndeterminate;
    self.progressHud.label.text = @"加载中";
    
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [UIColor lightGrayColor];
    [HeadTopView addSubview:self.lineView];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeDrawer)
                                                 name:@"closeDrawer"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeFeedBackDrawer)
                                                 name:@"closeFeedBackDrawer"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeInforDetail)
                                                 name:@"closeInforDetail"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openFunction) name:@"openFunction" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openPrivate) name:@"openPrivate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openFeedBack) name:@"openFeedBack" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageNotificationState:) name:SYNOTICE_MESSAGE_NOTIFICATION_CHANGE object:nil];
    [self initDrawer];
    
    [self.view addSubview:self.progressHud];
}

- (void)closeInforDetail
{
    self.textDescriptionViewController.view.hidden = YES;
    [self.textDescriptionViewController.view removeFromSuperview];
    
    self.feedBackCtrl.view.hidden = YES;
    [self.feedBackCtrl.view removeFromSuperview];
}

#pragma mark - noti
- (void)messageNotificationState:(NSNotification *)notif{
    int nType = [[notif.userInfo objectForKey:@"MessageNotificationState"] intValue];
    [self.tableView reloadData];
}

- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation
{
    [self.tableView reloadData];
}

- (void)openFunction
{
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    
    self.textDescriptionViewController = nil;
    self.textDescriptionViewController = [[SYTextDescriptionViewController alloc] initWithType:functionType];
    self.feedBackdrawer = [[AffineDrawer alloc] initWithView:keyWindow.rootViewController.view menuView:self.textDescriptionViewController.view menuFrame:CGRectMake(screenWidth, 0, self.view.frame.size.width * 0.7, screenHeight)];
    [self.feedBackdrawer openDrawer];
}

- (void)openPrivate
{
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    
    self.textDescriptionViewController = nil;
    self.textDescriptionViewController = [[SYTextDescriptionViewController alloc] initWithType:itemType];
    self.feedBackdrawer = [[AffineDrawer alloc] initWithView:keyWindow.rootViewController.view menuView:self.textDescriptionViewController.view menuFrame:CGRectMake(screenWidth, 0, self.view.frame.size.width * 0.7, screenHeight)];
    [self.feedBackdrawer openDrawer];
}

- (void)openFeedBack
{
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    
    self.feedBackCtrl = nil;
    self.feedBackCtrl = [[SYFeedbackViewController alloc] init];
    self.feedBackdrawer = [[AffineDrawer alloc] initWithView:keyWindow.rootViewController.view menuView:self.feedBackCtrl.view menuFrame:CGRectMake(screenWidth, 0, self.view.frame.size.width * 0.7, screenHeight)];
    [self.feedBackdrawer openDrawer];
}


- (void)initDrawer
{
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    self.roomManageCtrl = nil;
    self.roomManageCtrl = [[RoomManageCtrl alloc] init];
    self.roomManageCtrl.view.hidden = YES;
    
    self.drawer = [[AffineDrawer alloc] initWithView:keyWindow.rootViewController.view menuView:self.roomManageCtrl.view menuFrame:CGRectMake(screenWidth, 0, self.view.frame.size.width * 0.7, screenHeight)];
    
    [self closeDrawer];
}

- (void)closeDrawer
{
    [self.drawer closeDrawer];
    self.roomManageCtrl.view.hidden = YES;
    self.drawer.menuView.hidden = YES;
}

- (void)closeFeedBackDrawer
{
    [self.feedBackdrawer closeDrawer];
    self.feedBackCtrl.view.hidden = YES;
    self.textDescriptionViewController.view.hidden = YES;
}

- (void)viewWillLayoutSubviews
{
    [self closeDrawer];
    [self closeFeedBackDrawer];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeShare" object:nil];
    
    self.feedBackdrawer.mask.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    self.drawer.mask.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    self.roomManageCtrl.view.frame = CGRectMake(screenWidth, 0, screenWidth * 0.7, screenHeight);
    
    self.HeadTopView.frame = CGRectMake(0, 20, screenWidth - dockWidth, 50);
    self.titleLabel.frame = self.HeadTopView.bounds;
    self.lineView.frame = CGRectMake(0, 50, screenWidth - dockWidth, 1);
    
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.HeadTopView.frame) + 1, screenWidth - dockWidth, screenHeight - self.HeadTopView.frame.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 2) {
        return 2;
    }
    else if (section == 3) {
        return 2;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 120.0f;
    }
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth - dockWidth , 50)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth - dockWidth, 10)];
    label.textAlignment = NSTextAlignmentCenter;
//    if (section == 0) {
//        label.text = @"个人设置";
//    }
    
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.0f;
    }
    
    return 20.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        static NSString *identify = @"PersonalSettingCell";
        
        PersonalSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[PersonalSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            //cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell.btnCallManager addTarget:self action:@selector(callManager) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }else{
        static NSString *identify = @"SYSettingTableViewCell";
        SYSettingTableViewCell *settingableViewCell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!settingableViewCell) {
            settingableViewCell = [[SYSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            settingableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            settingableViewCell.delegate = self;
        }
        
        settingableViewCell.rectCell = CGRectMake(screenWidth - dockWidth - 70, 0, 70, 50);
        //update data
        if (indexPath.section == 1) {
            [settingableViewCell updateLeftInfo:@"允许消息推送" Type:switchType];
            settingableViewCell.otherLab.hidden = YES;
            settingableViewCell.leftLab.hidden = NO;
            settingableViewCell.arrowImgView.hidden = YES;
        }else if (indexPath.section == 2){
            if (indexPath.row == 0) {
                [settingableViewCell updateLeftInfo:@"房产管理" Type:arrowType];
                settingableViewCell.otherLab.hidden = YES;
                settingableViewCell.leftLab.hidden = NO;
                settingableViewCell.arrowImgView.hidden = NO;
                settingableViewCell.underLineView.hidden = NO;
            }else if (indexPath.row == 1) {
                [settingableViewCell updateLeftInfo:@"勿扰设置" Type:arrowType];
                settingableViewCell.underLineView.hidden = NO;
                settingableViewCell.otherLab.hidden = YES;
                settingableViewCell.leftLab.hidden = NO;
                settingableViewCell.arrowImgView.hidden = NO;
            }else if (indexPath.row == 2) {
                [settingableViewCell updateLeftInfo:@"应用保护" Type:arrowType];
                settingableViewCell.otherLab.hidden = YES;
                settingableViewCell.leftLab.hidden = NO;
                settingableViewCell.arrowImgView.hidden = NO;
            }
            
        }else if (indexPath.section == 3){
            
            if (indexPath.row == 0) {
                [settingableViewCell updateLeftInfo:@"分享应用" Type:arrowType];
                settingableViewCell.underLineView.hidden = NO;
                settingableViewCell.otherLab.hidden = YES;
                settingableViewCell.leftLab.hidden = NO;
                settingableViewCell.arrowImgView.hidden = NO;
            }else if (indexPath.row == 1) {
                [settingableViewCell updateLeftInfo:@"关于友邻邦HD" Type:arrowType];
                settingableViewCell.underLineView.hidden = NO;
                settingableViewCell.otherLab.hidden = YES;
                settingableViewCell.leftLab.hidden = NO;
                settingableViewCell.arrowImgView.hidden = NO;
            }else if (indexPath.row == 2) {
                [settingableViewCell updateLeftInfo:@"版本信息" Type:arrowType];
                settingableViewCell.underLineView.hidden = NO;
                settingableViewCell.otherLab.hidden = YES;
                settingableViewCell.leftLab.hidden = NO;
                settingableViewCell.arrowImgView.hidden = NO;
            }
        }else if (indexPath.section == 4) {
            [settingableViewCell updateLeftInfo:@"帮助与反馈" Type:arrowType];
            settingableViewCell.otherLab.hidden = YES;
            settingableViewCell.leftLab.hidden = NO;
            settingableViewCell.arrowImgView.hidden = NO;
        }else if (indexPath.section == 5) {
            [settingableViewCell updateLeftInfo:@"应用推荐" Type:arrowType];
            settingableViewCell.otherLab.hidden = YES;
            settingableViewCell.leftLab.hidden = NO;
            settingableViewCell.arrowImgView.hidden = NO;
        }else if (indexPath.section == 6){
            [settingableViewCell updateLeftInfo:@"退出登录" Type:arrowType];
            settingableViewCell.otherLab.hidden = NO;
            settingableViewCell.leftLab.hidden = YES;
            settingableViewCell.arrowImgView.hidden = YES;
        }
        
        return settingableViewCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2){
        if (indexPath.row == 0) {
            //账号房产管理
            self.roomManageCtrl = nil;
            self.roomManageCtrl = [[RoomManageCtrl alloc] init];
            self.roomManageCtrl.view.hidden = NO;
            [self.drawer setContentView:self.roomManageCtrl.view];
            [self.drawer openDrawer];
            
        }else if (indexPath.row == 1) {
            //勿扰设置
            self.disturbManageSettingCtrl = nil;
            self.disturbManageSettingCtrl = [[DisturbManageSettingCtrl alloc] init];
            [self.drawer setContentView:self.disturbManageSettingCtrl.view];
            [self.drawer openDrawer];
        }else if (indexPath.row == 2) {
            //应用保护
            self.deviceSaveCtrl = nil;
            self.deviceSaveCtrl = [[DeviceSaveCtrl alloc] init];
            [self.drawer setContentView:self.deviceSaveCtrl.view];
            [self.drawer openDrawer];
            
            return;
            [Common addAlertWithTitle:@"暂无该功能"];
        }
        
    }else if (indexPath.section == 3){
        if (indexPath.row == 0) {
            //分享应用
            self.shareViewController = nil;
            self.shareViewController = [[SYShareViewController alloc] init];
            [self.drawer setContentView:self.shareViewController.view];
            [self.drawer openDrawer];
        }else if (indexPath.row == 1) {
            //关于友邻邦HD
            self.aboutInfoViewController = nil;
            self.aboutInfoViewController = [[SYAbountViewController alloc] init];
            [self.drawer setContentView:self.aboutInfoViewController.view];
            [self.drawer openDrawer];
        }else if (indexPath.row == 2) {
            //检查更新
            self.checkUpdateViewController = nil;
            self.checkUpdateViewController = [[CheckUpdateViewController alloc] init];
            [self.drawer setContentView:self.checkUpdateViewController.view];
            [self.drawer openDrawer];
            
        }
    }else if (indexPath.section == 4) {
        //帮助与反馈
        self.helpFeedBackCtrl = nil;
        self.helpFeedBackCtrl = [[SYHelpViewController alloc] init];
        [self.drawer setContentView:self.helpFeedBackCtrl.view];
        [self.drawer openDrawer];
    
    }else if (indexPath.section == 5) {
        //应用推荐
        self.applyRecommandCtrl = nil;
        self.applyRecommandCtrl = [[ApplyRecommand alloc] init];
        [self.drawer setContentView:self.applyRecommandCtrl.view];
        [self.drawer openDrawer];
        
    }else if (indexPath.section == 6) {
        //退出登录
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确认退出" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
        alertView.delegate = self;
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        
        [self.progressHud showAnimated:YES];
        SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
        [communityHttpDAO padLogoutWithUserName:[SYLoginInfoModel shareUserInfo].userInfoModel.username Succeed:^{
            
            //[Common addAlertWithTitle:@"退出登录成功"];
            [self loginOut];
            [self.progressHud hideAnimated:YES];
            
        } fail:^(NSError *error) {
            [self.progressHud hideAnimated:YES];
            NSLog(@"退出登录 == %@",[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]]);
            
            [self loginOut];
        }];
    }
};

- (void)loginOut
{
    [[SYLinphoneManager instance] removeAccount];   //sip登出
    [SYLoginInfoModel loginOut];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"alreadyLogin"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginAgain" object:nil];
    [[MyFMDataBase shareMyFMDataBase] deleteDataWithTableName:sipModel delegeteDic:nil];
}

- (void)showCamerer
{
    UIImagePickerController *imgController = [[UIImagePickerController alloc] init];
    imgController.allowsEditing = YES;
    imgController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imgController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    imgController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //[delegate.window.rootViewController presentViewController:imgController animated:YES completion:nil];
}

- (void)callManager
{
    [self showCamerer];
    [[LinphoneManager instance] changeFrontCamera];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"fneibor_flag"]) {
        [Common addAlertWithTitle:@"呼叫失败"];
        return;
    }
    
    SYLockListModel *model = [[SYLockListModel alloc] init];
    model.sip_number = [NSString stringWithFormat:@"7%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"fneibor_flag"]];
    model.lock_name = @"正在视频通话中...";
    
    
    SYGuardMonitorViewController *subAccountInfoViewController = [[SYGuardMonitorViewController alloc] initWithCall:nil GuardInfo:model InComingCall:NO];
    subAccountInfoViewController.monitorStatus = @"YES";
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window.rootViewController presentViewController:subAccountInfoViewController animated:YES completion:nil];
}

#pragma - mark SYSettingTableViewCellDelegate
- (void)switchChange:(BOOL)change{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    if (iOS8_OR_LATER) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            NSURL *url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
