//
//  SYHomeViewController.m
//  YLB
//
//  Created by YAYA on 2017/3/12.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYHomeViewController.h"
#import "SYHomeGuardTableViewCell.h"
#import "SYHomeCommunityFunctionTableViewCell.h"
#import "SYHomeBannerTableViewCell.h"
#import "HMScannerViewController.h"
#import "SYHomeAllGuardsViewController.h"
#import "SYCommunityHttpDAO.h"
#import "SYMyCommunityViewController.h"
#import "SYPropertyRepairViewController.h"
#import "SYNeighborListViewController.h"
#import "SYGuardMontorView.h"
#import "SYGuardMonitorViewController.h"
#import "SYMyMessgeViewController.h"
#import "SYPersonalSpaceHttpDAO.h"
#import "SYLoginHttpDAO.h"
#import "SDWebImageManager.h"
#import "SYLoginViewController.h"
#import "SYWKWebViewController.h"
#import "MJRefresh.h"
#import "SYBlueTeethManager.h"
#import "SYBlueTeethListView.h"
#import "SYBlueTeethPeripheralModel.h"
#import "SYPropertyCostViewController.h"

typedef enum : NSUInteger {
    headerClickTag = 0,
    scanClickTag,
    messageClickTag,
    changeCommunityClickTag
} BtnClickTag;

@interface SYHomeViewController ()<UITableViewDelegate, UITableViewDataSource, SYHomeCommunityFunctionTableViewCellDelegate,SYHomeGuardTableViewCellDelegate, SYBlueTeethManagerDelegate>{
    dispatch_source_t _timer;
}
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIButton *headerBtn;
@property (nonatomic, retain) UILabel *localCommunityLab;
@property (nonatomic, retain) NSMutableArray *adverMarr;    //广告
@property (nonatomic, retain) NSMutableArray *todayNewsModelMArr;    //社区头条

@property (nonatomic, retain) UILabel *noticeLab;
@property (nonatomic, retain) UILabel *noticeDownLab;
@property (nonatomic, assign) BOOL loginAgaining;    //正在自动登录中（token过期后，要再次调用登录接口，这个Bool防止多个接口返回身份验证失败后，多次调用登录接口）
@property (nonatomic, assign) int nNewsShowingIndex;   //正在显示第几条社区头条
@property (nonatomic, retain) SYGuardMontorView *guardMontorView;
@property (nonatomic, retain) SYBlueTeethListView *blueTeethListView;

@property (nonatomic, retain) UIView *shakeView;    //蓝牙摇一摇提示
@property (nonatomic, retain) UIImageView *shakeNoticeContentImgView;   //摇一摇中间的图片
@end

@implementation SYHomeViewController

- (void)dealloc{
    NSLog(@"SYHomeViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.localCommunityLab.text = [SYAppConfig shareInstance].bindedModel.neibor_id.fneibname;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.blueTeethListView hiddenBlueTeethListView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.adverMarr = [[NSMutableArray alloc] init];
    self.todayNewsModelMArr = [[NSMutableArray alloc] init];
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES; //震动功能
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reflashPersonalInfo) name:SYNOTICE_REFLASH_PERSONAL_INFO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginInAgain) name:SYNOTICE_ResponseIdentifyAuthenticationErrorCode object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChange) name:SYNOTICE_LOGIN_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGuard) name:SYNOTICE_REFRESH_GUARD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otherUserLoginIn:) name:SYNOTICE_OTHERUSERLOGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reflashNeighborData:) name:SYNOTICE_Binded_Neighbor object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChanged:) name:SYNOTICE_NetworkStateChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showReflashing:) name:SYNOTICE_ShowReflashingLinphone object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dissMissGuardView:) name:SYNOTICE_DissMissGuardView object:nil];
    
    [self configUI];


    
    
    //==================搜索蓝牙========================
    SYBlueTeethManager *manager = [SYBlueTeethManager shareInstance];
    manager.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - overwrite
- (BOOL) showBackButton{
    return NO;
}


#pragma mark - noti
//登录状态改变
- (void)loginChange{
    [self configData];
    if (![SYLoginInfoModel isLogin] && self.guardMontorView) {
        [self.guardMontorView removeFromSuperview];
    }
}

//添加门禁后刷新
- (void)refreshGuard{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
}

//token过期后，重新登录
- (void)loginInAgain{
    if (self.loginAgaining) {
        return;
    }
    SYLoginHttpDAO *loginHttpDAO = [[SYLoginHttpDAO alloc] init];
    [loginHttpDAO loiginWithPassword:[SYAppConfig shareInstance].password WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username Succeed:^(SYUserInfoModel *model) {
        
        self.loginAgaining = NO;

    } fail:^(NSError *error) {
        self.loginAgaining = NO;
        
        [[SYLinphoneManager instance] removeAccount];   //sip登出
        [SYLoginInfoModel loginOut];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            SYLoginViewController *loginVC = [[SYLoginViewController alloc] initWithShowLaunchViewAnim:NO];
            [FrameManager pushViewController:loginVC animated:NO];
   
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:[error.userInfo objectForKey:@"NSLocalizedDescription"] delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            [alertView show];
        });

    }];
    self.loginAgaining = YES;
}

//刷新头像
- (void)reflashPersonalInfo{
    
    if (![SYLoginInfoModel isLogin]) {
        return;
    }
    //===headerImg===
    if ([SYLoginInfoModel shareUserInfo].personalSpaceModel.headerImg) {
        [self.headerBtn setBackgroundImage:[SYLoginInfoModel shareUserInfo].personalSpaceModel.headerImg forState:UIControlStateNormal];
    }else{
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[SYLoginInfoModel shareUserInfo].personalSpaceModel.head_url]] options:SDWebImageDownloaderHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            
            if (finished && image) {
                [self.headerBtn setBackgroundImage:image forState:UIControlStateNormal];
                [SYLoginInfoModel shareUserInfo].personalSpaceModel.headerImg = image;
                [SYLoginInfoModel saveWithSYLoginInfo];
            }else if (finished && !image) {
                [self.headerBtn setBackgroundImage:[UIImage imageNamed:@"sy_navigation_normal_header"] forState:UIControlStateNormal];
            }
        }];
    }
}

//其他设备登录了账号
- (void)otherUserLoginIn:(NSNotification *)noti{
    
    [[SYLinphoneManager instance] hangUpCall];
    [[SYLinphoneManager instance] removeAccount];   //sip登出
    [SYLoginInfoModel loginOut];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        SYLoginViewController *loginVC = [[SYLoginViewController alloc] initWithShowLaunchViewAnim:NO];
        [FrameManager pushViewController:loginVC animated:NO];
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:@"您的账号在另一个设备上登录" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alertView show];
    });
}

- (void)networkStateChanged:(NSNotification *)noti{
    if (![[noti userInfo] isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSNumber *netWorkTypeNum = [[noti userInfo] objectForKey:@"NetWorkType"];
    SYConnectivityState netWorkType = [netWorkTypeNum intValue];
    if (netWorkType == sy_none) {
        NSLog(@"=======断网了=======");
    }else{
        NSLog(@"=======网络正常=======");
    }
    [SYAppConfig shareInstance].networkState = netWorkType;
}

- (void)showReflashing:(NSNotification *)noti{
    [self showMessageWithContent:@"门口机不在线" duration:1];
}

- (void)dissMissGuardView:(NSNotification *)noti{
    if (self.guardMontorView){
        [self.guardMontorView removeFromSuperview];
    }
}

- (void)reflashNeighborData:(NSNotification *)noti{
    [self showWithContent:nil];
    [self configData];
    self.localCommunityLab.text = [SYAppConfig shareInstance].bindedModel.neibor_id.fneibname;
}


#pragma mark - private
- (void)configUI{

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = UIColorFromRGB(0xebebeb);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];

    self.tableView.tableHeaderView = [self tableViewHeaderView];
    
    WEAK_SELF;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf dataRequest];
    }];
    
    [FrameManager tabBarViewController].navigationItem.titleView = [self titleView];
    
    UIImage *img = [UIImage imageNamed:@"sy_home_blueTeeth_shake_bg"];
    self.shakeView = [[UIView alloc] initWithFrame:CGRectMake(0, self.tableView.bottom_sd, img.size.width, img.size.height)];
    self.shakeView.backgroundColor = [UIColor clearColor];
    self.shakeView.center = CGPointMake(self.view.width_sd * 0.5, self.shakeView.centerY);
    [self.view addSubview:self.shakeView];
    
    UIImageView *shakeBGImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.shakeView.size.width, self.shakeView.size.height)];
    shakeBGImgView.image = img;
    [self.shakeView addSubview:shakeBGImgView];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.shakeView.size.height - 13, self.shakeView.size.width, 11)];
    lab.font = [UIFont systemFontOfSize:8];
    lab.text = @"摇一摇开锁";
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = UIColorFromRGB(0xff8600);
    [self.shakeView addSubview:lab];
    
    self.shakeNoticeContentImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 15, 27)];
    self.shakeNoticeContentImgView.image = [UIImage imageNamed:@"sy_home_blueTeeth_shake_unlock"];
    self.shakeNoticeContentImgView.center = CGPointMake(self.shakeView.width_sd * 0.5, self.shakeView.height_sd * 0.45);
    [self.shakeView addSubview:self.shakeNoticeContentImgView];

}

- (UIView *)titleView{
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,  self.view.width_sd - 28, 31)];
    titleView.backgroundColor = [UIColor clearColor];
    
    UIView *headerBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, titleView.height_sd, titleView.height_sd)];
    headerBGView.backgroundColor = [UIColor whiteColor];
    [titleView addSubview:headerBGView];
    

    self.headerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.headerBtn.frame = CGRectMake(2, 2, headerBGView.width_sd - 4, headerBGView.height_sd - 4);
    [self.headerBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.headerBtn.tag = headerClickTag;
    [headerBGView addSubview:self.headerBtn];
    [self reflashPersonalInfo];
    
    //中间更换社区
    UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(headerBGView.right_sd + 9, 0, titleView.width_sd - headerBGView.right_sd - 9, titleView.height_sd)];
    middleView.backgroundColor = [UIColor whiteColor];
    [titleView addSubview:middleView];
    
    UIImage *img = [UIImage imageNamed:@"sy_navigation_location_community"];
    UIImageView *localCommunityImgView = [[UIImageView alloc] initWithImage:img];
    localCommunityImgView.frame = CGRectMake(5, 0, img.size.width, img.size.height);
    localCommunityImgView.center = CGPointMake(localCommunityImgView.centerX, titleView.height * 0.5);
    [middleView addSubview:localCommunityImgView];
    
    //社区消息
    img = [UIImage imageNamed:@"sy_navigation_my_message"];
    UIButton *communityMessageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    communityMessageBtn.frame = CGRectMake(middleView.width_sd - titleView.height_sd, 0, titleView.height_sd, titleView.height_sd);
    [communityMessageBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [communityMessageBtn setBackgroundColor:[UIColor clearColor]];
    communityMessageBtn.tag = messageClickTag;
    [middleView addSubview:communityMessageBtn];
    
    UIImageView *communityMessageImgView = [[UIImageView alloc] initWithImage:img];
    communityMessageImgView.frame = CGRectMake(middleView.width_sd - img.size.height - 10, 0, img.size.width, img.size.height);
    communityMessageImgView.center = communityMessageBtn.center;
    [middleView addSubview:communityMessageImgView];

    //扫一扫
    img = [UIImage imageNamed:@"sy_navigation_scan"];
    UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    scanBtn.frame = CGRectMake(communityMessageBtn.left_sd - titleView.height_sd, 0, titleView.height_sd, titleView.height_sd);
    [scanBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [scanBtn setBackgroundColor:[UIColor clearColor]];
    scanBtn.tag = scanClickTag;
    [middleView addSubview:scanBtn];
    
    UIImageView *scanImgView = [[UIImageView alloc] initWithImage:img];
    scanImgView.frame = CGRectMake(communityMessageImgView.left_sd - img.size.height - 20, 0, img.size.width, img.size.height);
    scanImgView.center = scanBtn.center;
    [middleView addSubview:scanImgView];
    
    self.localCommunityLab = [[UILabel alloc] initWithFrame:CGRectMake(localCommunityImgView.right_sd + 5, 0, scanBtn.left_sd - localCommunityImgView.right_sd - 5, middleView.height_sd)];
    self.localCommunityLab.textColor = UIColorFromRGB(0x999999);
    self.localCommunityLab.font = [UIFont systemFontOfSize:14];
    [middleView addSubview:self.localCommunityLab];
    
    UIButton *localCommunityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    localCommunityBtn.frame = self.localCommunityLab.frame;
    localCommunityBtn.tag = changeCommunityClickTag;
    [localCommunityBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [middleView addSubview:localCommunityBtn];

    return titleView;
}

- (void)updateOldToken{
    
    if (![SYLoginInfoModel isLogin]) {
        return;
    }

    WEAK_SELF;
    //更换旧的token 提前5分钟 token一旦过期了就不能再换，只能再次登录
    double nowTime = [[NSDate date] timeIntervalSince1970];
    NSInteger timeToChangeToken = nowTime - [SYLoginInfoModel shareUserInfo].lastTimeChangeToken;
    if ((timeToChangeToken / 60.0) >= [SYLoginInfoModel shareUserInfo].userInfoModel.token_timeout) {
        NSLog(@"===========token 过期===========");
        [self loginInAgain];
    }
    else if ((timeToChangeToken / 60.0) + 5 >= [SYLoginInfoModel shareUserInfo].userInfoModel.token_timeout) {
        
        [self updateNewToken:nowTime];
    }
    else{
        long updateTokenAfterSecond = ([SYLoginInfoModel shareUserInfo].userInfoModel.token_timeout * 60 - timeToChangeToken - 300);
        if (updateTokenAfterSecond <= 0) {
            [self updateNewToken:nowTime];
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(updateTokenAfterSecond * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [weakSelf updateNewToken:nowTime];
        });
    }
}

- (void)configData{

    if (![SYLoginInfoModel isLogin] || [SYAppConfig shareInstance].secondPlatformIPStr.length == 0 || ![SYAppConfig shareInstance].bindedModel) {
        return;
    }
    
    [self updateOldToken];
    
    [self dataRequest];
}

//接口请求
- (void)dataRequest{
    
    WEAK_SELF;
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    
    // 获取广告信息 banner
//    [communityHttpDAO getAdvertismentWithNeighborID:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id WithUserName:[SYLoginInfoModel shareUserInfo].userInfoModel.username Succeed:^(SYAdvertInfoListModel *model) {
//        
//        [weakSelf.adverMarr removeAllObjects];
//        [weakSelf.adverMarr addObjectsFromArray:model.homepage];
//        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
//        
//        [weakSelf.tableView.mj_header endRefreshing];
//    } fail:^(NSError *error) {
//        [weakSelf showErrorWithContent:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]] duration:1];
//        [weakSelf.tableView.mj_header endRefreshing];
//    }];

    //社区头条
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    [communityHttpDAO getTodayNewsWithNeigborID:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username WithStartTime:@"201254043423" WithEndTime:[dateFormatter stringFromDate:[NSDate date]] WithIsPage:0 WithCurrentPage:0 WithPageSize:0 Succeed:^(NSArray *modelArr) {
        
        if (!modelArr) {
            return ;
        }
        
        [weakSelf.todayNewsModelMArr removeAllObjects];
        [weakSelf.todayNewsModelMArr addObjectsFromArray:modelArr];
        [weakSelf neighborNewsTimerOpen];
        
    } fail:^(NSError *error) {
        [weakSelf showErrorWithContent:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]] duration:1];
    }];
    
    
    // 用户获取配置信息获取房产列表（房产管理）
    [communityHttpDAO getMyConfigInfoWithNeigborID:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username Succeed:^(SYConfigInfoModel *configInfo) {
        
        [SYLoginInfoModel shareUserInfo].configInfoModel = configInfo;
        [SYLoginInfoModel saveWithSYLoginInfo];
    } fail:^(NSError *error) {
        
    }];
    
    
    //全部门禁
    [communityHttpDAO getMyLockListWithNeigborID:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username Succeed:^(NSArray *modelArr) {

        NSMutableArray *arrTmp = [[NSMutableArray alloc] init];
        for (SYLockListModel *model in modelArr) {
            
            //删除全部门禁里面没有的已选择的门禁
            [[SYAppConfig shareInstance].selectedGuardMArr enumerateObjectsUsingBlock:^(SYLockListModel *modelTmp, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if ([model.sip_number isEqualToString:modelTmp.sip_number]) {
                    [arrTmp addObject:model];
                    *stop = YES;
                }
            }];
        }
        
        @synchronized ([SYAppConfig shareInstance].selectedGuardMArr) {
            [[SYAppConfig shareInstance].selectedGuardMArr removeAllObjects];
            [[SYAppConfig shareInstance].selectedGuardMArr addObjectsFromArray:arrTmp];
            [weakSelf.tableView reloadData];
        }
        [weakSelf dismissHud:YES];
    } fail:^(NSError *error) {
        [weakSelf dismissHud:YES];
    }];
}

- (void)updateNewToken:(double)nowTime{
    WEAK_SELF;
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    [communityHttpDAO getNewTokenWithOldToken:[SYLoginInfoModel shareUserInfo].userInfoModel.token WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username Succeed:^{
        [SYLoginInfoModel shareUserInfo].lastTimeChangeToken = nowTime;
        [SYLoginInfoModel saveWithSYLoginInfo];
        [weakSelf updateOldToken];  //获取新TOKEN后，要继续监听token是否过期
    } fail:^(NSError *error) {
        
    }];
}

- (UIView *)tableViewHeaderView{
    
    //社区头条
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 36 + 10)];
    headerView.backgroundColor = UIColorFromRGB(0xebebeb);
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(14, 10, headerView.width_sd - 28, headerView.height_sd - 10)];
    mainView.backgroundColor = [UIColor whiteColor];
    mainView.clipsToBounds = YES;
    [headerView addSubview:mainView];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(newsTap:)];
    [mainView addGestureRecognizer:tapGes];
    
    UIImage *img = [UIImage imageNamed:@"sy_home_headLine"];
    UIImageView *iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, img.size.width, img.size.height)];
    iconImgView.image = img;
    iconImgView.center = CGPointMake(iconImgView.centerX, mainView.height * 0.5f);
    [mainView addSubview:iconImgView];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(iconImgView.right + 17, 0, 1, 21)];
    lineView.backgroundColor = UIColorFromRGB(0xebebeb);
    lineView.center = CGPointMake(lineView.centerX, iconImgView.centerY);
    [mainView addSubview:lineView];
    
    
    float fnoticeLabLeft = lineView.right + 17;
    self.noticeLab = [[UILabel alloc] initWithFrame:CGRectMake(fnoticeLabLeft, 0, mainView.width - fnoticeLabLeft, mainView.height)];
    self.noticeLab.font = [UIFont systemFontOfSize:14.0];
    [mainView addSubview:self.noticeLab];
    
    self.noticeDownLab = [[UILabel alloc] initWithFrame:CGRectMake(fnoticeLabLeft, self.noticeLab.top_sd - self.noticeLab.height, mainView.width - fnoticeLabLeft, mainView.height)];
    self.noticeDownLab.font = [UIFont systemFontOfSize:14.0];
    [mainView addSubview:self.noticeDownLab];
    
    return headerView;
}

- (void)neighborNewsTimerOpen{

    if (self.todayNewsModelMArr.count == 0) {
        self.noticeLab.text = @"";
        self.noticeDownLab.text = @"";
        return;
    }
    
     if (self.todayNewsModelMArr.count == 1) {
         SYTodayNewsModel *model = self.todayNewsModelMArr.firstObject;
         self.noticeLab.text = model.title;
         self.noticeDownLab.text = @"";
         return;
    }
 
    self.nNewsShowingIndex = 0;
    SYTodayNewsModel *model = [self.todayNewsModelMArr objectAtIndex:0];
    self.noticeLab.text = model.title;
    
    model = [self.todayNewsModelMArr objectAtIndex:1];
    self.noticeDownLab.text = model.title;
    
    WEAK_SELF;
    __block int nIndex = 1;        //头条大于等于2条才轮播
    if (_timer) {
        dispatch_source_cancel(_timer);
    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0), 10.0 * NSEC_PER_SEC, 0); //每10秒执行
    dispatch_source_set_event_handler(_timer, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            if (nIndex + 1 >= weakSelf.todayNewsModelMArr.count) {
                nIndex = 0;
            }else{
                nIndex++;
            }
            self.nNewsShowingIndex = nIndex;
            
            [UIView animateWithDuration:0.25 animations:^{
                if (weakSelf.noticeLab.top == 0) {
                    weakSelf.noticeDownLab.top = 0;
                    weakSelf.noticeLab.top = weakSelf.noticeLab.height_sd;
                }else{
                    weakSelf.noticeDownLab.top = weakSelf.noticeDownLab.height_sd;
                    weakSelf.noticeLab.top = 0;
                }
            } completion:^(BOOL finished) {
                
                if (weakSelf.noticeLab.top == 0) {
                    weakSelf.noticeDownLab.bottom_sd = 0;
                }else{
                    weakSelf.noticeLab.bottom_sd = 0;
                }
                
                if (weakSelf.todayNewsModelMArr.count > 0 && nIndex < weakSelf.todayNewsModelMArr.count){
                    SYTodayNewsModel *model = [weakSelf.todayNewsModelMArr objectAtIndex:nIndex];
                    if (weakSelf.noticeLab.bottom_sd == 0) {
                        weakSelf.noticeLab.text = model.title;
                    }
                    else{
                        weakSelf.noticeDownLab.text = model.title;
                    }
                }
            }];
        });
    });
    dispatch_resume(_timer);
}

//显示蓝牙门口机列表
- (void)showBlueViewWithPeripheralModelArr:(NSArray *)peripheralModelArr{
    
    if (!self.blueTeethListView) {
        self.blueTeethListView = [[SYBlueTeethListView alloc] initWithFrame:[[UIApplication sharedApplication].delegate window].bounds WithPeripheralArr:peripheralModelArr];
    }
    [self.blueTeethListView setSYBlueTeethListClickBlock:^(int index, SYBlueTeethPeripheralModel *model) {
        
        if (index < peripheralModelArr.count) {
            CBPeripheral *peripheral = [peripheralModelArr objectAtIndex:index];
            SYBlueTeethManager *manager = [SYBlueTeethManager shareInstance];
            [manager connectPeripheral:peripheral BlueTeethPeripheralModel:model];
        }
    }];
    [self.blueTeethListView tableViewReload:peripheralModelArr];
    [[UIApplication sharedApplication].keyWindow addSubview:self.blueTeethListView];
    [self.blueTeethListView showBlueTeethListView];
}


#pragma mark - event
- (void)btnClick:(UIButton *)btn{

    if (btn.tag == headerClickTag) {
        [FrameManager changeTabbarIndex:2];
    }else if (btn.tag == scanClickTag) {
        HMScannerViewController *scanVC =  [[HMScannerViewController alloc] initWithCardName:nil avatar:nil completion:^(NSString *stringValue) {
            if (stringValue) {
                NSURL *url = [NSURL URLWithString:stringValue];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }];
        
        [self presentViewController:scanVC animated:YES completion:^{
            
        }];
    }else if (btn.tag == messageClickTag) {
        
        SYMyMessgeViewController *vc = [[SYMyMessgeViewController alloc] init];
        [FrameManager pushViewController:vc animated:YES];
        
    }else if (btn.tag == changeCommunityClickTag) {
        
        SYNeighborListViewController *vc = [[SYNeighborListViewController alloc] init];
        [FrameManager pushViewController:vc animated:YES];
    }
}

- (void)newsTap:(UITapGestureRecognizer *)tap{
    
    if (self.nNewsShowingIndex >= self.todayNewsModelMArr.count) {
        return;
    }
//    SYTodayNewsModel *model = [self.todayNewsModelMArr objectAtIndex:self.nNewsShowingIndex];
//    SYWKWebViewController *webViewController = [[SYWKWebViewController alloc] initWithURL:model.news_url];
//    webViewController.title = @"社区头条";
//    [FrameManager pushViewController:webViewController animated:YES];
}



#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  
    switch (indexPath.section) {

        case 0:
            return SYHomeBannerTableViewCellHeight;
            break;
        case 1:
            return SYHomeCommunityFunctionTableViewCellHeight;
            break;
        case 2:
            return SYHomeGuardTableViewCellCellHeight;
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return 10;
    }
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0){//banner
      
        static NSString *identify = @"SYHomeBannerTableViewCell";
        SYHomeBannerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[SYHomeBannerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [cell updateBannerInfo:self.adverMarr];
        
        return cell;
        
    }else if (indexPath.section == 1){// 我的社区、物业报修、物业投诉、物业缴费
       
        static NSString *identify = @"SYHomeCommunityFunctionTableViewCell";
        SYHomeCommunityFunctionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[SYHomeCommunityFunctionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
        }
  
        return cell;
    }else {
        //门禁
        static NSString *identify = @"SYHomeGuardTableViewCell";
        SYHomeGuardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[SYHomeGuardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
        }
   
        [cell reloadGuardCollectionView];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    CGFloat height = scrollView.frame.size.height;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat bottomOffset = scrollView.contentSize.height - contentOffsetY;
    //在最底部了
    if (bottomOffset <= height + 5)
    {
        NSLog(@"底部");
        if (self.shakeView.top_sd >= self.tableView.height_sd) {
            [UIView animateWithDuration:0.25 animations:^{
                self.shakeView.frame = (CGRect){{self.shakeView.left, self.tableView.height_sd - self.shakeView.height_sd}, self.shakeView.size};
            }];
        }
    }
    else
    {
        if (self.shakeView.bottom_sd == self.tableView.height_sd) {
        [UIView animateWithDuration:0.25 animations:^{
            self.shakeView.frame = (CGRect){{self.shakeView.origin.x, self.tableView.height_sd + self.shakeView.height_sd}, self.shakeView.size};
        }];
         }
    }
}


#pragma mark - SYHomeCommunityFunctionTableViewCellDelegate
#pragma mark 我的社区、物业报修、物业投诉、智能家居
- (void)functionBtnSelect:(functionTag)type{

    if (type == sy_home_my_communityBtnTag) {
        SYMyCommunityViewController *vc = [[SYMyCommunityViewController alloc] init];
        [FrameManager pushViewController:vc animated:YES];
        
    }else if (type == sy_home_repair_propertyBtnTag) {
        SYPropertyRepairViewController *vc = [[SYPropertyRepairViewController alloc] initWithRepairListOrderType:propertyRepairListType WithTitle:@"报修单"];
        [FrameManager pushViewController:vc animated:YES];
        
    }else if (type == sy_home_property_complaintsBtnTag) {
        SYPropertyRepairViewController *vc = [[SYPropertyRepairViewController alloc] initWithRepairListOrderType:propertyComplainListType WithTitle:@"投诉单"];
        [FrameManager pushViewController:vc animated:YES];
        
    }else if (type == sy_home_smart_homeBtnTag) {
        
        SYPropertyCostViewController *vc = [[SYPropertyCostViewController alloc] initWithRepairListOrderType:propertyComplainListType WithTitle:@"选择缴费房产"];
        [FrameManager pushViewController:vc animated:YES];
        //[self showMessageWithContent:@"功能未开通" duration:1];
    }
}

#pragma mark - SYHomeGuardTableViewCellDelegate
- (void)guardClick:(NSIndexPath *)indexPath LockListModel:(SYLockListModel *)model{
  
    //全部门禁
    if (indexPath.row == 4){
        SYHomeAllGuardsViewController *vc = [[SYHomeAllGuardsViewController alloc] init];
        vc.isAllGuardIn = YES;
        vc.clickIndex = -1;
        [FrameManager pushViewController:vc animated:YES];
    }
    else if (indexPath.row < 4){    //单独4个门禁
    
        //没有门禁，跳去全部门禁页面
        if (!model) {
            SYHomeAllGuardsViewController *vc = [[SYHomeAllGuardsViewController alloc] init];
            vc.isAllGuardIn = NO;
            vc.clickIndex = indexPath.row;
            [FrameManager pushViewController:vc animated:YES];
        }else{
            self.guardMontorView = [[SYGuardMontorView alloc] initWithFrame:[UIApplication sharedApplication].delegate.window.bounds WithLockListModel:model];
            [[UIApplication sharedApplication].delegate.window addSubview:self.guardMontorView];
        }
    }
}

//点击了添加门禁按钮，跳去全部门禁页面
- (void)addGuardClick:(NSIndexPath *)indexPath LockListModel:(SYLockListModel *)model{
    SYHomeAllGuardsViewController *vc = [[SYHomeAllGuardsViewController alloc] init];
    vc.isAllGuardIn = NO;
    vc.clickIndex = indexPath.row;
    [FrameManager pushViewController:vc animated:YES];
}


#pragma mark - applicationSupportsShake Delegate 摇一摇
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
  
    if (![SYBlueTeethManager isBlueTeethOpen]) {
        [self showMessageWithContent:@"请打开蓝牙" duration:2];
        return;
    }
    
    if(motion == UIEventSubtypeMotionShake) {
        NSLog(@"====UIEventSubtypeMotionShake======");

        [[SYBlueTeethManager shareInstance] starScanGuard];
    }
}

#pragma mark - SYBlueTeethManagerDelegate
- (void)blueTeethScanFinish:(NSArray *)peripheralArr PeripheralModel:(NSArray *)peripheralModelArr{

    //显示多个门禁让用户选择开哪个
    if (peripheralModelArr.count > 1) {
        
        NSArray *arrTmp = [[NSArray alloc] initWithArray:peripheralModelArr];
        
        if (!self.blueTeethListView) {
            self.blueTeethListView = [[SYBlueTeethListView alloc] initWithFrame:[[UIApplication sharedApplication].delegate window].bounds WithPeripheralArr:arrTmp];
            [self.view addSubview:self.blueTeethListView];
        }
        WEAK_SELF;
        [self.blueTeethListView setSYBlueTeethListClickBlock:^(int index, SYBlueTeethPeripheralModel *model) {
            
            if (index < arrTmp.count) {
                SYBlueTeethPeripheralModel *peripheralModel = [arrTmp objectAtIndex:index];
                
                if ([peripheralModel.RSSI integerValue] < -90) {
                    [weakSelf showMessageWithContent:@"蓝牙信号弱,请靠近后重新连接" duration:1];
                    return ;
                }
                
                if (index < peripheralArr.count) {
                    CBPeripheral *peripheral = [peripheralArr objectAtIndex:index];
                    SYBlueTeethManager *manager = [SYBlueTeethManager shareInstance];
                    [manager connectPeripheral:peripheral BlueTeethPeripheralModel:model];
                }
            }
        }];
        [self.blueTeethListView tableViewReload:arrTmp];
        [self.blueTeethListView showBlueTeethListView];
    }
}
@end
