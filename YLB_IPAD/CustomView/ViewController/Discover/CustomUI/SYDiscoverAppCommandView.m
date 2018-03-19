//
//  SYDiscoverAppCommandView.m
//  YLB
//
//  Created by YAYA on 2017/4/4.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYDiscoverAppCommandView.h"
#import "MJRefresh.h"
#import "SYDiscoverHttpDAO.h"
#import "SYDiscoverAppCommandTableViewCell.h"

@interface SYDiscoverAppCommandView ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *sourcesMArr;
@end

@implementation SYDiscoverAppCommandView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
    
        self.sourcesMArr = [[NSMutableArray alloc] init];
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
    //[self.tableView.mj_header beginRefreshing];
    //[self.tableView.mj_header setFrame:CGRectMake((screenWidth - dockWidth) * 0.5 - 120, 0, 120, 50)];
    [self reflashData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reflashData) name:@"refreshPage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reflashData) name:@"refreshAdervert" object:nil];

}

#pragma mark - 获取头条列表
- (void)reflashData
{
    WEAK_SELF;
    SYCommunityHttpDAO *communityHttpDAO =[[SYCommunityHttpDAO alloc] init];
    
    //社区头条
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];

    NSDate *priousDate = [Common getPriousorLaterDateFromDate:[NSDate date] withMonth:-2];
    NSString *newString = [dateFormatter stringFromDate:priousDate];
    
    [communityHttpDAO getTodayNewsWithNeigborID:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username WithStartTime:newString WithEndTime:[dateFormatter stringFromDate:[NSDate date]] WithIsPage:1 WithCurrentPage:1 WithPageSize:50 Succeed:^(NSArray *modelArr) {
        
        [weakSelf.sourcesMArr removeAllObjects];
        [weakSelf.sourcesMArr addObjectsFromArray:modelArr];
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
        
    } fail:^(NSError *error) {

        [weakSelf.sourcesMArr removeAllObjects];
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}

- (void)layoutSubviews
{
    //[self.tableView reloadData];
    _tableView.frame = CGRectMake(0, 0, screenWidth - dockWidth, screenHeight - SYHomeBannerTableViewCellHeight - 120);
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
    
    if (self.sourcesMArr.count == 0) {
        return 1;
    }
    return self.sourcesMArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.sourcesMArr.count > 0) {
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
    
    if (self.sourcesMArr.count > 0) {
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
        
        SYTodayNewsModel *model = [self.sourcesMArr objectAtIndex:indexPath.row];
        [cell updateToutiao:model];
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
    
    if (self.sourcesMArr.count > 0) {
        SYTodayNewsModel *model = [self.sourcesMArr objectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openToutiaoWebpage" object:model];
    }
}
@end
