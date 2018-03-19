//
//  SYGuardMontorView.m
//  YLB
//
//  Created by sayee on 17/4/5.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYGuardMontorView.h"
#import "HBLockSliderView.h"
#import "SYCommunityHttpDAO.h"
#import "SYGuardMonitorViewController.h"
#import "SYPasswordOpenGuardViewController.h"

@interface SYGuardMontorView ()<HBLockSliderDelegate>
@property (nonatomic, retain) UIView *bgView;
@property (nonatomic, retain) UIView *mainView;
@property (nonatomic, retain) SYLockListModel *model;
@end

@implementation SYGuardMontorView

- (instancetype)initWithFrame:(CGRect)frame WithLockListModel:(SYLockListModel *)model{

    if (self = [super initWithFrame:frame]) {
        self.model = model;
        [self initUI];
    }
    return self;
}

-(void)dealloc{
    NSLog(@"====SYGuardMontorView  dealloc===");
}


#pragma mark - private
- (void)initUI{

    self.backgroundColor = [UIColor clearColor];
    
    self.bgView = [[UIView alloc] initWithFrame:self.frame];
    self.bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self addSubview:self.bgView];
    
    self.mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width_sd - 20, (self.width_sd - 20) * (630.0 / 702) + 20)];
    self.mainView.backgroundColor = [UIColor whiteColor];
    self.mainView.center = CGPointMake(self.width_sd * 0.5f, self.height_sd * 0.5f);
    [self addSubview:self.mainView];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.mainView.width_sd - 80, 50)];
    titleLab.text = @"此列操作涉及到打开单元门观看监控等功能，请谨慎操作";
    titleLab.numberOfLines = 0;
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = [UIFont systemFontOfSize:12];
    [self.mainView addSubview:titleLab];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, titleLab.bottom_sd, self.mainView.width_sd - 20, 1)];
    line.backgroundColor = UIColorFromRGB(0x999999);
    [self.mainView addSubview:line];
    
    UIButton *monitorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [monitorBtn setTitle:@"门口监控" forState:UIControlStateNormal];
    monitorBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    monitorBtn.tag = monitorTag;
    [monitorBtn setTitleColor:UIColorFromRGB(0xd23023) forState:UIControlStateNormal];
    monitorBtn.frame = CGRectMake(0, line.bottom_sd, self.mainView.width_sd, 50);
    [monitorBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainView addSubview:monitorBtn];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(10, monitorBtn.bottom_sd, self.mainView.width_sd - 20, 1)];
    line.backgroundColor = UIColorFromRGB(0x999999);
    [self.mainView addSubview:line];
    
    UIButton *passwordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [passwordBtn setTitle:@"密码开锁" forState:UIControlStateNormal];
    passwordBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    passwordBtn.tag = openLockTag;
    [passwordBtn setTitleColor:UIColorFromRGB(0xd23023) forState:UIControlStateNormal];
    passwordBtn.frame = CGRectMake(0, line.bottom_sd, self.mainView.width_sd, 50);
    [passwordBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainView addSubview:passwordBtn];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(10, passwordBtn.bottom_sd, self.mainView.width_sd - 20, 1)];
    line.backgroundColor = UIColorFromRGB(0x999999);
    [self.mainView addSubview:line];
    
    HBLockSliderView *openLockView = [[HBLockSliderView alloc] initWithFrame:CGRectMake(10, line.bottom_sd + 20, self.mainView.width_sd - 20, 40)];
    openLockView.delegate = self;
    openLockView.thumbImage = [UIImage imageNamed:@"sy_home_slideUnlock"];
    openLockView.text = @"右滑解锁";
    [self.mainView addSubview:openLockView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10, openLockView.bottom_sd + 20, openLockView.width, openLockView.height);
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    backBtn.tag = backTag;
    backBtn.backgroundColor = UIColorFromRGB(0xd23023);
    [backBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainView addSubview:backBtn];
}



#pragma mark - event
- (void)btnClick:(UIButton *)btn{
    
    if (btn.tag == monitorTag) {
        SYGuardMonitorViewController *subAccountInfoViewController = [[SYGuardMonitorViewController alloc] initWithCall:nil GuardInfo:self.model InComingCall:NO];
        [FrameManager pushViewController:subAccountInfoViewController animated:YES];
    }else if (btn.tag == openLockTag) {
        SYPasswordOpenGuardViewController *vc = [[SYPasswordOpenGuardViewController alloc] initWithGuardInfo:self.model];
        [FrameManager pushViewController:vc animated:YES];
    }
    [self removeFromSuperview];
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
    WEAK_SELF;
    [communityHttpDAO remoteUnlockWithUserName:[SYLoginInfoModel shareUserInfo].userInfoModel.username DomainSN:self.model.domain_sn WithType:@"1" WithTime:dTime Succeed:^{
//        [weakSelf showSuccessWithContent:@"开锁成功" duration:1];
    } fail:^(NSError *error) {
        [weakSelf showErrorWithContent:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]] duration:1];
    }];
    
    //发送sip消息开锁
    NSString *username = [SYLoginInfoModel shareUserInfo].userInfoModel.username;
    NSString *domainSN = self.model.domain_sn ? self.model.domain_sn : @"000";
    NSString *message = [NSString stringWithFormat:@"{\"ver\":\"1.0\",\"typ\":\"req\",\"cmd\":\"0610\",\"tgt\":\"%@\",\"cnt\":{\"username\":\"%@\",\"type\":\"%@\",\"time\":\"%@\"}}", domainSN, username,  @"1", @(dTime)];
    
    if (![[SYLinphoneManager instance] sendMessage:message withExterlBodyUrl:nil withInternalURL:nil Address:self.model.sip_number]) {
        [self showErrorWithContent:@"开锁失败" duration:1];
    }
}

@end
