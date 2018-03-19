//
//  SYSubAccountViewController.m
//  YLB
//
//  Created by sayee on 17/3/29.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYSubAccountViewController.h"
#import "SYSubAccountTableViewCell.h"
#import "MJRefresh.h"
#import "SYCommunityHttpDAO.h"
#import "SYSubAccountInfoViewController.h"
#import "SYAddSubAccountViewController.h"

@interface SYSubAccountViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) NSMutableArray *sourcesMArr;
@property (nonatomic, strong) SipInfoModel *model;
@end

@implementation SYSubAccountViewController

- (instancetype)initWithSipInfoModel:(SipInfoModel *)model{
    if (self = [super init]) {
        self.model = model;
        self.sourcesMArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reflashHouseSubaccount) name:SYNOTICE_REFLASH_HOUSE_SUBACCOUNT object:nil];
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - overwrite
- (NSString *)backBtnTitle{
    return @"子账号管理";
}


#pragma mark - private
- (void)initUI{
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = UIColorFromRGB(0xebebeb);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    WEAK_SELF;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf getHouseSubaccount];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    [self.tableView.mj_header beginRefreshing];
    
    //===添加按钮==
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addButton.frame = CGRectMake(0, 0, 44, 44);
    self.addButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.addButton setTitle:@"添加" forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:self.addButton];
    UIBarButtonItem *flexSpacerl = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    self.navigationItem.rightBarButtonItems = @[flexSpacerl, backItem];
}

//获取子账号
- (void)getHouseSubaccount{
    WEAK_SELF;
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    [communityHttpDAO getHouseSubaccountWithHouseID:self.model.house_id WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username Succeed:^(NSArray *arrModel) {
        
        [weakSelf.sourcesMArr removeAllObjects];
        [weakSelf.sourcesMArr addObjectsFromArray:arrModel];
        [weakSelf.tableView reloadData];
        [weakSelf dismissHud:YES];
    } fail:^(NSError *error) {
        [weakSelf dismissHud:YES];
    }];
}


#pragma mark - event
- (void)addButtonClick:(UIButton *)btn{
    
    SYAddSubAccountViewController *vc = [[SYAddSubAccountViewController alloc] initWitSipInfoModel:self.model];
    [FrameManager pushViewController:vc animated:YES];
}


#pragma mark - noti
- (void)reflashHouseSubaccount{

    [self showWithContent:@"更新数据中"];
    [self getHouseSubaccount];
}


#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourcesMArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SYSubAccountTableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify = @"SYSubAccountTableViewCell";
    
    SYSubAccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[SYSubAccountTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (self.sourcesMArr.count > indexPath.row) {
        SYSubAccountModel *model = [self.sourcesMArr objectAtIndex:indexPath.row];
        [cell updateInfo:model];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.sourcesMArr.count > indexPath.row) {
        SYSubAccountModel *model = [self.sourcesMArr objectAtIndex:indexPath.row];
        SYSubAccountInfoViewController *subAccountInfoViewController = [[SYSubAccountInfoViewController alloc] initWithSipInfoModel:model SipInfoModel:self.model];
        [FrameManager pushViewController:subAccountInfoViewController animated:YES];
    }
}


@end
