//
//  RoomManageCtrl.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/8/7.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "RoomManageCtrl.h"
#import "SYHouseManageTableViewCell.h"
#import "SYSubAccountViewController.h"

@interface RoomManageCtrl ()<UITableViewDelegate,UITableViewDataSource,SYHouseManageTableViewCellDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *sourcesArr;
@end

@implementation RoomManageCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
    [self loadData];
}

- (void)initUI
{
    self.view.frame = CGRectMake(0, 0, self.view.width_sd * 0.7, self.view.height_sd);
    self.view.backgroundColor = UIColorFromRGB(0xebebeb);
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    UIButton *btnReturn = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReturn.frame = CGRectMake(0, 10, 70, 50);
    [btnReturn setImage:[UIImage imageNamed:@"last.png"] forState:UIControlStateNormal];
    [btnReturn addTarget:self action:@selector(ExitSubView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnReturn];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = @"房产管理";
    [self.view addSubview:lblTitle];
    
    self.underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, kScreenWidth - dockWidth - 0, 1)];
    _underLineView.backgroundColor = underLineColor;
    [self.view addSubview:_underLineView];
}

- (void)viewWillLayoutSubviews
{
    self.view.frame = CGRectMake(screenWidth * 0.3, 0, screenWidth * 0.7, screenHeight);
    
    self.tableView.frame = CGRectMake(0, 55, screenWidth, screenHeight - 50);
}

- (void)ExitSubView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeDrawer"
                                                        object:nil];
}

- (void)loadData
{
    WEAK_SELF;
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    // 用户获取配置信息获取房产列表（房产管理）
    [communityHttpDAO getMyConfigInfoWithNeigborID:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username Succeed:^(SYConfigInfoModel *configInfo) {
        
        [SYLoginInfoModel shareUserInfo].configInfoModel = configInfo;
        [SYLoginInfoModel saveWithSYLoginInfo];
//
//        weakSelf.sourcesArr = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:[SYLoginInfoModel shareUserInfo].configInfoModel.sipInfoList]];
        
        weakSelf.sourcesArr = [[NSArray alloc] initWithArray:configInfo.sipInfoList];
        [weakSelf.tableView reloadData];
     
    } fail:^(NSError *error) {
        
    }];
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourcesArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SYHouseManageTableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify = @"SYHouseManageTableViewCell";
    
    SYHouseManageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[SYHouseManageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    if (self.sourcesArr.count > indexPath.row) {
        SipInfoModel *model = [self.sourcesArr objectAtIndex:indexPath.row];
        [cell setInfoModel:model];
        cell.indexPath = indexPath;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.sourcesArr.count > indexPath.row) {
        SipInfoModel *model = [self.sourcesArr objectAtIndex:indexPath.row];
        
        if (!model.is_owner) {
            [Common showAlert:@"非户主没有权限操作子账号"];
            return;
        }
        
        SYSubAccountViewController *subAccountViewController = [[SYSubAccountViewController alloc] initWithSipInfoModel:model];
    }
}


- (void)houseManageTableViewCellSelectUnDisturbViewWithIndexPath:(NSIndexPath *)indexPath isdisturb:(BOOL)isdisturb
{
    WEAK_SELF;
    
    SipInfoModel *model = [self.sourcesArr objectAtIndex:indexPath.row];
    [[[SYCommunityHttpDAO alloc] init] updateDisturbingWithHouseID:model.house_id WithDisturbing:isdisturb?1:0 Succeed:^{
        
        //[weakSelf loadData];
        
        if (isdisturb) {
            [Common addAlertWithTitle:@"免打扰设置开启成功"];
        }else{
            [Common addAlertWithTitle:@"免打扰设置取消成功"];
        }
        

    } fail:^(NSError *error) {
        
        [weakSelf.tableView reloadData];
        [Common addAlertWithTitle:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
