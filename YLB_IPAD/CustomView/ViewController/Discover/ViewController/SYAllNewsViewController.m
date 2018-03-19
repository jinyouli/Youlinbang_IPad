//
//  SYAllNewsViewController.m
//  YLB
//
//  Created by sayee on 17/4/7.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYAllNewsViewController.h"
#import "MJRefresh.h"
#import "SYCommunityHttpDAO.h"
#import "SYDiscoverCommunityNewsTableViewCell.h"
#import "SYWKWebViewController.h"

@interface SYAllNewsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *sourcesMArr;
@property (nonatomic, assign) int nCurrentPage;
@end

@implementation SYAllNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sourcesMArr = [[NSMutableArray alloc] init];
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)backBtnTitle{
    return @"社区头条";
}


- (void)initUI{
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width_sd, self.view.height_sd - 59) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = UIColorFromRGB(0xebebeb);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    WEAK_SELF;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf reflashDataWithMore:NO];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf reflashDataWithMore:YES];
    }];
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - private
// 社区头条  isMore 是否下拉刷新
- (void)reflashDataWithMore:(BOOL)isMore{
    
    WEAK_SELF;
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    
    if (isMore) {
        self.nCurrentPage++;
    }else{
        self.nCurrentPage = 1;
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    [communityHttpDAO getTodayNewsWithNeigborID:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username WithStartTime:@"201254043423" WithEndTime:[dateFormatter stringFromDate:[NSDate date]] WithIsPage:1 WithCurrentPage:self.nCurrentPage WithPageSize:20 Succeed:^(NSArray *modelArr) {

        if (modelArr) {
            @synchronized (weakSelf.sourcesMArr) {
                if (!isMore) {
                    [weakSelf.sourcesMArr removeAllObjects];
                }
                weakSelf.tableView.mj_footer.hidden = modelArr.count == 0 ? YES : NO;   //上拉没有更多消息时，隐藏footer
                [weakSelf.sourcesMArr addObjectsFromArray:modelArr];
            }
            [weakSelf.tableView reloadData];
        }
        [weakSelf endRefreshWithMore:isMore];
        
    } fail:^(NSError *error) {
        [weakSelf endRefreshWithMore:isMore];
    }];
}

- (void)endRefreshWithMore:(BOOL)isMore{
    
    if (!isMore) {
        self.tableView.mj_footer.hidden = NO;
        [self.tableView.mj_header endRefreshing];
    }else{
        [self.tableView.mj_footer endRefreshing];
    }
}


#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sourcesMArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SYDiscoverCommunityNewsTableViewCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width_sd, 5)];
    view.backgroundColor = UIColorFromRGB(0xebebeb);
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify = @"SYDiscoverCommunityNewsTableViewCell";
    
    SYDiscoverCommunityNewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[SYDiscoverCommunityNewsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (self.sourcesMArr.count > indexPath.section) {
        SYTodayNewsModel *model  = [self.sourcesMArr objectAtIndex:indexPath.section];
        [cell updateNews:model];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.sourcesMArr.count > indexPath.section) {
        SYTodayNewsModel *model  = [self.sourcesMArr objectAtIndex:indexPath.section];
        SYWKWebViewController *vc = [[SYWKWebViewController alloc] initWithURL:model.news_url Title: @"社区头条"];
        [FrameManager pushViewController:vc animated:YES];
    }
}

@end
