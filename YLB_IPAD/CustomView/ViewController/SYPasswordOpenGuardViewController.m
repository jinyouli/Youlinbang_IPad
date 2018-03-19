//
//  SYPasswordOpenGuardViewController.m
//  YLB
//
//  Created by YAYA on 2017/4/9.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYPasswordOpenGuardViewController.h"
#import "SYCustomScrollView.h"
#import "SYLoginHttpDAO.h"
#import <MessageUI/MessageUI.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"

typedef enum : NSUInteger {
    QQBtnTag,
    WeChatBtnTag,
    MessageBtnTag,
} BtnTag;

@interface SYPasswordOpenGuardViewController ()<MFMessageComposeViewControllerDelegate>
@property (nonatomic, retain) UILabel *pwLab;
@property (nonatomic, retain) SYRandomPWModel *pwModel;
@property (nonatomic, retain) SYCustomScrollView *scrollView;
@property (nonatomic, retain) UILabel *timeLab;
@property (nonatomic, retain) UILabel *noticeLab;
@property (nonatomic, strong) UIView *underLineView;
@property (nonatomic, strong) UIView *lblTitle;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIView *shareView;
@property (nonatomic, strong) UILabel *shareLab;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIButton *qqBtn;
@property (nonatomic, strong) UILabel *qqLab;

@property (nonatomic, strong) UIButton *wechatBtn;
@property (nonatomic, strong) UILabel *wechatLab;

@property (nonatomic, strong) UIButton *messageBtn;
@property (nonatomic, strong) UILabel *messageLab;
@property (nonatomic, strong) UILabel *lblUser;
@end

@implementation SYPasswordOpenGuardViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithGuardInfo:(SYLockListModel *)model{
   
    if (self == [super init]) {
        self.model = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.frame = CGRectMake(0, 0, screenWidth * 0.7, screenHeight);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wechatShare:) name:SYNOTICE_WECHAT_SHARE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(qqShare:) name:SYNOTICE_QQ_SHARE object:nil];
    
    [self initUI];
    [self getRandomPw];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - overwrite
- (NSString *)backBtnTitle{
    return @"密码开锁";
}


#pragma mark - private
- (void)initUI{
    
    self.scrollView = [[SYCustomScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.scrollView];
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, screenWidth * 0.7 - 20, (820.0 / 702) * self.view.width_sd)];
    mainView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:mainView];
    self.mainView = mainView;
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, mainView.width_sd, 30)];
    titleLab.text = @"开锁密码为:";
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = [UIFont systemFontOfSize:18];
    [mainView addSubview:titleLab];
    self.titleLab = titleLab;
    
    self.pwLab = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLab.bottom_sd + 50, mainView.width_sd, 30)];
    self.pwLab.textColor = UIColorFromRGB(0xd23023);
    self.pwLab.font = [UIFont systemFontOfSize:18];
    self.pwLab.textAlignment = NSTextAlignmentCenter;
    [mainView addSubview:self.pwLab];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.pwLab.bottom_sd, self.view.width_sd * 0.5, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    lineView.center = CGPointMake(mainView.width_sd * 0.5, lineView.centerY);
    [mainView addSubview:lineView];
    self.lineView = lineView;
    
    
    UILabel *lblUser = [[UILabel alloc] init];
    lblUser.text = @"开锁步骤：先按【F】/【功能】再输入6位呼叫号码再按拨号键，业主按通授权后可直接作开门密码使用。";
    lblUser.textAlignment = NSTextAlignmentCenter;
    lblUser.font = [UIFont systemFontOfSize:13];
    lblUser.textColor = [UIColor lightGrayColor];
    lblUser.numberOfLines = 0;
    [mainView addSubview:lblUser];
    self.lblUser = lblUser;
    
    UILabel *shareLab = [[UILabel alloc] initWithFrame:CGRectMake(0, lineView.bottom_sd + 50, mainView.width_sd, 30)];
    shareLab.text = @"可通过以下方式分享";
    shareLab.textAlignment = NSTextAlignmentCenter;
    shareLab.textColor = [UIColor lightGrayColor];
    shareLab.font = [UIFont systemFontOfSize:14];
    [mainView addSubview:shareLab];
    self.shareLab = shareLab;
    
    UIView *shareView = [[UIView alloc] initWithFrame:CGRectMake(0, shareLab.bottom_sd + 20, self.view.width_sd, 60)];
    [self.view addSubview:shareView];
    self.shareView = shareView;
    
    float fLeft = (shareView.width_sd / 3);
    UIImage *img = [UIImage imageNamed:@"sy_home_QQ"];
    UIButton *qqBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [qqBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    qqBtn.tag = QQBtnTag;
    qqBtn.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    [qqBtn setImage:img forState:UIControlStateNormal];
    qqBtn.center = CGPointMake((fLeft * 0) + (fLeft * 0.5), qqBtn.centerY);
    [shareView addSubview:qqBtn];
    self.qqBtn = qqBtn;
    
    UILabel *qqLab = [[UILabel alloc] initWithFrame:CGRectMake(0, qqBtn.bottom_sd + 10, qqBtn.width_sd, 20)];
    qqLab.text = @"QQ好友";
    qqLab.textAlignment = NSTextAlignmentCenter;
    qqLab.font = [UIFont systemFontOfSize:14];
    qqLab.textColor = UIColorFromRGB(0x999999);
    qqLab.center = CGPointMake(qqBtn.centerX, qqLab.centerY);
    [shareView addSubview:qqLab];
    self.qqLab = qqLab;
    
    UIButton *wechatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [wechatBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    wechatBtn.tag = WeChatBtnTag;
    wechatBtn.frame = CGRectMake(0, qqBtn.top_sd, img.size.width, img.size.height);
    [wechatBtn setImage:[UIImage imageNamed:@"sy_home_WeChat"] forState:UIControlStateNormal];
    wechatBtn.center = CGPointMake((fLeft * 1) + (fLeft * 0.5), qqBtn.centerY);
    [shareView addSubview:wechatBtn];
    self.wechatBtn = wechatBtn;
    
    UILabel *wechatLab = [[UILabel alloc] initWithFrame:CGRectMake(0, wechatBtn.bottom_sd + 10, wechatBtn.width_sd, 20)];
    wechatLab.text = @"微信好友";
    wechatLab.textColor = UIColorFromRGB(0x999999);
    wechatLab.textAlignment = NSTextAlignmentCenter;
    wechatLab.font = [UIFont systemFontOfSize:14];
    wechatLab.center = CGPointMake(wechatBtn.centerX, qqLab.centerY);
    [shareView addSubview:wechatLab];
    self.wechatLab = wechatLab;

    UIButton *messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [messageBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    messageBtn.tag = MessageBtnTag;
    messageBtn.frame = CGRectMake(0, qqBtn.top_sd, img.size.width, img.size.height);
    [messageBtn setImage:[UIImage imageNamed:@"sy_home_mssage"] forState:UIControlStateNormal];
    messageBtn.center = CGPointMake((fLeft * 2) + (fLeft * 0.5), qqBtn.centerY);
    [shareView addSubview:messageBtn];
    self.messageBtn = messageBtn;
    
    UILabel *messageLab = [[UILabel alloc] initWithFrame:CGRectMake(0, wechatBtn.bottom_sd + 10, wechatBtn.width_sd, 20)];
    messageLab.text = @"手机短信";
    messageLab.textColor = UIColorFromRGB(0x999999);
    messageLab.textAlignment = NSTextAlignmentCenter;
    messageLab.font = [UIFont systemFontOfSize:14];
    messageLab.center = CGPointMake(messageBtn.centerX, qqLab.centerY);
    [shareView addSubview:messageLab];
    self.messageLab = messageLab;
    
    //=====底部lab======
    self.noticeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.scrollView.height_sd - 50 - 64, self.view.width_sd, 40)];
    self.noticeLab.text = @"密码用于打开相关房产的门锁，切记不要分享给不相关的人哦。";
    self.noticeLab.textAlignment = NSTextAlignmentCenter;
    self.noticeLab.numberOfLines = 0;
    self.noticeLab.textColor = UIColorFromRGB(0x999999);
    self.noticeLab.font = [UIFont systemFontOfSize:12];
    self.noticeLab.center = CGPointMake(self.view.width_sd * 0.5, self.noticeLab.centerY);
    [self.view addSubview:self.noticeLab];
    
    self.timeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.noticeLab.top_sd - 20, self.view.width_sd - 20, 40)];
    self.timeLab.textColor = UIColorFromRGB(0x999999);
    self.timeLab.font = [UIFont systemFontOfSize:12];
    self.timeLab.numberOfLines = 0;
    self.timeLab.lineBreakMode = NSLineBreakByCharWrapping;
    self.timeLab.textAlignment = NSTextAlignmentCenter;
    self.timeLab.center = CGPointMake(self.view.width_sd * 0.5, self.timeLab.centerY);
    [self.view addSubview:self.timeLab];
    
    UIButton *btnReturn = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReturn.frame = CGRectMake(0, 10, 70, 50);
    [btnReturn setImage:[UIImage imageNamed:@"last.png"] forState:UIControlStateNormal];
    [btnReturn addTarget:self action:@selector(ExitSubView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnReturn];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = @"密码开锁";
    [self.view addSubview:lblTitle];
    self.lblTitle = lblTitle;
    
    self.underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth - dockWidth - 0, 1)];
    _underLineView.backgroundColor = underLineColor;
    [self.view addSubview:_underLineView];
}

- (void)viewWillLayoutSubviews{
    
    self.view.frame = CGRectMake(screenWidth * 0.3, 0, screenWidth * 0.7, screenHeight);
    self.scrollView.frame = self.view.bounds;
    self.lblTitle.frame = CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50);
    
    self.mainView.frame = CGRectMake(10, 60, screenWidth * 0.7 - 20, (820.0 / 702) * screenWidth * 0.7);
    self.mainView.backgroundColor = [UIColor whiteColor];
    self.titleLab.frame = CGRectMake(0, 30, self.mainView.width_sd, 30);
    self.pwLab.frame = CGRectMake(0, self.titleLab.bottom_sd + 50, self.mainView.width_sd, 30);
    
    self.underLineView.frame = CGRectMake(0, 60, kScreenWidth - dockWidth - 0, 1);
    self.lineView.frame = CGRectMake(0, self.pwLab.bottom_sd, self.view.width_sd * 0.5, 1);
    self.lineView.center = CGPointMake(self.mainView.width_sd * 0.5, self.lineView.centerY);
    
    self.lblUser.frame = CGRectMake(10, self.lineView.bottom_sd + 10, self.mainView.width_sd - 20, 100);
    //[self.lblUser sizeToFit];
    self.shareLab.frame = CGRectMake(0, self.lblUser.bottom_sd + 20, self.mainView.width_sd, 30);
    self.noticeLab.frame = CGRectMake(0, self.scrollView.height_sd - 50 - 64, self.view.width_sd, 40);
    self.timeLab.frame = CGRectMake(0, self.noticeLab.top_sd - 20, self.view.width_sd - 20, 20);
    
    self.shareView.frame = CGRectMake(0, CGRectGetMaxY(self.shareLab.frame) + 70, screenWidth * 0.7, 60);
    
    float fLeft = (screenWidth * 0.7 / 3);
    UIImage *img = [UIImage imageNamed:@"sy_home_QQ"];
    self.qqBtn.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    self.qqBtn.center = CGPointMake((fLeft * 0) + (fLeft * 0.5), self.qqBtn.centerY);
    
    self.qqLab.frame = CGRectMake(0, self.qqBtn.bottom_sd + 10, self.qqBtn.width_sd, 20);
    self.qqLab.text = @"QQ好友";
    self.qqLab.center = CGPointMake(self.qqBtn.centerX, self.qqLab.centerY);
    
    self.wechatBtn.frame = CGRectMake(0, self.qqBtn.top_sd, img.size.width, img.size.height);
    self.wechatBtn.center = CGPointMake((fLeft * 1) + (fLeft * 0.5), self.qqBtn.centerY);
    
    self.wechatLab.frame = CGRectMake(0, self.wechatBtn.bottom_sd + 10, self.wechatBtn.width_sd, 20);
    self.wechatLab.text = @"微信好友";
    self.wechatLab.center = CGPointMake(self.wechatBtn.centerX, self.wechatLab.centerY);
    
    self.messageBtn.frame = CGRectMake(0, self.qqBtn.top_sd, img.size.width, img.size.height);
    self.messageBtn.center = CGPointMake((fLeft * 2) + (fLeft * 0.5), self.qqBtn.centerY);
    
    self.messageLab.frame = CGRectMake(0, self.wechatBtn.bottom_sd + 10, self.wechatBtn.width_sd, 20);
    self.messageLab.text = @"手机短信";
    self.messageLab.center = CGPointMake(self.messageBtn.centerX, self.messageLab.centerY);
}

- (void)ExitSubView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeDrawer"
                                                        object:nil];
}

- (void)getRandomPw{
    WEAK_SELF;
    SYLoginHttpDAO *loginHttpDAO = [[SYLoginHttpDAO alloc] init];
    
    
    //0表示密码直接开门模式，1为密码呼叫开门模式
    if ([SYAppConfig shareInstance].bindedModel.neibor_id.fopen_mode == 0) {
        [loginHttpDAO getRandomPasswordWithSipNumber:self.model.sip_number WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username Succeed:^(SYRandomPWModel *model) {
            
            weakSelf.pwModel = model;
            if (model) {
                weakSelf.pwLab.text = model.random_pw;
                weakSelf.timeLab.frame = (CGRect){weakSelf.timeLab.frame.origin.x, weakSelf.noticeLab.top_sd - 20, weakSelf.timeLab.width, 20};
                
                weakSelf.lblUser.text = [NSString stringWithFormat:@"%@的本次开锁密码为：%@，于%@失效，请妥善保管。\n开锁步骤：先按“F/功能”键，输入对应密码后再按“#”号键。", self.model.lock_parent_name, self.pwModel.random_pw, [self secondsToDate:[self.pwModel.randomkey_dead_time doubleValue]]];
            }
        } fail:^(NSError *error) {
            [weakSelf showErrorWithContent:[NSString stringWithFormat:@"%@", [error.userInfo objectForKey:@"NSLocalizedDescription"]] duration:1];
        }];
    }else{
        
        [loginHttpDAO getQiFuPasswordWithSipNumber:self.model.sip_number neibor_id:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username Succeed:^(SYRandomPWModel *model) {
            
            weakSelf.pwModel = model;
            if (model) {
                
                if (self.pwModel.tdead_time.length > 0) {
                    self.pwModel.tdead_time = [self.pwModel.tdead_time substringToIndex:10];
                }
                
                weakSelf.pwLab.text = model.tpassword;
                weakSelf.timeLab.frame = (CGRect){weakSelf.timeLab.frame.origin.x, weakSelf.noticeLab.top_sd - 40, weakSelf.timeLab.width, 40};
                weakSelf.lblUser.text = [NSString stringWithFormat:@"【%@】的呼叫号码为：%@，于%@失效，请妥善保管。\n呼叫步骤：先按【F】/【功能】再输入6位呼叫号码再按拨号键，接通业主授权后可直接作开门密码使用。", weakSelf.model.lock_parent_name, model.tpassword, [weakSelf secondsToDate:[weakSelf.pwModel.tdead_time doubleValue]]];
            }
        } fail:^(NSError *error) {
            [weakSelf showErrorWithContent:[NSString stringWithFormat:@"%@", [error.userInfo objectForKey:@"NSLocalizedDescription"]] duration:1];
        }];
    }
}

//显示系统短信发送页
- (void)showMessageView:(NSArray *)phones title:(NSString *)title body:(NSString *)body{
    
    if([MFMessageComposeViewController canSendText]){

        dispatch_async(dispatch_get_main_queue(), ^{
            MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
            //        controller.recipients = phones;   //收信人
            controller.body = body;
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:nil];
            //        [[[[controller viewControllers] lastObject] navigationItem] setTitle:title];//修改短信界面标题
        });
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                        message:@"该设备不支持短信功能"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

//秒转换为日期
- (NSString *)secondsToDate:(double)time{
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    return [formatter stringFromDate:date];
}

#pragma mark - event
- (void)btnClick:(UIButton *)btn{

    NSString *contentString;
    if ([SYAppConfig shareInstance].bindedModel.neibor_id.fopen_mode == 0) {
       contentString = [NSString stringWithFormat:@"%@的本次开锁密码为：%@，于%@失效，请妥善保管。\n开锁步骤：先按“F/功能”键，输入对应密码后再按“#”号键。", self.model.lock_parent_name, self.pwModel.random_pw, [self secondsToDate:[self.pwModel.randomkey_dead_time doubleValue]]];
    }else{
        
       contentString = [NSString stringWithFormat:@"【%@】的呼叫号码为：%@，于%@失效，请妥善保管。\n呼叫步骤：先按【F】/【功能】再输入6位呼叫号码再按拨号键，接通业主授权后可直接作开门密码使用。", self.model.lock_parent_name, self.pwModel.tpassword, [self secondsToDate:[self.pwModel.tdead_time doubleValue]]];
    }
    

    if (btn.tag == QQBtnTag) {
        if ([QQApiInterface isQQInstalled]) {
            QQApiTextObject *txtObj = [QQApiTextObject objectWithText:contentString];
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
            [QQApiInterface sendReq:req];
        }
        else{
            [self showMessageWithContent:@"请先安装QQ" duration:1];
        }
    }else if (btn.tag == WeChatBtnTag) {
        
        if ([WXApi isWXAppInstalled]){
            
            SendMessageToWXReq * req = [[SendMessageToWXReq alloc] init];
            req.text = contentString;
            req.bText = YES;
            req.scene = WXSceneSession;
            [WXApi sendReq:req];
        }
        else{
            [self showMessageWithContent:@"请先安装微信" duration:1];
        }
    }else if (btn.tag == MessageBtnTag) {
        [self showMessageView:nil title:nil body:contentString];
    }
}


#pragma mark - noti
- (void)wechatShare:(NSNotification *)noti{
    NSNumber *numCode = (NSNumber *)[noti userInfo];
    if ([numCode intValue] == 0) {
        [self showSuccessWithContent:@"分享成功" duration:1];
    }else if ([numCode intValue] == -2){
        [self showMessageWithContent:@"用户取消" duration:1];
    }else{
        [self showErrorWithContent:@"发送失败" duration:1];
    }
}

- (void)qqShare:(NSNotification *)noti{
    NSString *numCode = (NSString *)[noti userInfo];
    if ([numCode intValue] == 0) {
        [self showSuccessWithContent:@"分享成功" duration:1];
    }else if ([numCode intValue] == -2){
        [self showMessageWithContent:@"用户取消" duration:1];
    }else{
        [self showErrorWithContent:@"发送失败" duration:1];
    }
}



#pragma mark - uimessage delegate
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultSent:
            //信息传送成功
            [self showSuccessWithContent:@"发送成功" duration:1];
            break;
        case MessageComposeResultFailed:
            //信息传送失败
            [self showErrorWithContent:@"发送失败" duration:1];
            break;
        case MessageComposeResultCancelled:
            //信息被用户取消传送
            [self showMessageWithContent:@"用户取消" duration:1];
            break;
        default:
            break;
    }
}
@end
