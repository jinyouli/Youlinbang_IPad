//
//  MessageViewController.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/7/3.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "MessageViewController.h"
#import "SYMyMessageTableViewCell.h"
#import "MJRefresh.h"
#import "SYDiscoverHttpDAO.h"
#import "SYPersonalSpaceTableViewCell.h"
#import "AffineDrawer.h"
#import "InfomationViewController.h"

#import "PersonalMessageCtrl.h"
#import "CommunityPublishCtrl.h"
#import "PropertyStateCtrl.h"

#import "OtherMessageCtrl.h"
#import "FlowersViewController.h"
#import "UserHelperViewController.h"
#import "SYMyMessgeViewController.h"

@interface MessageViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, assign) int nPage;
@property (nonatomic, retain) NSMutableArray *sourcesMArr;
@property (nonatomic, strong) InfomationViewController *menuVC;

@property (nonatomic,strong) AffineDrawer *drawer;
@property (nonatomic,strong) AffineDrawer *drawerDetail;

@property (nonatomic, strong) UIView *HeadTopView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic,strong) PersonalMessageCtrl *personalMessageCtrl;
@property (nonatomic,strong) SYMyMessgeViewController *communityPublishCtrl;
@property (nonatomic,strong) PropertyStateCtrl *propertyStateCtrl;

@property (nonatomic,strong) OtherMessageCtrl *otherMessageCtrl;
@property (nonatomic,strong) FlowersViewController *flowersViewController;
@property (nonatomic,strong) UserHelperViewController *userHelperViewController;
@property (nonatomic,strong) SYMyMessageDetailViewController *messageCtrl;
@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(0xebebeb);
    [self initUI];
}

- (void)initUI
{
    self.sourcesMArr = [[NSMutableArray alloc] init];
    UIView *HeadTopView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth - dockWidth, 50)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:HeadTopView.bounds];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel = titleLabel;
    titleLabel.text = @"消息";
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
    
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    self.menuVC = [[InfomationViewController alloc] init];
    
    self.drawer = [[AffineDrawer alloc] initWithView:keyWindow.rootViewController.view menuView:self.menuVC.view menuFrame:CGRectMake(screenWidth, 0, self.view.frame.size.width * 0.7, screenHeight)];
    self.drawerDetail = [[AffineDrawer alloc] initWithView:keyWindow.rootViewController.view menuView:self.menuVC.view menuFrame:CGRectMake(screenWidth, 0, self.view.frame.size.width * 0.7, screenHeight)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeDrawer)
                                                 name:@"closeDrawer"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(closeDrawerDetail)
                                                 name:@"closeDrawerDetail"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeInforDetail)
                                                 name:@"closeInforDetail"
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openMessage:)
                                                 name:@"openMessage"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil ];
}

- (void)openMessage:(NSNotification *)notif
{
    SYNoticeByPagerModel *model = notif.object;
    
    self.messageCtrl = [[SYMyMessageDetailViewController alloc] initWithModel:model WithType:NeighborMessageType];
    [self.drawerDetail setContentView:self.messageCtrl.view];
    [self.drawerDetail openDrawer];
    self.messageCtrl.view.hidden = NO;
}

- (void)closeInforDetail
{
    self.messageCtrl.view.hidden = YES;
}

- (void)closeDrawer
{
    [self.drawer closeDrawer];
}

- (void)closeDrawerDetail
{
    [self.drawerDetail closeDrawer];
}

- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation
{
    self.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    self.drawer.mask.frame = CGRectMake(0, 0, screenWidth, screenHeight);
}

- (void)viewWillLayoutSubviews
{
    self.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    self.drawerDetail.mask.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    
    self.HeadTopView.frame = CGRectMake(0, 20, screenWidth - dockWidth, 50);
    self.titleLabel.frame = self.HeadTopView.bounds;
    self.lineView.frame = CGRectMake(0, 50, screenWidth - dockWidth, 1);
    
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.HeadTopView.frame) + 1, screenWidth, screenHeight - self.HeadTopView.frame.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private
- (void)reflashData:(BOOL)isMore{
    
    WEAK_SELF;
    
    if (isMore) {
        self.nPage++;
    }else{
        self.nPage = 1;
    }
    
    SYDiscoverHttpDAO *discoverHttpDAO = [[SYDiscoverHttpDAO alloc] init];
    [discoverHttpDAO getTenementMsgListWithWorkerID:nil WithUserID:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id Succeed:^(NSArray *modelArr) {
        weakSelf.tableView.mj_footer.hidden = YES;
        [weakSelf.tableView.mj_header endRefreshing];
        
        [weakSelf.sourcesMArr removeAllObjects];
        [weakSelf.sourcesMArr addObjectsFromArray:modelArr];
        [weakSelf.tableView reloadData];
        
    } fail:^(NSError *error) {
        [weakSelf.tableView.mj_header endRefreshing];
        weakSelf.tableView.mj_footer.hidden = YES;
    }];
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 2;
    }else if (section == 1){
        return 3;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SYPersonalSpaceTableViewCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth - dockWidth, 50)];
    
    if (section == 0) {
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"消息";
    }else{
        label.text = @"未读消息";
    }
    
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 50.0f;
    }
    
    return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        static NSString *identify = @"SYPersonalSpaceTableViewCellIdentify";
        SYPersonalSpaceTableViewCell *personalSpaceTableViewCell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!personalSpaceTableViewCell) {
            personalSpaceTableViewCell = [[SYPersonalSpaceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            personalSpaceTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        SYPersonalSpaceModel *model = [[SYPersonalSpaceModel alloc] init];
        if (indexPath.row == 0) {
            
            model.iconImg = [UIImage imageNamed:@"Slice 86"];
            model.nameStr = @"个人通知";
        }else if (indexPath.row == 1) {
            model.iconImg = [UIImage imageNamed:@"Slice 85"];
            model.nameStr = @"社区公告";
        }else if (indexPath.row == 2) {
            model.iconImg = [UIImage imageNamed:@"sy_me_help"];
            model.nameStr = @"物业动态";
        }
        
        [personalSpaceTableViewCell updateData:model];
        
        return personalSpaceTableViewCell;
    }else{
        
        static NSString *identify = @"SYMyMessageTableViewCell";
        
        SYMyMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[SYMyMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        }
        //    SYNoticeByPagerModel *model = [self.sourcesMArr objectAtIndex:indexPath.row];
        //    [cell updateTenementMessageInfo:model];
        
//        SYNoticeByPagerModel *model = [[SYNoticeByPagerModel alloc] init];
//        model.fcontent = @"龙域社区的楼栋2公告龙域社区的楼栋2公告龙域社区的楼栋2公告龙域社区的楼栋2公告龙域社区的楼栋2公告龙域社区的楼栋2公告龙域社区的楼栋2公告龙域社区的楼栋2公告龙域社区的楼栋2公告龙域社区的楼栋2公告龙域社区的楼栋2公告";
//        model.fpush_type = @"0911";
//        model.frepairs_id = @"0000000055a0ec3d0155ba81879d0060";
//        model.fcreatetime = @"07-07 16:30";
//        model.fname = @"系统";
//
//        [cell updateTenementMessageInfo:model];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.drawer openDrawer];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            self.communityPublishCtrl = [[SYMyMessgeViewController alloc] init];
            self.communityPublishCtrl.type = MyMessageType;
            [self.drawer setContentView:self.communityPublishCtrl.view];
            [self.drawer openDrawer];
            
        }else if (indexPath.row == 1) {
            self.communityPublishCtrl = [[SYMyMessgeViewController alloc] init];
            self.communityPublishCtrl.type = NeighborMessageType;
            [self.drawer setContentView:self.communityPublishCtrl.view];
            [self.drawer openDrawer];
            
        }else if (indexPath.row == 2) {
            self.propertyStateCtrl = [[PropertyStateCtrl alloc] init];
            [self.drawer setContentView:self.propertyStateCtrl.view];
            [self.drawer openDrawer];
        }
    }else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            self.otherMessageCtrl = [[OtherMessageCtrl alloc] init];
            [self.drawer setContentView:self.otherMessageCtrl.view];
            [self.drawer openDrawer];
            
        }else if (indexPath.row == 1) {
            self.flowersViewController = [[FlowersViewController alloc] init];
            [self.drawer setContentView:self.flowersViewController.view];
            [self.drawer openDrawer];

        }else if (indexPath.row == 2) {
            self.userHelperViewController = [[UserHelperViewController alloc] init];
            [self.drawer setContentView:self.userHelperViewController.view];
            [self.drawer openDrawer];
        }
    }
}

- (void)initAllSubviews
{
    self.personalMessageCtrl = [[PersonalMessageCtrl alloc] init];
    self.communityPublishCtrl = [[SYMyMessgeViewController alloc] init];
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
