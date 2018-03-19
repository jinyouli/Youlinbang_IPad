//
//  SYHomeGuardCollectionViewCell.m
//  YLB
//
//  Created by sayee on 17/3/31.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYHomeGuardCollectionViewCell.h"
#import "SYLockListModel.h"

@interface SYHomeGuardCollectionViewCell ()<HBLockSliderDelegate>

@property (nonatomic, retain) UIImageView *iconImgView; //门禁图片
@property (nonatomic, retain) UIButton *addGuardBtn;    //添加门禁
@property (nonatomic, retain) UIImageView *addGuardImgView; //添加门禁图片
@property (nonatomic, retain) SYLockListModel *model;

@property (nonatomic, retain) UILabel *guardAddLab;    //添加门锁门
@property (nonatomic, retain) UIImageView *addGuardIconImgView; //添加门禁图片

@property (nonatomic, retain) UIButton *monitorBtn;    //视频监控
@property (nonatomic, retain) UIButton *passwordBtn;    //密码开锁
@property (nonatomic, strong) HBLockSliderView *openLockView;

@property (nonatomic, strong) UIView *lockChangeView;
@property (nonatomic, retain) UIButton *lockChangeCancel;
@end


@implementation SYHomeGuardCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        [self configUI];
    }
    return self;
}

#pragma mark - private
- (void)configUI{

    self.iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, 33, 33)];
    self.iconImgView.image = [UIImage imageNamed:@"Oval 151"];
    self.iconImgView.center = CGPointMake(self.width_sd * 0.5, self.iconImgView.centerY);
    self.iconImgView.layer.cornerRadius = 16.5;
    self.iconImgView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.iconImgView];
    
    UIImage *img = [UIImage imageNamed:@"sy_home_door_guard_add"];
    self.addGuardImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.width_sd - img.size.width, 0, img.size.width, img.size.height)];
    self.addGuardImgView.image = img;
    [self.contentView addSubview:self.addGuardImgView];
    
    self.addGuardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addGuardBtn setBackgroundColor:[UIColor clearColor]];
    self.addGuardBtn.frame = CGRectMake(self.width_sd - 30, 0, 30, 30);
    [self.addGuardBtn addTarget:self action:@selector(guardBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.addGuardBtn];
    
    self.guardNameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.iconImgView.bottom_sd + 5, self.width_sd, 20)];
    self.guardNameLab.textAlignment = NSTextAlignmentCenter;
    self.guardNameLab.font = [UIFont systemFontOfSize:15.0];
    self.guardNameLab.center = CGPointMake(self.iconImgView.centerX, self.guardNameLab.centerY);
    [self.guardNameLab setTintColor:[UIColor darkGrayColor]];
    [self.contentView addSubview:self.guardNameLab];
    
    UIColor *backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:175.0f/255.0f blue:5.0f/255.0f alpha:1.0f];
    self.openLockView = [[HBLockSliderView alloc] initWithFrame:CGRectMake(10, self.height_sd * 0.5, self.width_sd - 20, 40) cornerRadius:20 kForegroundColor:backgroundColor kBackgroundColor:backgroundColor];

    self.openLockView.delegate = self;
    self.openLockView.thumbImage = [UIImage imageNamed:@"sy_home_slideUnlock"];
    self.openLockView.text = @"右滑解锁";
    [self.contentView addSubview:self.openLockView];
    
    self.monitorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.monitorBtn setTitle:@"视频监控" forState:UIControlStateNormal];
    self.monitorBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    self.monitorBtn.tag = monitorTag;
    [self.monitorBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.monitorBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.monitorBtn];
    
    
    self.passwordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.passwordBtn setTitle:@"密码开锁" forState:UIControlStateNormal];
    self.passwordBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    self.passwordBtn.tag = openLockTag;
    [self.passwordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.passwordBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.passwordBtn];
    
    //没有门锁时候
    img = [UIImage imageNamed:@"Slice 27a"];
    self.addGuardIconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.addGuardIconImgView.image = img;
    self.addGuardIconImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.addGuardIconImgView];

    self.guardAddLab = [[UILabel alloc] initWithFrame:CGRectMake(self.addGuardIconImgView.right_sd, 0, self.width_sd - self.addGuardIconImgView.right_sd, 30)];
    self.guardAddLab.text = @"添加快捷门锁";
    self.guardAddLab.textAlignment = NSTextAlignmentCenter;
    self.guardAddLab.textColor = [UIColor darkGrayColor];
    self.guardAddLab.font = [UIFont systemFontOfSize:15.0];
    self.guardAddLab.center = CGPointMake(self.guardAddLab.centerX, self.addGuardIconImgView.centerY);
    [self.contentView addSubview:self.guardAddLab];
    
    //修改门锁
    self.lockChangeView = [[UIView alloc] init];
    self.lockChangeView.backgroundColor = [UIColor whiteColor];
    
    self.lockDeleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.lockDeleteBtn setImage:[UIImage imageNamed:@"Oval 23"] forState:UIControlStateNormal];
    self.lockDeleteBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.lockChangeView addSubview:self.lockDeleteBtn];
    
    self.lockChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.lockChangeBtn setImage:[UIImage imageNamed:@"Oval 22"] forState:UIControlStateNormal];
    self.lockChangeBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.lockChangeView addSubview:self.lockChangeBtn];
    
    self.lockChangeCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.lockChangeCancel setImage:[UIImage imageNamed:@"Slice 24"] forState:UIControlStateNormal];
    self.lockChangeCancel.tag = lockCancel;
    self.lockChangeCancel.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.lockChangeCancel addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.lockChangeView addSubview:self.lockChangeCancel];
    self.lockChangeView.hidden = YES;
    
    [self.contentView addSubview:self.lockChangeView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGuard) name:SYNOTICE_REFRESH_GUARD object:nil];
}

- (void)refreshGuard
{
    self.lockChangeView.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.iconImgView.frame = CGRectMake(10, 10, 33, 33);
    
    UIImage *img = [UIImage imageNamed:@"sy_home_door_guard_add"];
    self.addGuardImgView.frame = CGRectMake(self.width_sd - img.size.width - 12, 5, img.size.width + 10, img.size.height + 10);
    self.addGuardBtn.frame = CGRectMake(self.width_sd - 30, 0, 30, 30);
    self.guardNameLab.frame = CGRectMake(0, 15, self.width_sd, 20);

    self.openLockView.frame = CGRectMake(15, self.height_sd * 0.5 - 15, self.width_sd - 30, 40);
    
    self.monitorBtn.frame = CGRectMake(5, self.height_sd - 50, 100, 50);
    self.passwordBtn.frame = CGRectMake(self.width_sd - 115, self.height_sd - 50, 100, 50);
    
    self.addGuardIconImgView.frame = CGRectMake(0, 0, 30, 30);
    self.addGuardIconImgView.center = CGPointMake(self.width_sd * 0.5f - 70, self.height_sd * 0.5f);
    
    self.guardAddLab.frame = CGRectMake(self.addGuardIconImgView.right_sd, 0, 120, 30);
    self.guardAddLab.center = CGPointMake(self.guardAddLab.centerX, self.addGuardIconImgView.centerY);
    
    self.lockChangeView.frame = CGRectMake(self.width_sd - 150, 0, 140, 50);
    self.lockDeleteBtn.frame = CGRectMake(10, 5, 40, 40);
    self.lockChangeBtn.frame = CGRectMake(60, 5, 40, 40);
    self.lockChangeCancel.frame = CGRectMake(self.lockChangeView.frame.size.width - 25, 5, 20, 40);
}

#pragma mark - event
- (void)btnClick:(UIButton *)btn{
    
    if (btn.tag == monitorTag) {
        //视频监控
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openVideo" object:self.model];
    }else if (btn.tag == openLockTag) {
        //密码开锁
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openPassword" object:self.model];
    }else if (btn.tag == lockCancel) {
        //取消锁
        self.lockChangeView.hidden = YES;
    }
}

#pragma mark - event
- (void)guardBtnClick:(UIButton *)btn{
    
    self.lockChangeView.hidden = NO;
//    if ([self.delegate respondsToSelector:@selector(guardAddToLocal:LockListModel:)]) {
//        [self.delegate guardAddToLocal:self.indexPath LockListModel:self.model];
//    }
}


#pragma mark - public
- (void)updateguardName:(SYLockListModel *)model{
    self.model = model;
    self.guardNameLab.text = model ? model.lock_name : @"添加门锁";
    
    if (model){
    
        self.iconImgView.hidden = NO;
        self.addGuardImgView.hidden = NO;
        self.addGuardBtn.hidden = NO;
        self.guardNameLab.hidden = NO;
        self.openLockView.hidden = NO;
        self.monitorBtn.hidden = NO;
        self.passwordBtn.hidden = NO;
        
        self.addGuardIconImgView.hidden = YES;
        self.guardAddLab.hidden = YES;
    }
    else{
        
        self.iconImgView.hidden = YES;
        self.addGuardImgView.hidden = YES;
        self.addGuardBtn.hidden = YES;
        self.guardNameLab.hidden = YES;
        self.openLockView.hidden = YES;
        self.monitorBtn.hidden = YES;
        self.passwordBtn.hidden = YES;
        
        self.addGuardIconImgView.hidden = NO;
        self.guardAddLab.hidden = NO;
    }
}

#pragma mark - HBLockSliderView delegate
- (void)sliderEndValueChanged:(HBLockSliderView *)slider{
    
    if (slider.value < 0.5) {
        return;
    }
    
    //[Common showAlert:@"已发送解锁请求"];
    
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
    long long dTime = [[NSNumber numberWithDouble:time] longLongValue]; // 将double转为long long型
    [communityHttpDAO remoteUnlockWithUserName:[SYLoginInfoModel shareUserInfo].userInfoModel.username DomainSN:self.model.domain_sn WithType:@"1" WithTime:dTime Succeed:^{
        
        [Common showAlert:@"开锁成功"];
    } fail:^(NSError *error) {
        [Common showAlert:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
    }];
    
    //发送sip消息开锁
    NSString *username = [SYLoginInfoModel shareUserInfo].userInfoModel.username;
    NSString *domainSN = self.model.domain_sn ? self.model.domain_sn : @"000";
    NSString *message = [NSString stringWithFormat:@"{\"ver\":\"1.0\",\"typ\":\"req\",\"cmd\":\"0610\",\"tgt\":\"%@\",\"cnt\":{\"username\":\"%@\",\"type\":\"%@\",\"time\":\"%@\"}}", domainSN, username,  @"1", @(dTime)];
    
    if (![[SYLinphoneManager instance] sendMessage:message withExterlBodyUrl:nil withInternalURL:nil Address:self.model.sip_number]) {
        [Common showAlert:@"开锁失败"];
    }
}



@end
