//
//  DiscoverViewController.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/7/3.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "DiscoverViewController.h"
#import "SYHomeBannerTableViewCell.h"
#import "MJRefresh.h"
#import "SYCommunityHttpDAO.h"
#import "SYDiscoverCommunityNewsTableViewCell.h"
#import "AffineDrawer.h"
#import "InfomationViewController.h"
#import "SYRecommandView.h"

@interface DiscoverViewController ()<UITableViewDelegate,UITableViewDataSource>{
    dispatch_source_t _timer;
}
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *adverMarr;    //广告
@property (nonatomic, retain) NSMutableArray *sourcesMArr;    //头条列表

@property (nonatomic, retain) UILabel *noticeLab;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic,strong) MBProgressHUD *progressHud;

@property (nonatomic, retain) UILabel *noticeDownLab;
@property (nonatomic, assign) BOOL loginAgaining;    //正在自动登录中（token过期后，要再次调用登录接口，这个Bool防止多个接口返回身份验证失败后，多次调用登录接口）
@property (nonatomic, assign) int nNewsShowingIndex;   //正在显示第几条社区头条

@property (nonatomic, strong) UIView *HeadTopView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIView *segmentBottomLine;

@property (nonatomic, strong) InfomationViewController *menuVC;
@property (nonatomic,strong) AffineDrawer *drawer;
@property (nonatomic, strong) SYCustomScrollView *customScrollView;
@property (nonatomic, strong) SYDiscoverCommunityNewsView *discoverCommunityNewsView;
@property (nonatomic, strong) SYDiscoverAppCommandView *discoverAppCommandView;
@property (nonatomic, strong) SYRecommandView *recommandView;

@property (nonatomic, strong) SYWebPageCtrl *webCtrl;
@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(0xebebeb);
    [self initUI];
    [self getAdvertiseList];
}

- (void)initUI
{
    self.adverMarr = [[NSMutableArray alloc] init];
    
    UIView *HeadTopView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth - dockWidth, 50)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:HeadTopView.bounds];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel = titleLabel;
    titleLabel.text = @"周边资讯";
    [HeadTopView addSubview:titleLabel];
    [self.view addSubview:HeadTopView];
    self.HeadTopView = HeadTopView;
    
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
    
    WEAK_SELF;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getAdvertiseList];
    }];
    
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    self.menuVC = [[InfomationViewController alloc] init];

    self.drawer = [[AffineDrawer alloc] initWithView:keyWindow.rootViewController.view menuView:self.menuVC.view menuFrame:CGRectMake(screenWidth, 0, self.view.frame.size.width * 0.7, screenHeight)];
    
    self.customScrollView = [[SYCustomScrollView alloc] initWithFrame:CGRectMake(0, 0, (screenWidth - dockWidth), self.view.height_sd)];
    self.customScrollView.contentSize = CGSizeMake((screenWidth - dockWidth) * 3, 0);
    self.customScrollView.delegate = self;
    self.customScrollView.backgroundColor = UIColorFromRGB(0xebebeb);
    self.customScrollView.pagingEnabled = YES;
    self.customScrollView.bounces = NO;
    self.customScrollView.showsVerticalScrollIndicator = NO;
    self.customScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.customScrollView.showsHorizontalScrollIndicator = NO;
    
    self.recommandView = [[SYRecommandView alloc] initWithFrame:[self getPropertyViewRect:0]];
    self.discoverCommunityNewsView = [[SYDiscoverCommunityNewsView alloc] initWithFrame:[self getPropertyViewRect:1]];
    self.discoverAppCommandView = [[SYDiscoverAppCommandView alloc] initWithFrame:[self getPropertyViewRect:2]];
    
    [self.customScrollView addSubview:self.recommandView];
    [self.customScrollView addSubview:self.discoverCommunityNewsView];
    [self.customScrollView addSubview:self.discoverAppCommandView];
    
    self.progressHud = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHud.mode = MBProgressHUDModeIndeterminate;
    self.progressHud.label.text = @"加载中";
    self.progressHud.frame = CGRectMake(screenWidth * 0.5 - 100, screenHeight * 0.5 - 50, 100, 100);
    [self.view addSubview:self.progressHud];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeDrawer)
                                                 name:@"closeDrawer"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPage) name:@"refreshAdervert" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPage) name:@"refreshPage" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openDiscoverWebpage:) name:@"openDiscoverWebpage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openToutiaoWebpage:) name:@"openToutiaoWebpage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openAdvertWebpage:) name:@"openAdvertWebpage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeAdvertiseDrawer) name:@"closeAdvertiseDrawer" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPage) name:@"refreshPage" object:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil ];
}

- (void)closeAdvertiseDrawer
{
    self.webCtrl.view.hidden = YES;
}

- (void)closeDrawer
{
    [self.drawer closeDrawer];
}

- (void)refreshPage
{
    [self getAdvertiseList];
}

- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation
{
    self.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.customScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    WEAK_SELF;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.segmentBottomLine.frame = CGRectMake(weakSelf.segmentedControl.selectedSegmentIndex * weakSelf.segmentBottomLine.frame.size.width, weakSelf.segmentBottomLine.frame.origin.y, weakSelf.segmentBottomLine.frame.size.width, weakSelf.segmentBottomLine.frame.size.height);
    }];
}

- (void)openDiscoverWebpage:(NSNotification *)notif
{
    SYRecommendModel *model = notif.object;
    
    self.webCtrl = [[SYWebPageCtrl alloc] initWithUrl:model.fnewsurl title:model.ftitle];
    [self.drawer setContentView:self.webCtrl.view];
    [self.drawer openDrawer];
}

- (void)openToutiaoWebpage:(NSNotification *)notif
{
    SYTodayNewsModel *model = notif.object;
    
    self.webCtrl = [[SYWebPageCtrl alloc] initWithUrl:model.news_url title:model.title];
    [self.drawer setContentView:self.webCtrl.view];
    [self.drawer openDrawer];
}

- (void)openAdvertWebpage:(NSNotification *)notif
{
    SYAdvertInfoListModel *model = notif.object;
    
    if (model.pic_list.count > 0) {
        SYAdvertInfoModel *picModel = [model.pic_list objectAtIndex:0];
        self.webCtrl = [[SYWebPageCtrl alloc] initWithUrl:picModel.fredirecturl title:model.ftitle];
        [self.drawer setContentView:self.webCtrl.view];
        [self.drawer openDrawer];
    }
}

- (void)viewWillLayoutSubviews
{
    self.drawer.mask.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    self.customScrollView.frame = CGRectMake(0, 0, (screenWidth - dockWidth), screenHeight );
    self.customScrollView.contentSize = CGSizeMake((screenWidth - dockWidth) * 3, 0);
    
    self.recommandView.frame = [self getPropertyViewRect:0];
    self.discoverCommunityNewsView.frame = [self getPropertyViewRect:1];
    self.discoverAppCommandView.frame = [self getPropertyViewRect:2];
    
    
    self.HeadTopView.frame = CGRectMake(0, 20, screenWidth - dockWidth, 50);
    self.titleLabel.frame = self.HeadTopView.bounds;
    self.lineView.frame = CGRectMake(0, 50, screenWidth - dockWidth, 1);
    
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.HeadTopView.frame) + 15, screenWidth - dockWidth, screenHeight - self.HeadTopView.frame.size.height);
}

//"应用推荐", @"社区头条" 的frame
- (CGRect)getPropertyViewRect:(NSInteger)index {
    CGRect rect = CGRectMake((screenWidth - dockWidth) * index, 0, screenWidth - dockWidth, self.customScrollView.height_sd);
    return rect;
}

#pragma mark - 获取广告和资讯
- (void)getAdvertiseList{
    
    WEAK_SELF;
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    
    [self.progressHud showAnimated:YES];
    [communityHttpDAO getAdvertismentWithNeighborID:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id WithUserName:[SYLoginInfoModel shareUserInfo].userInfoModel.username Succeed:^(NSArray *modelArr) {
        
        [self.progressHud hideAnimated:YES];
        [weakSelf.tableView.mj_header endRefreshing];
        
        [weakSelf.adverMarr removeAllObjects];
        
        for (int i=0; i<modelArr.count; i++) {
            SYAdvertInfoListModel *model = [modelArr objectAtIndex:i];
            if ([model.fposition isEqualToString:@"1"]) {
                [weakSelf.adverMarr addObject:model];
            }
        }
        
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        
    } fail:^(NSError *error) {
        [Common addAlertWithTitle:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
        [weakSelf.tableView.mj_header endRefreshing];
        [self.progressHud hideAnimated:YES];
        
        [weakSelf.adverMarr removeAllObjects];
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)getSegmentalView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
    view.backgroundColor = [UIColor clearColor];
    
    NSArray *itemArr = [[NSArray alloc] initWithObjects:@"推荐", @"资讯", @"头条", nil];
    
    float fSegmentedControlHeight = 40;
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArr];
    segmentedControl.frame = CGRectMake(14, 10, 200, fSegmentedControlHeight);
    segmentedControl.backgroundColor = [UIColor clearColor];
    segmentedControl.tintColor = [UIColor clearColor];
    [segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x999999), NSFontAttributeName : [UIFont systemFontOfSize:14.0]} forState:UIControlStateNormal];
    [segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName :  [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:16.0]} forState:UIControlStateSelected];
    [segmentedControl addTarget:self action:@selector(segmentedControlSelect:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl = segmentedControl;
    [view addSubview:segmentedControl];
    
    self.segmentBottomLine = [[UIView alloc] initWithFrame:CGRectMake(self.segmentedControl.selectedSegmentIndex * (self.segmentedControl.width / itemArr.count), fSegmentedControlHeight - 4, (self.segmentedControl.width + 0) / itemArr.count, 4)];
    self.segmentBottomLine.backgroundColor = UIColorFromRGB(0xf23023);
    [self.segmentedControl addSubview:self.segmentBottomLine];
    
    return view;
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        return SYHomeBannerTableViewCellHeight;
    }else if (indexPath.section == 1) {
        return 50;
    }
    else{
        return self.view.height_sd - 60;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        static NSString *identify = @"SYHomeBannerTableViewCell";
        SYHomeBannerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[SYHomeBannerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.bannerView.hidden = NO;
        cell.pageControl.hidden = NO;
        [cell updateBannerInfo:self.adverMarr];
        
        return cell;
    }else{
        
        static NSString *identify = @"tableviewCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (indexPath.section == 1) {
            [cell.contentView addSubview:[self getSegmentalView]];
        }else{
            [cell.contentView addSubview:self.customScrollView];
        }
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //[self.drawer openDrawer];
}

#pragma mark - event
- (void)segmentedControlSelect:(UISegmentedControl *)segmentedCtl{
    
    [self.customScrollView setContentOffset:CGPointMake((screenWidth - dockWidth) * segmentedCtl.selectedSegmentIndex, 0) animated:YES];
    
    WEAK_SELF;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.segmentBottomLine.frame = CGRectMake(weakSelf.segmentedControl.selectedSegmentIndex * weakSelf.segmentBottomLine.frame.size.width, weakSelf.segmentBottomLine.frame.origin.y, weakSelf.segmentBottomLine.frame.size.width, weakSelf.segmentBottomLine.frame.size.height);
    }];
}

#pragma mark - scrollview delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    double currentPage = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
    
    double page = ceilf(currentPage);
    if (self.segmentedControl.selectedSegmentIndex == page) {
        return;
    }
    
    WEAK_SELF;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.segmentBottomLine.frame = CGRectMake(page * weakSelf.segmentBottomLine.frame.size.width, weakSelf.segmentBottomLine.frame.origin.y, weakSelf.segmentBottomLine.frame.size.width, weakSelf.segmentBottomLine.frame.size.height);
    }];
    self.segmentedControl.selectedSegmentIndex = page;
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
