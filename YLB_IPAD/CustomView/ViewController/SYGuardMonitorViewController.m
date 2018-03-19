//
//  SYGuardMonitorViewController.m
//  YLB
//
//  Created by sayee on 17/4/1.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYGuardMonitorViewController.h"
#import "HBLockSliderView.h"
#import "SYCommunityHttpDAO.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LinphoneManager.h"

typedef enum : NSUInteger {
    RouteChangeBtnTag,
    HangUpBtnTag,
} BtnTag;

@interface SYGuardMonitorViewController ()<HBLockSliderDelegate>{
    dispatch_source_t timerPopVC;
    UISlider *volumeViewSlider;
}
@property (nonatomic, retain) UIView *monitorView;
@property (nonatomic, retain) UIView *monitorMaskView;
@property (nonatomic, assign) SYLinphoneCall *call;
@property (nonatomic ,strong) UILabel *timeLab;
@property (nonatomic, strong) SYLockListModel *model;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, assign) BOOL isMachineOnline;    //有这个状态通知门口机才在线
@property (nonatomic, assign) BOOL isInComingCall;
@property (nonatomic, assign) BOOL isBackClick;  //主动点击返回
@property (nonatomic, assign) BOOL isTimerOpening;  //视频倒计时是否正在计时

@property (nonatomic, strong) UIButton *routeChangeBtn;
@property (nonatomic, strong) UIImageView *callingImage;

@property (nonatomic, strong) UIButton *upButton;
@property (nonatomic, strong) UIButton *downButton;
@property (nonatomic, strong) UIButton *rightUpButton;
@property (nonatomic, strong) UIButton *rightDownButton;

@property (nonatomic, strong) UIButton *handfreeButton;
@property (nonatomic, strong) UIButton *defineButton;
@property (nonatomic, strong) UIButton *hangUpBtn;
@property (nonatomic, strong) HBLockSliderView *openLockView;

@property (nonatomic, strong) UIView *leftMainView;
@property (nonatomic, strong) UIView *rightMainView;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UILabel *neighborNameLab;
@property (nonatomic, strong) UILabel *neighborDetailLab;

@end

@implementation SYGuardMonitorViewController

- (void)dealloc{
    NSLog(@"SYGuardMonitorViewController dealloc");
//    dispatch_source_cancel(timerPopVC);
    [SYAppConfig shareInstance].isSpeaker = YES;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];   //关闭屏幕常亮
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"presentSecondVideo" object:nil];
}

- (instancetype)initWithCall:(SYLinphoneCall *)call GuardInfo:(SYLockListModel *)model InComingCall:(BOOL)isInComingCall{

    if (self == [super init]) {
        self.call = call;
        self.model = model;
        self.isInComingCall = isInComingCall;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    MSVideoSize vsize = ms_video_size_make(176,144);
//
//    if (self.model) {
//        linphone_core_set_preferred_video_size(LC, vsize);
//
//        [[LinphoneManager instance] changeVideoSize:2];
//
//        MSVideoSize myVideoSize = linphone_core_get_preferred_video_size(LC);
//        NSLog(@"长==%d,宽==%d",myVideoSize.height,myVideoSize.width);
//    }
    
    //1. 获得 MPVolumeView 实例，
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-100, -100, 100, 100)];
    
    volumeViewSlider = nil;
    //2. 遍历MPVolumeView的subViews得到MPVolumeSlider
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(linphoneCallUpdate:) name:kSYLinphoneCallUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceProximityStateDidChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popViewVC) name:SYNOTICE_Close_SYGuardMonitorViewController object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openSecondComing) name:@"openSecondComing" object:nil];
    
    [self initUI];
    [self configData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openSecondComing
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - overwrite
- (NSString *)backBtnTitle{
    return @"视频对讲";
}

- (void)backButtonClick{
    self.isBackClick = YES;
    
    if (self.model) {
        
        [[SYLinphoneManager instance] hangUpCall];
        [[SYLinphoneManager instance] resignActive];
    }
    
    [self popViewVC];
    
}

#pragma mark - private
- (void)configData{

    if ([SYAppConfig networkState] == sy_none) {
        [self showErrorWithContent:@"请检查网络" duration:1];
        return;
    }
    
    //===linphone===
    //接听视频
    
    //[SYLinphoneManager instance].isSYLinphoneReady
    if ([SYLinphoneManager instance].isSYLinphoneReady) {
     
        if (self.isInComingCall) {
            [[SYLinphoneManager instance] acceptCall:self.call Video:self.monitorView];
        }
        else {
            
            [[SYLinphoneManager instance] call:self.model.sip_number displayName:[SYLoginInfoModel shareUserInfo].userInfoModel.username transfer:NO Video:self.monitorView];
        }

        //扬声器
        [SYLinphoneManager instance].speakerEnabled = [SYAppConfig shareInstance].isSpeaker;
        
        
        //门口机呼过来没有domain_sn  解锁接口必须带domain_sn, 所以请求全部门禁列表里面，用sipnumber找对应的domain_sn
        if (!self.model.domain_sn) {

            for (SYLockListModel *model in [SYAppConfig shareInstance].myNeighborLockList) {
                if ([model.sip_number isEqualToString:self.model.sip_number]) {
                    self.model.domain_sn = model.domain_sn;
                    break;
                }
            }
            
            if (!self.model.domain_sn){
                WEAK_SELF;
                SYCommunityHttpDAO *communityHttpDAO =[[SYCommunityHttpDAO alloc] init];
                //全部门禁
                [communityHttpDAO getMyLockListWithNeigborID:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username Succeed:^(NSArray *modelArr) {
                    
                    for (SYLockListModel *model in modelArr) {
                        if ([model.sip_number isEqualToString:weakSelf.model.sip_number]) {
                            weakSelf.model.domain_sn = model.domain_sn;
                            break;
                        }
                    }
                } fail:^(NSError *error) {
                    
                }];
            }
        }
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"视频错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)initUI{

    self.monitorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width_sd, (560 / 750.0) * self.view.width_sd)];
    self.monitorView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.monitorView];
    
    self.callingImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width_sd, (560 / 750.0) * self.view.width_sd)];
    self.callingImage.image = [UIImage imageNamed:@"Group.png"];
    self.callingImage.contentMode = UIViewContentModeCenter;
    self.callingImage.backgroundColor = [UIColor lightGrayColor];
    self.callingImage.hidden = YES;
    [self.view addSubview:self.callingImage];

    self.monitorMaskView = [[UIView alloc] initWithFrame:self.monitorView.frame];
    self.monitorMaskView.backgroundColor = [UIColor blackColor];
    self.monitorMaskView.hidden = NO;
//    [self.view addSubview:self.monitorMaskView];
    
    self.timeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.monitorView.height_sd - 20, self.view.width_sd, 20)];
    self.timeLab.textAlignment = NSTextAlignmentCenter;
    self.timeLab.font = [UIFont systemFontOfSize:14];
    self.timeLab.textColor = [UIColor whiteColor];
    [self.view addSubview:self.timeLab];
    
    UILabel *neighborNameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.monitorView.bottom_sd + 40, self.view.width_sd, 20)];
    neighborNameLab.textAlignment = NSTextAlignmentCenter;
    neighborNameLab.font = [UIFont systemFontOfSize:14];
    neighborNameLab.text = self.model.lock_name;
    [self.view addSubview:neighborNameLab];
    self.neighborNameLab = neighborNameLab;
    
    UILabel *neighborDetailLab = [[UILabel alloc] initWithFrame:CGRectMake(0, neighborNameLab.bottom_sd, self.view.width_sd, 20)];
    neighborDetailLab.textAlignment = NSTextAlignmentCenter;
    neighborDetailLab.font = [UIFont systemFontOfSize:12];
    neighborDetailLab.textColor = UIColorFromRGB(0x999999);
    neighborDetailLab.text = self.model.lock_parent_name;
    [self.view addSubview:neighborDetailLab];
    self.neighborDetailLab = neighborDetailLab;

    
    UIButton *hangUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    hangUpBtn.frame = CGRectMake(0, self.view.height_sd - 114, screenWidth, 50);
    hangUpBtn.backgroundColor = UIColorFromRGB(0xD23023);
    [hangUpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [hangUpBtn setTitle:@"挂断" forState:UIControlStateNormal];
    hangUpBtn.tag = HangUpBtnTag;
    [hangUpBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hangUpBtn];
    self.hangUpBtn = hangUpBtn;
    
    
//    LinphoneCallParams *params = linphone_core_create_call_params(LC,[SYLinphoneManager instance].currentCall);
//    linphone_call_params_enable_audio(params,TRUE);
//    linphone_call_params_enable_video(params,TRUE);
//    linphone_core_enable_video_display(LC,TRUE);
//    linphone_core_enable_video(LC, TRUE, TRUE);

    
    HBLockSliderView *openLockView = [[HBLockSliderView alloc] initWithFrame:CGRectMake(10, hangUpBtn.top_sd - 80, self.view.width_sd - 76, 40) cornerRadius:0 kForegroundColor:UIColorFromRGB(0x87fca2) kBackgroundColor:UIColorFromRGB(0xd0cbec)];
    openLockView.delegate = self;
    openLockView.thumbImage = [UIImage imageNamed:@"sy_home_slideUnlock"];
    openLockView.center = CGPointMake(self.view.width_sd * 0.5f, openLockView.centerY);
    openLockView.text = @"右滑解锁";
    [self.view addSubview:openLockView];
    self.openLockView = openLockView;
    
    if ([self.monitorStatus isEqualToString:@"YES"]) {
        self.openLockView.hidden = YES;
    }else{
        self.openLockView.hidden = NO;
    }

    self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.activityView.center = CGPointMake(self.monitorView.width_sd * 0.5, self.monitorView.height_sd * 0.5);
    [self.activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self.monitorMaskView addSubview:self.activityView];
    [self.activityView startAnimating];
    
    //==========扬声器切换按钮=======
    UIButton *routeChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    routeChangeBtn.frame = CGRectMake(0, 0, 60, 44);
    routeChangeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    if (![SYAppConfig isSpeaker]) {
        [routeChangeBtn setTitle:@"扬声器" forState:UIControlStateNormal];
    }else{
        [routeChangeBtn setTitle:@"听筒" forState:UIControlStateNormal];
    }
    routeChangeBtn.tag = RouteChangeBtnTag;
    [routeChangeBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.routeChangeBtn = routeChangeBtn;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:routeChangeBtn];
    UIBarButtonItem *flexSpacerl = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    flexSpacerl.width = -15;
    self.navigationItem.rightBarButtonItems = @[flexSpacerl, backItem];
    
    /*
     分割线
     */
    UIButton *handfreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    handfreeButton.frame = CGRectMake(15, 193, 55, 35);
    handfreeButton.titleLabel.textColor = [UIColor whiteColor];
    handfreeButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [handfreeButton setTitle:@"免提" forState:UIControlStateNormal];
    handfreeButton.layer.borderColor = [UIColor whiteColor].CGColor;
    handfreeButton.layer.borderWidth = 1.0f;
    handfreeButton.tag = 5;
    [self.view addSubview:handfreeButton];
    [handfreeButton addTarget:self action:@selector(handfreeSubmit:) forControlEvents:UIControlEventTouchUpInside];
    self.handfreeButton = handfreeButton;
    
    
    UIButton *defineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    defineButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 70, 193, 55, 35);
    defineButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    defineButton.layer.borderColor = [UIColor whiteColor].CGColor;
    defineButton.layer.borderWidth = 1.0f;
    defineButton.tag = 6;
    [defineButton setTitle:@"清晰" forState:UIControlStateNormal];
    defineButton.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:defineButton];
    [defineButton addTarget:self action:@selector(handfreeSubmit:) forControlEvents:UIControlEventTouchUpInside];
    self.defineButton = defineButton;
    self.defineButton.hidden = YES;

    [self initLeftSubView];
    [self initRightSubView];
    
    self.leftMainView.hidden = YES;
    self.rightMainView.hidden = YES;
    
    self.lblTitle = [[UILabel alloc] init];
    
    if ([self.monitorStatus isEqualToString:@"YES"]) {
        self.lblTitle.text = @"管理处";
    }else if ([self.monitorStatus isEqualToString:@"Coming"]){
        self.lblTitle.text = @"视频对讲";
    }else{
        self.lblTitle.text = @"视频监控";
    }
    
    self.lblTitle.textAlignment = NSTextAlignmentCenter;
    self.lblTitle.textColor = [UIColor whiteColor];
    [self.view addSubview:self.lblTitle];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 11, 70, 50);
    [backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"sy_navigation_back"] forState:UIControlStateNormal];
    [self.view addSubview:backButton];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.monitorView.frame = CGRectMake(0, 0, self.view.width_sd, 0.65 * screenHeight);
    self.handfreeButton.frame = CGRectMake(15, self.monitorView.frame.size.height - 50, 55, 35);
    self.defineButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 70, self.monitorView.frame.size.height - 50, 55, 35);
    
    self.leftMainView.frame = CGRectMake(0, self.handfreeButton.frame.origin.y - 70, 100, 70);
    self.rightMainView.frame = CGRectMake(screenWidth - 100, self.defineButton.frame.origin.y - 70, 100, 70);
    
    self.hangUpBtn.frame = CGRectMake(0, self.view.height_sd - 60, screenWidth, 60);
    self.openLockView.frame = CGRectMake(10, self.hangUpBtn.top_sd - 80, self.view.width_sd - 176, 40);
    self.openLockView.center = CGPointMake(self.view.width_sd * 0.5f, self.openLockView.centerY);
    
    self.lblTitle.frame = CGRectMake(0, 5, screenWidth, 50);
    
    self.timeLab.frame = CGRectMake(0, self.monitorView.height_sd - 20, self.view.width_sd, 20);
    self.neighborNameLab.frame = CGRectMake(0, self.monitorView.bottom_sd + 40, self.view.width_sd, 20);
    self.neighborDetailLab.frame = CGRectMake(0, self.neighborNameLab.bottom_sd, self.view.width_sd, 20);
}

- (void)handfreeSubmit:(UIButton*)btn
{
    if (btn.tag == 5) {
        
        if (self.leftMainView.isHidden) {
            self.leftMainView.hidden = NO;
        }else{
            self.leftMainView.hidden = YES;
        }
        self.rightMainView.hidden = YES;
    }else if (btn.tag == 6){
        self.leftMainView.hidden = YES;
        
        if (self.rightMainView.isHidden) {
            self.rightMainView.hidden = NO;
        }else{
            self.rightMainView.hidden = YES;
        }
    }
}

- (void)initLeftSubView
{
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 120, 100, 70)];
    mainView.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:mainView];
    self.leftMainView = mainView;
    
    UIButton *upButton = [UIButton buttonWithType:UIButtonTypeCustom];
    upButton.frame = CGRectMake(0, 0, 100, 35);
    upButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [upButton setTitle:@"免提" forState:UIControlStateNormal];
    upButton.titleLabel.textColor = [UIColor whiteColor];
    upButton.tag = 1;
    [mainView addSubview:upButton];
    [upButton addTarget:self action:@selector(defineSubmit:) forControlEvents:UIControlEventTouchUpInside];
    //[upButton setImage:nil forState:UIControlStateNormal];
    
    upButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [upButton.imageView setSize:CGSizeMake(10, 10)];
    [upButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [upButton setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, -80)];
    self.upButton = upButton;
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, upButton.frame.origin.y + upButton.frame.size.height , mainView.frame.size.width, 1)];
    lineView.backgroundColor = [UIColor whiteColor];
    [mainView addSubview:lineView];
    
    UIButton *downButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //downButton.backgroundColor = [UIColor redColor];
    downButton.frame = CGRectMake(0, 35, 100, 35);
    downButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [downButton setTitle:@"听筒" forState:UIControlStateNormal];
    downButton.titleLabel.textColor = [UIColor whiteColor];
    downButton.tag = 2;
    [mainView addSubview:downButton];
    [downButton addTarget:self action:@selector(defineSubmit:) forControlEvents:UIControlEventTouchUpInside];
    //[downButton setImage:nil forState:UIControlStateNormal];
    
    downButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [downButton.imageView setSize:CGSizeMake(10, 10)];
    [downButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [downButton setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, -80)];
    self.downButton = downButton;
    
//    [SYAppConfig shareInstance].isSpeaker = YES;
//    [[SYLinphoneManager instance] setSpeakerEnabled:YES];

    [self.upButton setImage:[UIImage imageNamed:@"commitRight"] forState:UIControlStateNormal];
    [self.upButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.upButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -40, 0, 0)];
    
    [self.downButton setImage:nil forState:UIControlStateNormal];
    [self.downButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.downButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [self.handfreeButton setTitle:@"免提" forState:UIControlStateNormal];
}

- (void)initRightSubView
{
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(screenWidth - 100, 120, 100, 70)];
    mainView.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:mainView];
    self.rightMainView = mainView;
    
    UIButton *upButton = [UIButton buttonWithType:UIButtonTypeCustom];
    upButton.frame = CGRectMake(0, 0, 100, 35);
    upButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [upButton setTitle:@"清晰" forState:UIControlStateNormal];
    upButton.titleLabel.textColor = [UIColor whiteColor];
    upButton.tag = 3;
    [mainView addSubview:upButton];
    [upButton addTarget:self action:@selector(defineSubmit:) forControlEvents:UIControlEventTouchUpInside];
    //[upButton setImage:nil forState:UIControlStateNormal];
    
    upButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [upButton.imageView setSize:CGSizeMake(10, 10)];
    [upButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    [upButton setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 10)];
    self.rightUpButton = upButton;
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, upButton.frame.origin.y + upButton.frame.size.height , mainView.frame.size.width, 1)];
    lineView.backgroundColor = [UIColor whiteColor];
    [mainView addSubview:lineView];
    
    UIButton *downButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //downButton.backgroundColor = [UIColor redColor];
    downButton.frame = CGRectMake(0, 35, 100, 35);
    downButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [downButton setTitle:@"流畅" forState:UIControlStateNormal];
    downButton.titleLabel.textColor = [UIColor whiteColor];
    downButton.tag = 4;
    [mainView addSubview:downButton];
    [downButton addTarget:self action:@selector(defineSubmit:) forControlEvents:UIControlEventTouchUpInside];
    //[downButton setImage:nil forState:UIControlStateNormal];
    
    downButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [downButton.imageView setSize:CGSizeMake(10, 10)];
    [downButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    [downButton setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 10)];
    self.rightDownButton = downButton;
    
    [self.rightUpButton setImage:[UIImage imageNamed:@"commitRight"] forState:UIControlStateNormal];
    [self.rightUpButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.rightUpButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    
    [self.rightDownButton setImage:nil forState:UIControlStateNormal];
    [self.rightDownButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.rightDownButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    
    //[[LinphoneManager instance] changeVideoSize:0];
    [self.defineButton setTitle:@"清晰" forState:UIControlStateNormal];
}

- (void)defineSubmit:(UIButton*)btn
{
    if (btn.tag == 1) {
        
        [SYAppConfig shareInstance].isSpeaker = YES;
        [[SYLinphoneManager instance] setSpeakerEnabled:YES];
        
        //[volumeViewSlider setValue:0.0 animated:NO];

        
        [self.upButton setImage:[UIImage imageNamed:@"commitRight"] forState:UIControlStateNormal];
        [self.upButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [self.upButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -40, 0, 0)];
        
        [self.downButton setImage:nil forState:UIControlStateNormal];
        [self.downButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.downButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
        [self.handfreeButton setTitle:@"免提" forState:UIControlStateNormal];
    }
    else if (btn.tag == 2) {
        
        [SYAppConfig shareInstance].isSpeaker = NO;
        [[SYLinphoneManager instance] setSpeakerEnabled:NO];
        
        //[volumeViewSlider setValue:1.0 animated:NO];
        
        [self.upButton setImage:nil forState:UIControlStateNormal];
        [self.upButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.upButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
        
        [self.downButton setImage:[UIImage imageNamed:@"commitRight"] forState:UIControlStateNormal];
        [self.downButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [self.downButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -40, 0, 0)];
        [self.handfreeButton setTitle:@"听筒" forState:UIControlStateNormal];
    }
    else if (btn.tag == 3) {
        //清晰
        [self.rightUpButton setImage:[UIImage imageNamed:@"commitRight"] forState:UIControlStateNormal];
        [self.rightUpButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [self.rightUpButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
        
        [self.rightDownButton setImage:nil forState:UIControlStateNormal];
        [self.rightDownButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.rightDownButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        
        [[LinphoneManager instance] changeVideoSize:0];
        [self.defineButton setTitle:@"清晰" forState:UIControlStateNormal];
    }
    else if (btn.tag == 4) {
        
        //流畅
        [self.rightUpButton setImage:nil forState:UIControlStateNormal];
        [self.rightUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.rightUpButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        
        [self.rightDownButton setImage:[UIImage imageNamed:@"commitRight"] forState:UIControlStateNormal];
        [self.rightDownButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [self.rightDownButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
        
        [[LinphoneManager instance] changeVideoSize:1];
        [self.defineButton setTitle:@"流畅" forState:UIControlStateNormal];
        
        MSVideoSize myVideoSize = linphone_core_get_preferred_video_size(LC);
    }
    
    self.rightMainView.hidden = YES;
    self.leftMainView.hidden = YES;
}

- (void)timerOpen{
    
    if (self.isTimerOpening) {
        return;
    }
    
    WEAK_SELF;
    __block int timeout = 30; //倒计时时间

    if ([self.monitorStatus isEqualToString:@"YES"] || [self.monitorStatus isEqualToString:@"Coming"]) {
        timeout = 120;  //门口机监控的话~~2分钟才挂断
    }else{
        timeout = 30;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer,dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(timer, ^{
        if(timeout <= 0){
            self.isTimerOpening = NO;
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //倒计时结束
                weakSelf.timeLab.text = @"00:00";
            });
        }else{
            int hours = timeout / 3600;
            int minutes = (timeout - hours*3600) / 60;
            int seconds = timeout % 60;
//            NSString *strTime = [NSString stringWithFormat:@"%d时%d分%.2d秒后重新获取验证码",hours,minutes, seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.timeLab.text = [NSString stringWithFormat:@"%d:%.2d", minutes, seconds];
            });
            timeout--;
        }
    });
    dispatch_resume(timer);
    
    self.monitorMaskView.hidden = YES;
    [SYAppConfig shareInstance].isPlayingSipVideo = YES;

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];   //屏幕常亮
    self.isTimerOpening = YES;
}

- (void)popViewVC{
    [self dismissViewControllerAnimated:YES completion:nil];
   // [FrameManager popViewControllerAnimated:YES];
}


#pragma mark - event
- (void)btnClick:(UIButton *)btn{

    if (btn.tag == HangUpBtnTag) {
        [self backButtonClick];
    }
    else if (btn.tag == RouteChangeBtnTag){
        [SYAppConfig shareInstance].isSpeaker = ![SYAppConfig isSpeaker];
        [SYLinphoneManager instance].speakerEnabled = [SYAppConfig shareInstance].isSpeaker;
        if (![SYAppConfig isSpeaker]) {
            [btn setTitle:@"扬声器" forState:UIControlStateNormal];
        }else{
            [btn setTitle:@"听筒" forState:UIControlStateNormal];
        }
    }
    else if (btn.tag == 7){
        /*
         切换视频
         */
        bool_t videoSupport = linphone_core_video_supported(LC);
        LinphoneCallParams *params = linphone_core_create_call_params(LC,[SYLinphoneManager instance].currentCall);
        
        if (videoSupport) {
            if ([btn.titleLabel.text isEqualToString:@"切换视频"]) {
                
                linphone_call_params_enable_video(params,TRUE);
                //linphone_core_enable_video_display(LC,TRUE);
                linphone_core_enable_video(LC, TRUE, TRUE);
                
                __block SYGuardMonitorViewController *weakSelf = self;
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
                
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                    weakSelf.callingImage.hidden = YES;
                    [btn setTitle:@"切换语音" forState:UIControlStateNormal];
                });
            }else{
                
                linphone_call_params_enable_video(params,FALSE);
                //linphone_core_enable_video_display(LC,FALSE);
                linphone_core_enable_video(LC, FALSE, FALSE);
                
                __block SYGuardMonitorViewController *weakSelf = self;
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
                
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                    weakSelf.callingImage.hidden = NO;
                    [btn setTitle:@"切换视频" forState:UIControlStateNormal];
                });
            }
            
            if ([SYLinphoneManager instance].currentCall) {
                linphone_core_update_call(LC, [SYLinphoneManager instance].currentCall, params);
            }
        }
    }
}


#pragma mark - notifi
- (void)linphoneCallUpdate:(NSNotification *)notif{
    SYLinphoneCallState state = [[notif.userInfo objectForKey:@"state"] intValue];
    if (state == SYLinphoneCallStreamsRunning) {
        if (self.isInComingCall) {
            [self.activityView stopAnimating];
            [self timerOpen];
        }
        else{
            if (self.isMachineOnline) {
                [self.activityView stopAnimating];
                [self timerOpen];
            }
            else{
                NSLog(@"==============门口机不在线============");
//               __block BOOL isStar = NO;
//                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
//                timerPopVC = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
//                dispatch_source_set_timer(timerPopVC,dispatch_walltime(NULL, 0), 3 * NSEC_PER_SEC, 0); //每秒执行
//                dispatch_source_set_event_handler(timerPopVC, ^{
//   
//                    if (!isStar) {
//                        isStar = YES;
//                        return ;
//                    }
//                
//                    NSLog(@"====================");
//                    dispatch_source_cancel(timerPopVC);
//                    [[SYLinphoneManager instance] popPushSYCall:nil];
//                    self.isBackClick = YES;
//
//                 
//                });
//                dispatch_resume(timerPopVC);

//                [[SYLinphoneManager instance] popPushSYCall:nil];
//                self.isBackClick = YES;
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self popViewVC];
//                });
//                [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_ShowReflashingLinphone object:nil];
            }
        }
    }
    else if (state == SYLinphoneCallOutgoingInit){
        [self.activityView startAnimating];
    }
    else if (state == SYLinphoneCallReleased){
        //用户没有主动退出页面，则视频通话结束后，自动退出当前页面
        if (!self.isBackClick) {
            [self popViewVC];
        }
    }
    else if (state == SYLinphoneCallOutgoingEarlyMedia || state == SYLinphoneCallIncomingEarlyMedia){
        self.isMachineOnline = YES;
        //红外线
//        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    }
    else if (state == SYLinphoneCallPaused){
        [self.activityView stopAnimating];
    }
}

//红外线
- (void)deviceProximityStateDidChange:(NSNotification *)noti{
    
    //黑屏
    if ([[UIDevice currentDevice] proximityState] == YES){
        [SYLinphoneManager instance].speakerEnabled = NO;
    }
    else{
        [SYLinphoneManager instance].speakerEnabled = [SYAppConfig isSpeaker];
    }
}


#pragma mark - HBLockSliderView delegate
- (void)sliderEndValueChanged:(HBLockSliderView *)slider{
    
    if (slider.value < 0.5) {
        return;
    }
    
    //[self showMessageWithContent:@"已发送解锁请求" duration:1];
    
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
    long long dTime = [[NSNumber numberWithDouble:time] longLongValue]; // 将double转为long long型
    [communityHttpDAO remoteUnlockWithUserName:[SYLoginInfoModel shareUserInfo].userInfoModel.username DomainSN:self.model.domain_sn WithType:@"1" WithTime:dTime Succeed:^{

    } fail:^(NSError *error) {

    }];
    
    //发送sip消息开锁
    NSString *username = [SYLoginInfoModel shareUserInfo].userInfoModel.username;
    NSString *domainSN = self.model.domain_sn ? self.model.domain_sn : @"000";
    NSString *message = [NSString stringWithFormat:@"{\"ver\":\"1.0\",\"typ\":\"req\",\"cmd\":\"0610\",\"tgt\":\"%@\",\"cnt\":{\"username\":\"%@\",\"type\":\"%@\",\"time\":\"%@\"}}", domainSN, username,  @"1", @(dTime)];

    if (![[SYLinphoneManager instance] sendMessage:message withExterlBodyUrl:nil withInternalURL:nil Address:self.model.sip_number]) {

    }
}
@end
