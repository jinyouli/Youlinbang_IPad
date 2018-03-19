//
//  SYMyMessageListView.m
//  YLB
//
//  Created by sayee on 17/4/7.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYMyMessageListView.h"
#import "MJRefresh.h"
#import "SYDiscoverHttpDAO.h"
#import "SYMyMessageTableViewCell.h"

@interface SYMyMessageListView ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *sourcesMArr;
@property (nonatomic, assign) int nPage;
@property (nonatomic, assign) SYMyMessageNoticeType type;

@end


@implementation SYMyMessageListView

- (instancetype)initWithFrame:(CGRect)frame WithType:(SYMyMessageNoticeType) type{
    if (self = [super initWithFrame:frame]) {

        self.type = type;
        self.sourcesMArr = [[NSMutableArray alloc] init];
        [self initUI];
    }
    return self;
}

- (void)initUI{
    
    _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = UIColorFromRGB(0xebebeb);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.tableView];
    
    WEAK_SELF;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf reflashData:NO];
    }];
    
//    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
//
//        [weakSelf reflashData:NO];
//    }];
    [self reflashData:NO];
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
    //我的消息
    if (self.type == TenementMessageType) {
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
    else{
        [discoverHttpDAO getNoticeByPagerWithNeigborID:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username WithNoticeType:self.type WithAppType:2 WithCurrentPage:self.nPage WithPageSize:20 Succeed:^(NSArray *modelArr) {
            
            weakSelf.tableView.mj_footer.hidden = modelArr.count == 0 ? YES : NO;   //上拉没有更多消息时，隐藏footer
            
            if (!isMore) {
                [weakSelf.sourcesMArr removeAllObjects];
                [weakSelf.tableView.mj_header endRefreshing];
            }else{
                [weakSelf.tableView.mj_footer endRefreshing];
            }
            [weakSelf.sourcesMArr addObjectsFromArray:modelArr];
            
            [weakSelf.tableView reloadData];
        } fail:^(NSError *error) {
            if (!isMore) {
                [weakSelf.tableView.mj_header endRefreshing];
            }else{
                [weakSelf.tableView.mj_footer endRefreshing];
            }
        }];
    }
}

- (void)layoutSubviews
{
    self.tableView.frame = CGRectMake(0, 0, screenWidth * 0.7, screenHeight - 60);
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.sourcesMArr.count > 0) {
        return self.sourcesMArr.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.sourcesMArr.count > 0) {
        return SYMyMessageTableViewCellHeight;
    }
    return screenHeight - 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.sourcesMArr.count > 0) {
        static NSString *identify = @"SYMyMessageTableViewCell";
        
        SYMyMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[SYMyMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        }
        
        if (self.sourcesMArr.count > indexPath.section) {
            if (self.type == TenementMessageType) {
                SYNoticeByPagerModel *model = [self.sourcesMArr objectAtIndex:indexPath.row];
                [cell updateTenementMessageInfo:model];
            }else{
                SYNoticeByPagerModel *model = [self.sourcesMArr objectAtIndex:indexPath.row];
                [cell updateMyMessageInfo:model];
            }
        }
        
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.sourcesMArr.count > 0) {
        if (self.sourcesMArr.count > indexPath.row) {
            SYNoticeByPagerModel *model = [self.sourcesMArr objectAtIndex:indexPath.row];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"openMessage" object:model];
        }
    }
}
@end
