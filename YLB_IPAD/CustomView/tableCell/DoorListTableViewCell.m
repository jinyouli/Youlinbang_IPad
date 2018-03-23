//
//  DoorListTableViewCell.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/8/5.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "DoorListTableViewCell.h"

@interface DoorListTableViewCell ()
@property (nonatomic,strong) UIImageView *headImageView;
@property (nonatomic,strong) UILabel *lblNickName;
@property (nonatomic,strong) UIView *lineView;

@property (nonatomic,strong) UIView *MoreFunctionView;
@property (nonatomic,strong) UIButton *btnVideo;
@property (nonatomic,strong) UIButton *btnPassword;
@property (nonatomic,strong) UIButton *btnOpenLock;
@property (nonatomic,strong) UIButton *btnCancel;

@property (nonatomic,strong) SYLockListModel *model;
@end

@implementation DoorListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.backgroundColor = [UIColor whiteColor];
    
    self.MoreFunctionView = [[UIView alloc] init];
    
    self.btnVideo = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnVideo setTitle:@"视频监控" forState:UIControlStateNormal];
    [self.btnVideo addTarget:self action:@selector(showVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.btnVideo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnVideo setBackgroundColor:[UIColor colorWithRed:109.0f/255.0f green:223.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    [self.MoreFunctionView addSubview:self.btnVideo];
    
    self.btnPassword = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnPassword setTitle:@"密码开锁" forState:UIControlStateNormal];
    [self.btnPassword addTarget:self action:@selector(showPassword) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPassword setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnPassword setBackgroundColor:[UIColor colorWithRed:208.0f/255.0f green:148.0f/255.0f blue:238.0f/255.0f alpha:1.0f]];
    [self.MoreFunctionView addSubview:self.btnPassword];
    
    self.btnOpenLock = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnOpenLock setTitle:@"点击开锁" forState:UIControlStateNormal];
    [self.btnOpenLock addTarget:self action:@selector(showOpenLock) forControlEvents:UIControlEventTouchUpInside];
    [self.btnOpenLock setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnOpenLock setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:225.0f/255.0f blue:125.0f/255.0f alpha:1.0f]];
    [self.MoreFunctionView addSubview:self.btnOpenLock];
    
    self.btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [self.btnCancel addTarget:self action:@selector(showCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnCancel setBackgroundColor:[UIColor colorWithRed:233.0f/255.0f green:148.0f/255.0f blue:169.0f/255.0f alpha:1.0f]];
    [self.MoreFunctionView addSubview:self.btnCancel];
    
    
    
    UIImageView *headImageView = [[UIImageView alloc] init];
    headImageView.image = [UIImage imageNamed:@"sy_navigation_normal_header"];
    headImageView.backgroundColor = [UIColor clearColor];
    headImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:headImageView];
    self.headImageView = headImageView;
    
    UILabel *lblNickName = [[UILabel alloc] init];
    lblNickName.textColor = [UIColor darkGrayColor];
    [self addSubview:lblNickName];
    self.lblNickName = lblNickName;
    
    UIButton *btnCallManager = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCallManager setTitle:@"添加" forState:UIControlStateNormal];
    [btnCallManager setFont:[UIFont systemFontOfSize:15.0f]];
    self.btnCallManager = btnCallManager;
    self.btnCallManager.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.btnCallManager.layer.borderWidth = 0.5f;
    [self.btnCallManager setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.btnCallManager.hidden = YES;
    [self addSubview:btnCallManager];
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = UIColorFromRGB(0xebebeb);
    [self addSubview:self.lineView];
    
    UIButton *btnMoreFunction = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMoreFunction setTitle:@"" forState:UIControlStateNormal];
    [btnMoreFunction addTarget:self action:@selector(showMoreFunction) forControlEvents:UIControlEventTouchUpInside];
    self.btnMoreFunction = btnMoreFunction;
    self.btnMoreFunction.hidden = YES;
    [self addSubview:btnMoreFunction];
    
    [self addSubview:self.MoreFunctionView];
}

#pragma mark - public
- (void)updateFrames:(SYLockListModel *)model{
    
    if (!model) {
        return;
    }
    
    self.model = model;
    self.lblNickName.text = model.lock_parent_name;
}

- (void)showMoreFunction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeFunction" object:nil];
    
    [UIView animateWithDuration:0.5f animations:^{
        
        self.MoreFunctionView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    } completion:nil];
}

- (void)showVideo
{
    //视频监控
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openVideo" object:self.model];
}

- (void)showPassword
{
    //密码开锁
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openPassword" object:self.model];
}

#pragma mark - 点击开锁
- (void)showOpenLock
{
    //[Common showAlert:@"已发送解锁请求"];
    
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
    long long dTime = [[NSNumber numberWithDouble:time] longLongValue]; // 将double转为long long型
    [communityHttpDAO remoteUnlockWithUserName:[SYLoginInfoModel shareUserInfo].userInfoModel.username DomainSN:self.model.domain_sn WithType:@"1" WithTime:dTime Succeed:^{
        
        [Common addAlertWithTitle:@"开锁成功"];
    } fail:^(NSError *error) {
        [Common addAlertWithTitle:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
    }];
    
    //发送sip消息开锁
    NSString *username = [SYLoginInfoModel shareUserInfo].userInfoModel.username;
    NSString *domainSN = self.model.domain_sn ? self.model.domain_sn : @"000";
    NSString *message = [NSString stringWithFormat:@"{\"ver\":\"1.0\",\"typ\":\"req\",\"cmd\":\"0610\",\"tgt\":\"%@\",\"cnt\":{\"username\":\"%@\",\"type\":\"%@\",\"time\":\"%@\"}}", domainSN, username,  @"1", @(dTime)];
    
    if (![[SYLinphoneManager instance] sendMessage:message withExterlBodyUrl:nil withInternalURL:nil Address:self.model.sip_number]) {
        [Common showAlert:@"开锁失败"];
    }
}

- (void)showCancel
{
    [UIView animateWithDuration:0.5f animations:^{
        
        self.MoreFunctionView.frame = CGRectMake(self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
    } completion:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.headImageView.frame = CGRectMake(20, 10, 40, 40);
    
    self.lblNickName.frame = CGRectMake(CGRectGetMaxX(self.headImageView.frame) + 15, 7, self.frame.size.width - CGRectGetMaxX(self.headImageView.frame) - 40, 50);
    self.btnCallManager.frame = CGRectMake(self.frame.size.width - 60, 15, 45, 35);
    self.lineView.frame = CGRectMake(60, self.bounds.size.height, self.bounds.size.width - 60, 1);
    
    self.MoreFunctionView.frame = CGRectMake(self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
    self.btnVideo.frame = CGRectMake(0, 0, self.bounds.size.width * 0.25, self.bounds.size.height);
    self.btnPassword.frame = CGRectMake(self.bounds.size.width * 0.25, 0, self.bounds.size.width * 0.25, self.bounds.size.height);
    self.btnOpenLock.frame = CGRectMake(self.bounds.size.width * 0.5, 0, self.bounds.size.width * 0.25, self.bounds.size.height);
    self.btnCancel.frame = CGRectMake(self.bounds.size.width * 0.75, 0, self.bounds.size.width * 0.25, self.bounds.size.height);
    
    self.btnMoreFunction.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);

}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
