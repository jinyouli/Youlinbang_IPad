//
//  SecondViewController.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/6/26.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "HomePageViewController.h"
#import "ViewController.h"
#import "SYHomeBannerTableViewCell.h"
#import "MJRefresh.h"
#import "SYCommunityHttpDAO.h"
#import "SYAppConfig.h"
#import "SYHomeGuardTableViewCell.h"
#import "SYDiscoverCommunityNewsTableViewCell.h"
#import "SYGuardMonitorViewController.h"
#import "HMScannerViewController.h"
#import "AffineDrawer.h"
#import "ViewcontrollersManager.h"
#import "DoorListViewController.h"
#import "CommunityListView.h"
#import "AppDelegate.h"
#import "SYHomeGuardCollectionViewCell.h"
#import "SYHomeBannerCollectionViewCell.h"
#import "SYHomeCommandMessageCollectionViewCell.h"

typedef enum : NSUInteger {
    headerClickTag = 0,
    scanClickTag,
    messageClickTag,
    changeCommunityClickTag,
    moreLock,
    moreNews
} BtnClickTag;

static NSString *const HomeBannerCollectionViewCellID = @"SYHomeBannerCollectionViewCellID";
static NSString *const HomeGuardCollectionViewCellID = @"SYHomeGuardCollectionViewCellID";
static NSString *const headerId = @"headerId";
static NSString *const HomeCommandMessageCollectionViewCellID = @"SYHomeCommandMessageCollectionViewCellID";

@interface HomePageViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate,SYHomeGuardTableViewCellDelegate>{
    dispatch_source_t _timer;
}

@property (nonatomic, retain) NSMutableArray *adverMarr;    //广告
@property (nonatomic, retain) NSMutableArray *todayNewsModelMArr;    //社区头条
@property (nonatomic,strong) MBProgressHUD *progressHud;

@property (nonatomic, retain) UILabel *noticeLab;
@property (nonatomic, retain) UILabel *noticeDownLab;
@property (nonatomic, assign) BOOL loginAgaining;    //正在自动登录中（token过期后，要再次调用登录接口，这个Bool防止多个接口返回身份验证失败后，多次调用登录接口）
@property (nonatomic, assign) int nNewsShowingIndex;   //正在显示第几条社区头条
@property (nonatomic, strong) UILabel *localCommunityLab; //选择归属社区
@property (nonatomic, strong) UIImageView *scanImgView;
@property (nonatomic, strong) UIButton *scanBtn;
@property (nonatomic, strong) UIView *middleView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *moreBtn;

@property (nonatomic, strong) UIButton *localCommunityBtn;
@property (nonatomic, strong) UIImageView *localCommunityImgView;
@property (nonatomic, strong) DoorListViewController *menuVC;
@property (nonatomic,strong) AffineDrawer *drawer;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) CommunityListView *communityView;

@property (nonatomic, strong) SYNeiIPListModel *model;
@property (nonatomic, strong) SYPasswordOpenGuardViewController *passwordVC;
@property (nonatomic, strong) SYWebPageCtrl *webCtrl;
@property (nonatomic, strong) UIControl *backMask;

@property (nonatomic, retain) UICollectionViewFlowLayout *collectionViewFlowLayout;
@property (nonatomic, retain) UICollectionView *collectionView;
@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
}

- (void)initUI{
    
    self.adverMarr = [[NSMutableArray alloc] init];
    self.todayNewsModelMArr = [[NSMutableArray alloc] init];
    self.view.backgroundColor = UIColorFromRGB(0xebebeb);
    
    self.backMask = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [self.backMask setBackgroundColor:[UIColor clearColor]];
    [self.backMask addTarget:self action:@selector(closeComunity) forControlEvents:UIControlEventTouchUpInside];
    [self.backMask setAlpha:0.0f];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window.rootViewController.view addSubview:self.backMask];

    [self setTitleView];
    [self initCollectionView];
    
    self.progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHud.mode = MBProgressHUDModeIndeterminate;
    self.progressHud.label.text = @"加载中";
    self.progressHud.frame = CGRectMake(screenWidth * 0.5 - 50 - dockWidth, screenHeight * 0.5 - 50, 100, 100);
    
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    self.menuVC = [[DoorListViewController alloc] init];
    self.menuVC.view.hidden = YES;
    
    self.drawer = [[AffineDrawer alloc] initWithView:keyWindow.rootViewController.view menuView:self.menuVC.view menuFrame:CGRectMake(screenWidth, 0, self.view.frame.size.width * 0.7, screenHeight)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(closeDrawer)
                                                   name:@"closeDrawer"
                                                 object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeInforDetail)
                                                 name:@"closeInforDetail"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAdervert) name:@"refreshAdervert" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData:) name:@"loginSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGuard) name:SYNOTICE_REFRESH_GUARD object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHomePage:) name:SYNOTICE_Binded_Neighbor object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openVideo:) name:@"openVideo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openComingCall:) name:@"openComingCall" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openPassword:) name:@"openPassword" object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil ];
    
    [self selectFromDatabase];
    [self.view addSubview:self.progressHud];
}

- (void)selectFromDatabase
{
    NSDictionary *selectDict = [[NSDictionary alloc] initWithObjectsAndKeys:myUsername,@"username",myfneib_name,@"fneib_name", nil];
    self.todayNewsModelMArr = [[NSMutableArray alloc] initWithArray:[[MyFMDataBase shareMyFMDataBase] selectDataWithTableName:@"RecommandTable" withDic:selectDict]];
    if (self.todayNewsModelMArr.count == 0) {
        [self getRecommedList];
    }
    
    self.adverMarr = [[NSMutableArray alloc] initWithArray:[[MyFMDataBase shareMyFMDataBase] selectDataWithTableName:@"AdvertModel" withDic:selectDict]];
    if (self.adverMarr.count == 0) {
        [self getADpublishList];
    }
    
    [self.collectionView reloadData];
}

- (void)initCollectionView
{
    self.collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init]; // 自定义的布局对象
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.collectionViewFlowLayout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.collectionView.scrollEnabled = YES;
    self.collectionView.userInteractionEnabled = YES;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
   // self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 49, 0);
    self.collectionView.scrollIndicatorInsets = _collectionView.contentInset;
    [self.view addSubview:self.collectionView];
    
    // 注册cell、sectionHeader
    [self.collectionView registerClass:[SYHomeGuardCollectionViewCell class] forCellWithReuseIdentifier:HomeGuardCollectionViewCellID];
    [self.collectionView registerClass:[SYHomeBannerCollectionViewCell class] forCellWithReuseIdentifier:HomeBannerCollectionViewCellID];
    [self.collectionView registerClass:[SYHomeCommandMessageCollectionViewCell class] forCellWithReuseIdentifier:HomeCommandMessageCollectionViewCellID];
    [self.collectionView registerClass:[SYHomeCollectionViewHeaderCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId];
    
    WEAK_SELF;
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getRecommedList];
        [weakSelf getADpublishList];
    }];
    [self.collectionView setContentInset:UIEdgeInsetsMake(5, 0, 10, 0)];
}

- (void)closeInforDetail
{
    self.webCtrl.view.hidden = YES;
    self.passwordVC.view.hidden = YES;
    [self.passwordVC.view removeFromSuperview];
}

- (void)closeComunity
{
    [UIView animateWithDuration:0.2f animations:^{
        self.communityView.frame = CGRectMake(10, 70, self.titleView.frame.size.width - 60, 0);
        self.backMask.alpha = 0.0f;
    }];
    
}

- (void)refreshAdervert
{
    [self getRecommedList];
    [self getADpublishList];
}

- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation
{
    //[self.tableView reloadData];
    self.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[Common topViewController] isKindOfClass:[SYGuardMonitorViewController class]]) {
        [[Common topViewController] dismissViewControllerAnimated:NO completion:nil];
    }
    [self.collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //self.menuVC.view.frame = CGRectMake(screenWidth, 0, screenWidth * 0.7, screenHeight);
    //self.menuVC.view.hidden = YES;
}

- (void)refreshHomePage:(NSNotification *)notif
{
    self.localCommunityLab.text = notif.object;
    
    [self getADpublishList];
    [self getRecommedList];
    self.menuVC = [[DoorListViewController alloc] init];
    //[self.tableView reloadData];
    
    [UIView animateWithDuration:0.2f animations:^{
        self.communityView.frame = CGRectMake(10, 70, self.titleView.frame.size.width - 60, 0);
    }];
}

- (void)openVideo:(NSNotification *)notif
{
    //[self closeDrawer];
    //self.menuVC.view.hidden = NO;
    NSLog(@"模型==%@",notif.object);
    if ([[Common topViewController] isKindOfClass:[MainViewController class]]) {
        
        SYLockListModel *model = notif.object;
        SYGuardMonitorViewController *subAccountInfoViewController = [[SYGuardMonitorViewController alloc] initWithCall:nil GuardInfo:model InComingCall:NO];
        
        //    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        //    [delegate.window.rootViewController presentViewController:subAccountInfoViewController animated:YES completion:nil];
        
        [[Common topViewController] presentViewController:subAccountInfoViewController animated:YES completion:nil];
    }
}

- (void)openComingCall:(NSNotification *)notif
{
    SYGuardMonitorViewController *vc = notif.object;
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [delegate.window.rootViewController presentViewController:vc animated:YES completion:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

//- (void)openSecondComing:(NSNotification *)notif
//{
//    SYInComingCallViewController *vc = notif.object;
//    [self presentViewController:vc animated:YES completion:nil];
////    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
////    [delegate.window.rootViewController presentViewController:vc animated:YES completion:nil];
//}

- (void)openLockDoorList
{
    self.menuVC = [[DoorListViewController alloc] init];
    self.menuVC.LockSelectTag = otherTag;
    
    [self.drawer setContentView:self.menuVC.view];
    self.menuVC.view.hidden = NO;
    [self.drawer openDrawer];
}

//密码开锁
- (void)openPassword:(NSNotification *)notif
{
    SYLockListModel *model = notif.object;
    
    self.passwordVC = [[SYPasswordOpenGuardViewController alloc] initWithGuardInfo:model];
    [self.drawer setContentView:self.passwordVC.view];
    [self.drawer openDrawer];
}

//添加门禁后刷新
- (void)refreshGuard{
    
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
//    [self.tableView reloadData];
    [self.collectionView reloadData];
}

- (void)loadData:(NSNotification *)notif
{
    SYNeiIPListModel *model = notif.object;
    self.localCommunityLab.text = model.fneib_name;
}

- (void)openMonitor:(NSNotification*)notif
{
    [self closeDrawer];
    
    SYLockListModel *model = notif.object;
    
    SYGuardMonitorViewController *subAccountInfoViewController = [[SYGuardMonitorViewController alloc] initWithCall:nil GuardInfo:model InComingCall:NO];
    
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [delegate.window.rootViewController presentViewController:subAccountInfoViewController animated:YES completion:nil];
    [self presentViewController:subAccountInfoViewController animated:YES completion:nil];
}

- (void)closeDrawer
{
    [self.drawer closeDrawer];
    self.menuVC.view.hidden = YES;
}

- (void)viewWillLayoutSubviews
{
   // self.headerView.frame = CGRectMake(0, 0, screenWidth - dockWidth, 50);
   // self.moreBtn.frame = CGRectMake(screenWidth - dockWidth - 100, 5, 100, 50);

    self.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    
    self.backMask.frame = CGRectMake(0, screenHeight * 0.35, screenWidth, screenHeight * 0.65);
    
    //self.menuVC.view.frame = CGRectMake(screenWidth, 0, screenWidth * 0.7, screenHeight);
    self.drawer.mask.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    
    self.titleView.frame = CGRectMake(0, 20,  screenWidth - dockWidth, 40);
    self.communityView.frame = CGRectMake(10, 70, screenWidth - dockWidth - 60, self.communityView.frame.size.height);
    
    self.scanImgView.frame = CGRectMake(self.titleView.frame.size.width - self.titleView.height_sd - 5, 7, self.titleView.height_sd - 5, self.titleView.height_sd - 5);
    self.scanBtn.frame = self.scanImgView.frame;
    
    self.middleView.frame = CGRectMake(10, 5, self.titleView.frame.size.width - 60, self.titleView.height_sd - 0);
    self.localCommunityLab.frame = CGRectMake(30, 0, self.titleView.frame.size.width - 100, self.middleView.height_sd);
    self.localCommunityBtn.frame = self.localCommunityLab.frame;
    self.localCommunityImgView.center = CGPointMake(self.localCommunityImgView.centerX, self.titleView.height * 0.5);
    
    self.collectionView.frame = CGRectMake(0, CGRectGetMaxY(self.titleView.frame),  screenWidth - dockWidth, screenHeight - 50);
    [self.collectionView reloadData];
    
    SYHomeBannerCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:HomeBannerCollectionViewCellID forIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (self.adverMarr.count > 0) {
        [cell updateBannerInfo:self.adverMarr];
    }
}

//扫一扫，选择归属社区
- (void)setTitleView{
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 5,  self.view.width_sd, 50)];
    titleView.backgroundColor = UIColorFromRGB(0xebebeb);
    self.titleView = titleView;
    [self.view addSubview:self.titleView];
    
    //中间更换社区
    UIView *middleView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 200, titleView.height_sd - 5)];
    middleView.backgroundColor = [UIColor whiteColor];
    [titleView addSubview:middleView];
    middleView.layer.borderWidth = 1.0f;
    middleView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.middleView = middleView;
    
    UIImage *img = [UIImage imageNamed:@"sy_navigation_location_community"];
    UIImageView *localCommunityImgView = [[UIImageView alloc] initWithImage:img];
    [middleView addSubview:localCommunityImgView];
    self.localCommunityImgView = localCommunityImgView;

    
    self.localCommunityLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.titleView.frame.size.width - 100, middleView.height_sd)];
    self.localCommunityLab.textColor = UIColorFromRGB(0x999999);
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"fneib_name"]) {
        self.localCommunityLab.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"fneib_name"];
    }else{
        self.localCommunityLab.text = @"选择归属社区";
    }
    self.localCommunityLab.font = [UIFont systemFontOfSize:14];
    [middleView addSubview:self.localCommunityLab];
    
    UIButton *localCommunityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    localCommunityBtn.tag = changeCommunityClickTag;
    [localCommunityBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [middleView addSubview:localCommunityBtn];
    self.localCommunityBtn = localCommunityBtn;
    
    //扫一扫
    img = [UIImage imageNamed:@"sy_navigation_scan"];
    UIImageView *scanImgView = [[UIImageView alloc] initWithImage:img];
    scanImgView.contentMode = UIViewContentModeScaleAspectFit;
    self.scanImgView = scanImgView;
    [self.titleView addSubview:scanImgView];
    
    UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [scanBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [scanBtn setBackgroundColor:[UIColor clearColor]];
    scanBtn.tag = scanClickTag;
    self.scanBtn = scanBtn;
    [self.titleView addSubview:scanBtn];
    
    CommunityListView *communityView = [[CommunityListView alloc] initWithFrame:CGRectMake(10, 70, self.titleView.frame.size.width - 60, 0)];
    communityView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:communityView];
    self.communityView = communityView;

}

#pragma mark - event
- (void)btnClick:(UIButton *)btn{
    
    if (btn.tag == headerClickTag) {
        
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
        
        
    }else if (btn.tag == changeCommunityClickTag) {
        //切换社区
        if (self.communityView.frame.size.height > 0) {
            [UIView animateWithDuration:0.2f animations:^{
                self.communityView.frame = CGRectMake(10, 70, self.titleView.frame.size.width - 60, 0);
            }];
        }else{
            [UIView animateWithDuration:0.2f animations:^{
                self.communityView.frame = CGRectMake(10, 70, self.titleView.frame.size.width - 60, 200);
                self.backMask.alpha = 0.02f;
            }];
        }
        
    }else if (btn.tag == moreLock) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"allLocks" object:nil];
        self.menuVC.LockSelectTag = otherTag;
        self.menuVC.view.hidden = NO;
        [self openLockDoorList];
        
    }else if (btn.tag == moreNews) {
        //更多社区头条
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"moreNews" object:nil];
    }
}

- (void)addNewDoor:(NSInteger)selectIndex
{
    self.menuVC = [[DoorListViewController alloc] init];
    self.menuVC.clickIndex = selectIndex;
    self.menuVC.LockSelectTag = addTag;
    //更多门锁
    [[NSNotificationCenter defaultCenter] postNotificationName:@"allLocks" object:nil];
    
    [self.drawer setContentView:self.menuVC.view];
    self.menuVC.view.hidden = NO;
    [self.drawer openDrawer];
}

- (void)changeNewDoor:(UIButton *)btn
{
    self.menuVC.clickIndex = btn.tag;
    self.menuVC.LockSelectTag = changeTag;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"allLocks" object:nil];
    [self.drawer setContentView:self.menuVC.view];
    self.menuVC.view.hidden = NO;
    [self.drawer openDrawer];
}

- (void)deleteNewDoor:(UIButton *)btn
{
//    self.menuVC.clickIndex = selectIndex;
//    self.menuVC.LockSelectTag = deleteTag;
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"allLocks" object:nil];
//    [self.drawer openDrawer];
    
    [self guardDelete:btn.tag];
}

//删除门锁
- (void)guardDelete:(NSInteger)selectIndex
{
    
    if (![SYAppConfig shareInstance].selectedGuardMArr) {
        [SYAppConfig shareInstance].selectedGuardMArr = [[NSMutableArray alloc] init];
    }
    
    if ([SYAppConfig shareInstance].selectedGuardMArr.count >= selectIndex) {
        [[SYAppConfig shareInstance].selectedGuardMArr removeObjectAtIndex:selectIndex];
        [SYAppConfig saveMyHistoryNeighborLockList];
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_REFRESH_GUARD object:nil];
    }
}


#pragma mark - 门禁delegate
//点击添加门禁按钮
- (void)addGuardClick:(NSIndexPath *)indexPath LockListModel:(SYLockListModel *)model
{
    
}

//点击门禁
- (void)guardClick:(NSIndexPath *)indexPath LockListModel:(SYLockListModel *)model
{
    SYLinphoneCall *call = [[SYLinphoneManager instance] callByCallId:model.sip_number];
    
    SYGuardMonitorViewController *subAccountInfoViewController = [[SYGuardMonitorViewController alloc] initWithCall:call GuardInfo:model InComingCall:NO];
    [self presentViewController:subAccountInfoViewController animated:YES completion:nil];
}

#pragma mark - 获取推荐列表
- (void)getRecommedList
{
    if (![SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id) {
        return;
    }
    
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    
    WEAK_SELF;
    [self.progressHud showAnimated:YES];
    [communityHttpDAO getRecommendListWithNeighborID:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id Succeed:^(NSArray *modelArr) {
        [weakSelf.collectionView.mj_header endRefreshing];
        [self.progressHud hideAnimated:YES];
        
        [weakSelf.todayNewsModelMArr removeAllObjects];
        if (modelArr.count > 0) {
            weakSelf.todayNewsModelMArr = [[NSMutableArray alloc] initWithArray:modelArr];
            
            //删除已有的数据库
            NSString *username = [SYLoginInfoModel shareUserInfo].userInfoModel.username;
            NSString *fneib_name = [[NSUserDefaults standardUserDefaults] objectForKey:@"fneib_name"];

            NSDictionary *deleteDict = [[NSDictionary alloc] initWithObjectsAndKeys:username,@"username",fneib_name,@"fneib_name", nil];
            [[MyFMDataBase shareMyFMDataBase] deleteDataWithTableName:@"RecommandModel" delegeteDic:deleteDict];
            
            for (SYAdpublishModel *myModel in modelArr) {
                
                NSDictionary *insertDict = [[NSDictionary alloc] initWithObjectsAndKeys:myModel.ftitle,@"ftitle",myModel.fpictureurl,@"fpictureurl",myModel.fcreatetime,@"fcreatetime",myModel.fnewsurl,@"fnewsurl",myModel.adID,@"adID",myModel.fcontent,@"fcontent",[NSNumber numberWithInt:myModel.type],@"type",username,@"username",fneib_name,@"fneib_name", nil];
                
                [[MyFMDataBase shareMyFMDataBase] insertDataWithTableName:@"RecommandTable" insertDictionary:insertDict];
            }
        }
        [weakSelf.collectionView reloadData];
        
    } fail:^(NSError *error) {
        [self.progressHud hideAnimated:YES];
        [weakSelf.todayNewsModelMArr removeAllObjects];
        [weakSelf.collectionView reloadData];
        [weakSelf.collectionView.mj_header endRefreshing];
    }];
}

#pragma mark -- 获取广告图
- (void)getADpublishList{
    
    if (![SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id) {
        return;
    }
    
    WEAK_SELF;
    [self.progressHud showAnimated:YES];
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    
    [communityHttpDAO getAdvertismentWithNeighborID:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id WithUserName:[SYLoginInfoModel shareUserInfo].userInfoModel.username Succeed:^(NSArray *modelArr) {
        
        [weakSelf.collectionView.mj_header endRefreshing];
        [self.progressHud hideAnimated:YES];
        
        if (modelArr.count > 0) {
            [weakSelf.adverMarr removeAllObjects];
            
            //删除已有的数据库
            NSString *username = [SYLoginInfoModel shareUserInfo].userInfoModel.username;
            NSString *fneib_name = [[NSUserDefaults standardUserDefaults] objectForKey:@"fneib_name"];
            
            NSDictionary *deleteDict = [[NSDictionary alloc] initWithObjectsAndKeys:username,@"username",fneib_name,@"fneib_name", nil];
            [[MyFMDataBase shareMyFMDataBase] deleteDataWithTableName:@"AdvertModel" delegeteDic:deleteDict];
            
            for (int i=0; i<modelArr.count; i++) {
                SYAdvertInfoListModel *model = [modelArr objectAtIndex:i];
                if ([model.fposition isEqualToString:@"1"]) {
                    [weakSelf.adverMarr addObject:model];
                    
                    SYAdvertInfoModel *advertModel = model.pic_list[0];
                    NSDictionary *insertDict = [[NSDictionary alloc] initWithObjectsAndKeys:advertModel.fredirecturl,@"fredirecturl",advertModel.img_path,@"img_path",username,@"username",fneib_name,@"fneib_name", nil];
                    NSLog(@"图片==%@,%@",advertModel.img_path,advertModel.fredirecturl);
                    
                    [[MyFMDataBase shareMyFMDataBase] insertDataWithTableName:@"AdvertModel" insertDictionary:insertDict];
                }
            }
            [weakSelf.collectionView reloadData];
        }else{
            [weakSelf.adverMarr removeAllObjects];
            [weakSelf.collectionView reloadData];
        }
        
    } fail:^(NSError *error) {
        [weakSelf.collectionView.mj_header endRefreshing];
        [self.progressHud hideAnimated:YES];
        [weakSelf.adverMarr removeAllObjects];
        [weakSelf.collectionView reloadData];
        
    }];
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


#pragma mark - tableview delegate
/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 2) {
        return self.todayNewsModelMArr.count;
    }
    
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
            
        case 0:
            return SYHomeBannerTableViewCellHeight;
            break;
        case 1:
            
            return (screenWidth - dockWidth) * (170 / 300.0);
            break;
        case 2:
            return SYDiscoverCommunityNewsTableViewCellHeight;
            break;
        default:
            return 0;
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth - dockWidth, 50)];
    self.headerView = view;
    view.backgroundColor = UIColorFromRGB(0xebebeb);
    
    if (section == 0) {
        return view;
    }
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20, 20, 20)];
    icon.image = [UIImage imageNamed:@"Rectangle 20"];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:icon];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:15.0f];
    label.frame = CGRectMake(30, 5, 100, 50);
    [view addSubview:label];
    
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(screenWidth - dockWidth - 100, 5, 100, 50);
    [moreBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [moreBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [view addSubview:moreBtn];
    [moreBtn setImage:[UIImage imageNamed:@"sy_me_rightArrow"] forState:UIControlStateNormal];
    [moreBtn setFont:[UIFont systemFontOfSize:14.0f]];
    [moreBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    self.moreBtn = moreBtn;
    
    if (section == 1) {
        label.text = @"快捷开锁";
        [moreBtn setTitle:@"更多门锁" forState:UIControlStateNormal];
        moreBtn.tag = moreLock;
        [moreBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 50, 0, -70)];
    }else if (section == 2) {
        label.text = @"推荐";
        [moreBtn setTitle:@"更多" forState:UIControlStateNormal];
        moreBtn.tag = moreNews;
        [moreBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 50, 0, -10)];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 30.0f;
    }
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        static NSString *identify = @"SYHomeBannerTableViewCell";
        SYHomeBannerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[SYHomeBannerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.contentView.backgroundColor = UIColorFromRGB(0xebebeb);
        cell.bannerView.hidden = NO;
        cell.pageControl.hidden = NO;
        
        [cell updateBannerInfo:self.adverMarr];
        return cell;
    }
    else if (indexPath.section == 1){
        //门禁
        static NSString *identify = @"SYHomeGuardTableViewCell";
        SYHomeGuardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[SYHomeGuardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
        }
        cell.contentView.backgroundColor = UIColorFromRGB(0xebebeb);
        [cell reloadGuardCollectionView];
        
        return cell;
    }
    else{
        static NSString *identify = @"SYDiscoverCommunityNewsTableViewCell";
        
        SYDiscoverCommunityNewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[SYDiscoverCommunityNewsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (indexPath.row % 2 == 0) {
            cell.mainView.backgroundColor = [UIColor clearColor];
        }else{
            cell.mainView.backgroundColor = [UIColor whiteColor];
        }
        
        SYRecommendModel *model = [self.todayNewsModelMArr objectAtIndex:indexPath.row];        
        [cell updateNews:model];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
 
}
*/

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 1) {
        return 4;
    }else if (section == 2) {
        return self.todayNewsModelMArr.count;
    }
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        //轮播图
        SYHomeBannerCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:HomeBannerCollectionViewCellID forIndexPath:indexPath];
        [cell updateBannerInfo:self.adverMarr];
        [cell setTapActionBlock:^(NSString *fredirecturl) {
            self.webCtrl = [[SYWebPageCtrl alloc] initWithUrl:fredirecturl title:@""];
            [self.drawer setContentView:self.webCtrl.view];
            [self.drawer openDrawer];
        }];
        
        return cell;
    }else if (indexPath.section == 1){
        SYHomeGuardCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:HomeGuardCollectionViewCellID forIndexPath:indexPath];
        //cell.delegate = self;
        SYLockListModel *model = nil;
        cell.indexPath = indexPath;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        if ([SYAppConfig shareInstance].selectedGuardMArr.count > indexPath.row) {
            model = [[SYAppConfig shareInstance].selectedGuardMArr objectAtIndex:indexPath.row];
        }
        [cell updateguardName:model];
        cell.lockChangeBtn.tag = indexPath.row;
        [cell.lockChangeBtn addTarget:self action:@selector(changeNewDoor:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.lockDeleteBtn.tag = indexPath.row;
        [cell.lockDeleteBtn addTarget:self action:@selector(deleteNewDoor:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }else{
        SYHomeCommandMessageCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:HomeCommandMessageCollectionViewCellID forIndexPath:indexPath];
        
        if (self.todayNewsModelMArr.count > indexPath.row) {
            SYAdpublishModel *model  = [self.todayNewsModelMArr objectAtIndex:indexPath.row];
            [cell updateRecommandInfo:model ShowTag:YES];
        }
        return cell;
    }
}

// 和UITableView类似，UICollectionView也可设置段头段尾
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        SYHomeCollectionViewHeaderCollectionReusableView *headerView = [_collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerId forIndexPath:indexPath];
        if(headerView == nil)
        {
            headerView = [[SYHomeCollectionViewHeaderCollectionReusableView alloc] init];
        }
        
        if (indexPath.section == 1) {
            [headerView updateTitle:@"快捷开锁" moreLabel:@"全部门锁"];
        }else if (indexPath.section == 2) {
            [headerView updateTitle:@"推荐" moreLabel:@"更多"];
        }
        
        [headerView setClickCallBack:^{
            
            if (indexPath.section == 1) {
                //全部门禁
                [[NSNotificationCenter defaultCenter] postNotificationName:@"allLocks" object:nil];
                self.menuVC.LockSelectTag = otherTag;
                self.menuVC.view.hidden = NO;
                [self openLockDoorList];
                
            }else if (indexPath.section == 2) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"moreNews" object:nil];
            }
        }];
        return headerView;
    }
    
    return nil;
}


#pragma mark ---- UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {//banner
        return (CGSize){screenWidth - dockWidth , SYHomeBannerCollectionViewCellHeight};
    }
    else if (indexPath.section == 2) {
        return (CGSize){screenWidth - dockWidth , 70};
    }
    
    return (CGSize){(screenWidth - dockWidth - 20) * 0.5 , (screenWidth - dockWidth - 20) * 0.5 * 0.7};
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (section == 2) {
        return 5;
    }
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

//定义每个Section的四边间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);//分别为上、左、下、右
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return (CGSize){kScreenWidth - dockWidth, 0};
    }
    
    return (CGSize){kScreenWidth - dockWidth, SYHomeCollectionViewHeaderCollectionReusableViewHeight};
}

// 选中某item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        SYHomeGuardCollectionViewCell *cell = (SYHomeGuardCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if ([cell.guardNameLab.text isEqualToString:@"添加门锁"]) {

            [[NSNotificationCenter defaultCenter] postNotificationName:@"allLocks" object:nil];
            [self.drawer setContentView:self.menuVC.view];
            self.menuVC.LockSelectTag = addTag;
            self.menuVC.view.hidden = NO;
            [self.drawer openDrawer];
        }
    }else if (indexPath.section == 2) {
        
        SYRecommendModel *model = [self.todayNewsModelMArr objectAtIndex:indexPath.row];
        
        self.webCtrl = [[SYWebPageCtrl alloc] initWithUrl:model.fnewsurl title:model.ftitle];
        [self.drawer setContentView:self.webCtrl.view];
        [self.drawer openDrawer];
    }
}

#pragma mark - UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
