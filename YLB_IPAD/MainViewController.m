//
//  FirstViewController.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/6/26.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "MainViewController.h"
#import "YLBDock.h"
#import "HomePageViewController.h"
#import "SYLoginHttpDAO.h"
#import "SYPersonalSpaceHttpDAO.h"
#import "PCCircleViewConst.h"
#import "DiscoverViewController.h"
#import "MyInfoViewController.h"
#import "MessageViewController.h"
#import "ViewcontrollersManager.h"
#import "QRCodeViewController.h"
#import "SYGuardMonitorViewController.h"
#import "YLBDockItem.h"

@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource,DockDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) YLBDock *dock;
@property (nonatomic, strong) UIView *underSubView;
@property (nonatomic, strong) QRCodeViewController *qrVC;

@property (nonatomic, strong) HomePageViewController *secVC;
@property (nonatomic, strong) DiscoverViewController *disVC;
@property (nonatomic, strong) MyInfoViewController *infoVC;
@property (nonatomic, strong) MessageViewController *mesVC;

@property (nonatomic,strong) MBProgressHUD *progressHud;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [ViewcontrollersManager shareMgr].insetVC = self;
    
    [self.progressHud showAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHeader:) name:@"updateHeader" object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openMonitor:)
                                                 name:@"openMonitor"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initUI) name:@"loginSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLoginImage:) name:@"updateLoginImage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginAgain) name:@"loginAgain" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moreNews) name:@"moreNews" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginAgain) name:SYNOTICE_ResponseIdentifyAuthenticationErrorCode object:nil];
    
    [SYLoginInfoModel shareUserInfo].userInfoModel.user_id = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] longValue];
    BOOL isLogin = [SYAppConfig getUserLoginInfoWithUserID:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id];
    
    if (isLogin && [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"alreadyLogin"] isEqualToString:@"1"]) {
        
        [self initUI];
        [self updateHeaderWithDefault];
        
    }else{
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initUI) name:@"loginSuccess" object:nil];
        
        self.qrVC = [[QRCodeViewController alloc] init];
        [self.view addSubview:self.qrVC.view];
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLoginImage:) name:@"updateLoginImage" object:nil];
    }
}



- (void)moreNews
{
    for (int i=0; i<self.dock.arrayButtons.count; i++) {
        YLBDockItem *item = [self.dock.arrayButtons objectAtIndex:i];
        item.backgroundColor = [UIColor clearColor];
        item.selected = NO;
        
        if (i == 1) {
            item.backgroundColor = [UIColor redColor];
            item.selected = YES;
        }
    }

    [self addChildViewController:self.disVC];
    
    UIView *firstView = self.rightView.subviews.firstObject;
    [firstView removeFromSuperview];
    
    [self.rightView addSubview:self.disVC.view];
    self.underSubView = self.disVC.view;
}

- (void)loginAgain
{
    self.qrVC = [[QRCodeViewController alloc] init];
    [self.view addSubview:self.qrVC.view];
}

- (void)updateLoginImage:(NSNotification *)notif
{
    NSString *headurl = notif.object;
    [self updateHeadImage:headurl];
}

- (void)updateHeadImage:(NSString *)headurl
{
    NSData *dataImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:headurl]];
    self.qrVC.headImage.image = [UIImage imageWithData:dataImg];
    
    [self.qrVC.headImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",headurl]]  placeholderImage:[UIImage imageNamed:@"sy_navigation_normal_header"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            self.qrVC.headImage.image = image;
        }
    }];
    
    self.qrVC.scanSuccessBack.hidden = NO;
    self.qrVC.whiteBack.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateHeader:(NSNotification *)nofi
{
    SYPersonalSpaceModel *model = (SYPersonalSpaceModel *)nofi.object;
    
    if (model.alias.length > 0) {
        self.dock.nickName.text = model.alias;
    }else{
        NSString *userName = [SYLoginInfoModel shareUserInfo].userInfoModel.username;
        self.dock.nickName.text = [userName substringFromIndex:userName.length - 2];
    }
    
    if (model.head_url.length > 0) {
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.head_url]];
        self.dock.headImage.image = [UIImage imageWithData:imgData];
    }
    
    [self.dock.headImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",model.head_url]]  placeholderImage:[UIImage imageNamed:@"sy_navigation_normal_header"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            self.dock.headImage.image = image;
        }
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:model.head_url forKey:@"headurl"];
    [[NSUserDefaults standardUserDefaults] setObject:model.alias forKey:@"nickName"];
    [[NSUserDefaults standardUserDefaults] setObject:model.motto forKey:@"motto"];
}

- (void)updateHeaderWithDefault
{
    NSString *headurl = [[NSUserDefaults standardUserDefaults] objectForKey:@"headurl"];
    NSString *nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"];
    
    if (nickName.length > 0) {
        self.dock.nickName.text = nickName;
    }else{
        NSString *userName = [SYLoginInfoModel shareUserInfo].userInfoModel.username;
        self.dock.nickName.text = [userName substringFromIndex:userName.length - 2];
    }
    
    [self.dock.headImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",headurl]]  placeholderImage:[UIImage imageNamed:@"sy_navigation_normal_header"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            self.dock.headImage.image = image;
        }
    }];
}

- (void)initUI{
    
    UIView *CodeView = self.view.subviews.firstObject;
    [CodeView removeFromSuperview];
    
    self.rightView = [[UIView alloc] init];
    [self.view addSubview:self.rightView];
    
    self.dock = [[YLBDock alloc] init];
    self.dock.backgroundColor = [UIColor whiteColor];
    self.dock.delgeate = self;
    [self.view addSubview:self.dock];
    
    self.secVC = [[HomePageViewController alloc] init];
    [self addChildViewController:self.secVC];
    UIView *firstView = self.rightView.subviews.firstObject;
    [firstView removeFromSuperview];
    
    [self.rightView addSubview:self.secVC.view];
    self.underSubView = self.secVC.view;
    
    self.disVC = [[DiscoverViewController alloc] init];
    self.infoVC = [[MyInfoViewController alloc] init];
    self.mesVC = [[MessageViewController alloc] init];
}

- (void)openMonitor:(NSNotification*)notif
{
    SYLockListModel *model = notif.object;
    
    SYGuardMonitorViewController *subAccountInfoViewController = [[SYGuardMonitorViewController alloc] initWithCall:nil GuardInfo:model InComingCall:NO];
    [self presentViewController:subAccountInfoViewController animated:YES completion:nil];
}

- (void)initAllSubViews
{
    /*
     HomePageViewController *secVC = [[HomePageViewController alloc] init];
     [self addChildViewController:secVC];
     
     UIView *firstView = self.rightView.subviews.firstObject;
     [firstView removeFromSuperview];
     
     [self.rightView addSubview:secVC.view];
     self.underSubView = secVC.view;
     */
}

#pragma mark -- DockDelegate
- (void)touchButton:(NSInteger)tagNum
{
    switch (tagNum) {
        case 0:{
            [self addChildViewController:self.secVC];
            
            UIView *firstView = self.rightView.subviews.firstObject;
            [firstView removeFromSuperview];
            
            [self.rightView addSubview:self.secVC.view];
            self.underSubView = self.secVC.view;
            break;
        }
        case 1:
        {
            [self addChildViewController:self.disVC];
            
            UIView *firstView = self.rightView.subviews.firstObject;
            [firstView removeFromSuperview];
            
            [self.rightView addSubview:self.disVC.view];
            self.underSubView = self.disVC.view;
            break;
        }
        case 2:
        {
            [self addChildViewController:self.infoVC];
            
            UIView *firstView = self.rightView.subviews.firstObject;
            [firstView removeFromSuperview];
            
            [self.rightView addSubview:self.infoVC.view];
            self.underSubView = self.infoVC.view;
            break;
        }
        case 3:
        {
            [self addChildViewController:self.mesVC];
            
            UIView *firstView = self.rightView.subviews.firstObject;
            [firstView removeFromSuperview];
            
            [self.rightView addSubview:self.mesVC.view];
            self.underSubView = self.mesVC.view;
            break;
        }
        default:
            break;
    }
}

- (void)addChildViewcontrollers:(UIViewController*)vc
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self addChildViewController:nav];
}

- (void)viewWillLayoutSubviews
{
    self.view.frame = CGRectMake(0, 0, screenWidth , screenHeight);
    
    self.dock.frame = CGRectMake(0, 0, dockWidth, screenHeight);
    self.rightView.frame = CGRectMake(self.dock.frame.size.width, 0, screenWidth - self.dock.frame.size.width, screenHeight);
    self.underSubView.frame = self.rightView.bounds;
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 10)];
    label.text = @"2016年";
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *identify = @"SYPropertyHistoryCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        //cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = @"测试";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
