//
//  SYDiscoverAppCommandView.m
//  YLB
//
//  Created by YAYA on 2017/4/4.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYRecommandView.h"
#import "MJRefresh.h"
#import "SYDiscoverHttpDAO.h"
#import "SYDiscoverAppCommandTableViewCell.h"

@interface SYRecommandView ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *todayNewsModelMArr;
//@property (nonatomic, strong) UIImageView *backImage;
//@property (nonatomic, strong) UILabel *lblDetail;
@end

@implementation SYRecommandView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
    
        self.todayNewsModelMArr = [[NSMutableArray alloc] init];
        [self initUI];
    }
    return self;
}

- (void)initUI{
    
    self.backgroundColor = UIColorFromRGB(0xebebeb);
    
    /*
    self.backImage = [[UIImageView alloc] init];
    self.backImage.image = [UIImage imageNamed:@"icon_empty"];
    self.backImage.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.backImage];
    
    self.lblDetail = [[UILabel alloc] init];
    self.lblDetail.text = @"暂无更多数据";
    self.lblDetail.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.lblDetail];
    */
     
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width_sd, self.height_sd - SYHomeBannerTableViewCellHeight - 70) style:UITableViewStylePlain];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPage) name:@"refreshAdervert" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPage) name:@"refreshPage" object:nil];
}

- (void)refreshPage
{
    [self reflashData];
}

- (void)layoutSubviews
{
    _tableView.frame = CGRectMake(0, 0, screenWidth - dockWidth, screenHeight - SYHomeBannerTableViewCellHeight - 120);
    /*
    self.backImage.frame = CGRectMake((screenWidth - dockWidth) * 0.5 - 50, (screenHeight - SYHomeBannerTableViewCellHeight - 120) * 0.5 - 50, 100, 100);
    self.lblDetail.frame = CGRectMake(0, CGRectGetMaxY(self.backImage.frame) + 10, screenWidth - dockWidth, 50);
     */
}

#pragma mark - 获取推荐列表
- (void)reflashData
{
    if (![SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id) {
        return;
    }
    
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    
    WEAK_SELF;
    [communityHttpDAO getRecommendListWithNeighborID:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id Succeed:^(NSArray *modelArr) {
        
        [weakSelf.todayNewsModelMArr removeAllObjects];
        if (modelArr.count > 0) {
            
            weakSelf.todayNewsModelMArr = [[NSMutableArray alloc] initWithArray:modelArr];
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
    } fail:^(NSError *error) {
        
        NSLog(@"获取推荐失败==%@",[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]]);

        [weakSelf.todayNewsModelMArr removeAllObjects];
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
    
    if (self.todayNewsModelMArr.count > 0) {
        return self.todayNewsModelMArr.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.todayNewsModelMArr.count > 0) {
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
    
    if (self.todayNewsModelMArr.count > 0) {
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
    else{
        
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
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.todayNewsModelMArr.count > 0) {
        SYRecommendModel *model = [self.todayNewsModelMArr objectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openDiscoverWebpage" object:model];
    }
    
    
}

@end
