//
//  SYDiscoverAppCommandView.m
//  YLB
//
//  Created by YAYA on 2017/4/4.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYDiscoverCommunityNewsView.h"
#import "MJRefresh.h"
#import "SYDiscoverHttpDAO.h"
#import "SYDiscoverAppCommandTableViewCell.h"

@interface SYDiscoverCommunityNewsView ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *adverMarr;
@end

@implementation SYDiscoverCommunityNewsView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.adverMarr = [[NSMutableArray alloc] init];
        [self initUI];
    }
    return self;
}

- (void)initUI{
    
    self.backgroundColor = UIColorFromRGB(0xebebeb);
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width_sd, self.height_sd - SYHomeBannerTableViewCellHeight - 50) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.tableView];
    
    WEAK_SELF;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf reflashData];
    }];
    //[self.tableView.mj_header setFrame:CGRectMake((screenWidth - dockWidth) * 0.5 - 120, 0, 120, 50)];
    [self reflashData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPage) name:@"refreshPage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPage) name:@"refreshAdervert" object:nil];
}

- (void)refreshPage
{
    [self reflashData];
}

- (void)layoutSubviews
{
    //[self.tableView reloadData];
    _tableView.frame = CGRectMake(0, 0, screenWidth - dockWidth, screenHeight - SYHomeBannerTableViewCellHeight - 120);
}

#pragma mark - 获取头条列表
- (void)reflashData
{
    WEAK_SELF;
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    
    [communityHttpDAO getAdvertismentWithNeighborID:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id WithUserName:[SYLoginInfoModel shareUserInfo].userInfoModel.username Succeed:^(NSArray *modelArr) {

        [weakSelf.adverMarr removeAllObjects];
        if (modelArr.count > 0) {
            for (int i=0; i<modelArr.count; i++) {
                SYAdvertInfoListModel *model = [modelArr objectAtIndex:i];
                if ([model.fposition isEqualToString:@"4"]) {
                    [weakSelf.adverMarr addObject:model];
                }
            }
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
    } fail:^(NSError *error) {
        
        [weakSelf.adverMarr removeAllObjects];
        [weakSelf.tableView reloadData];
        
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}

#pragma mark - public
- (void)updateAppsData{
    [self.tableView.mj_header beginRefreshing];
}


#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.adverMarr.count > 0) {
        return self.adverMarr.count;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.adverMarr.count > 0) {
        return 100;
    }
    return (screenHeight - SYHomeBannerTableViewCellHeight - 120);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width_sd, 5)];
    view.backgroundColor = UIColorFromRGB(0xebebeb);
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.adverMarr.count > 0) {
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
        
        SYAdvertInfoListModel *model = [self.adverMarr objectAtIndex:indexPath.row];
        [cell updateAdvertInfo:model];
        
        return cell;
    }else{
        
        static NSString *identify = @"SYNothingCell";
        
        SYNothingCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[SYNothingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.adverMarr.count > 0) {
        SYAdvertInfoListModel *model = [self.adverMarr objectAtIndex:indexPath.row];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openAdvertWebpage" object:model];
    }
    
}
@end
