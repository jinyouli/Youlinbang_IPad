//
//  SYInComingCallViewController.m
//  YLB
//
//  Created by sayee on 17/4/12.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYInComingCallViewController.h"
#import "SYGuardMonitorViewController.h"
#import <AVFoundation/AVFoundation.h>

typedef enum : NSUInteger {
    hangUPCallBtnTag,
    acceptCallBtnTag
} BtnClickTag;

@interface SYInComingCallViewController ()
@property (nonatomic, retain) UILabel *displayNameLab;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, assign) SYLinphoneCall *call;
@property (nonatomic, assign) SystemSoundID sound;
@property (nonatomic, strong) UIButton *hangUpBtn;
@property (nonatomic, strong) UIButton *acceptBtn;
@end

@implementation SYInComingCallViewController

- (instancetype)initWithDisplayName:(NSString *)displayName WithCall:(SYLinphoneCall *)call{
    if (self = [super init]) {
        self.displayName = displayName;
        self.call = call;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOut:) name:SYNOTICE_OTHERUSERLOGIN object:nil];
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //播放铃声
    if ([Common playRing]) {
        [self playBeep];
    }
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"openSecondComing" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([Common playRing]) {
        [self stopAlertSoundWithSoundID:_sound];
    }
}

- (void)playBeep
{
    //使用自定义铃声;
    _sound = kSystemSoundID_Vibrate;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ring"ofType:@"caf"];
    
    if (path) {
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&_sound);
        if (error != kAudioServicesNoError) {
            _sound = 0;
        }
    }
    
    AudioServicesPlaySystemSound(_sound);//播放声音
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);//静音模式下震动
}

- (void)stopAlertSoundWithSoundID:(SystemSoundID)sound {
    AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate);
    AudioServicesDisposeSystemSoundID(sound);
    AudioServicesRemoveSystemSoundCompletion(sound);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - private
- (void)initUI{

    self.view.backgroundColor = [UIColor blackColor];
    
    self.displayNameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.width_sd, 30)];
    self.displayNameLab.font = [UIFont systemFontOfSize:16];
    self.displayNameLab.text = self.displayName;
    self.displayNameLab.textColor = [UIColor whiteColor];
    self.displayNameLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.displayNameLab];
    
    UIButton *hangUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [hangUpBtn setTitle:@"挂断" forState:UIControlStateNormal];
    hangUpBtn.tag = hangUPCallBtnTag;
    hangUpBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    hangUpBtn.frame = CGRectMake(40, self.view.height_sd - 64 - 110, 70, 70);
    hangUpBtn.layer.cornerRadius = hangUpBtn.height_sd * 0.5;
    hangUpBtn.layer.masksToBounds = YES;
    [hangUpBtn setBackgroundColor:UIColorFromRGB(0xd23023)];
    [hangUpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [hangUpBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hangUpBtn];
    self.hangUpBtn = hangUpBtn;

    
    UIButton *acceptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [acceptBtn setTitle:@"接听" forState:UIControlStateNormal];
    acceptBtn.tag = acceptCallBtnTag;
    acceptBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    acceptBtn.frame = CGRectMake(self.view.width_sd - 110, hangUpBtn.top_sd, 70, 70);
    acceptBtn.layer.cornerRadius = acceptBtn.height_sd * 0.5;
    acceptBtn.layer.masksToBounds = YES;
    [acceptBtn setBackgroundColor:UIColorFromRGB(0x00b300)];
    [acceptBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [acceptBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:acceptBtn];
    self.acceptBtn = acceptBtn;
}

- (void)viewWillLayoutSubviews
{
    self.displayNameLab.frame = CGRectMake(0, 100, self.view.width_sd, 30);
    self.hangUpBtn.frame = CGRectMake(40, self.view.height_sd - 64 - 110, 70, 70);
    self.acceptBtn.frame = CGRectMake(self.view.width_sd - 110, self.hangUpBtn.top_sd, 70, 70);
}

#pragma mark - event
- (void)btnClick:(UIButton *)btn{

    if (btn.tag == hangUPCallBtnTag) {
        [[SYLinphoneManager instance] hangUpCall];
        [self dismissViewControllerAnimated:YES completion:nil];
        
//        [[FrameManager rootViewController] dismissViewControllerAnimated:YES completion:^{
//            
//        }];
    }else  if (btn.tag == acceptCallBtnTag) {
        if (!self.call) {
            [self showErrorWithContent:@"call为空，通话失败" duration:1];
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }

        SYLockListModel *lockListModel = [[SYLockListModel alloc] init];
        lockListModel.lock_parent_name = self.displayName;
        lockListModel.sip_number = self.sipNumber;
        SYGuardMonitorViewController *vc = [[SYGuardMonitorViewController alloc] initWithCall:self.call GuardInfo:lockListModel InComingCall:YES];
        vc.monitorStatus = @"Coming";
        
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openComingCall" object:vc];
    }
}


#pragma mark - noti
//其他设备登录了账号
- (void)loginOut:(NSNotification *)noti{
    [[SYLinphoneManager instance] hangUpCall];
    [[FrameManager rootViewController] dismissViewControllerAnimated:NO completion:nil];
}
@end
