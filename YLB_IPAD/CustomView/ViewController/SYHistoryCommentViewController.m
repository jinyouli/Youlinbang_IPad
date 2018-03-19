//
//  SYHistoryCommentViewController.m
//  YLB
//
//  Created by YAYA on 2017/4/18.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYHistoryCommentViewController.h"
#import "MJRefresh.h"
#import "SYCommunityHttpDAO.h"
#import "SYHistoryCommentTableViewCell.h"

@interface SYHistoryCommentViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) SYPropertyRepairModel *model;
@property (nonatomic, assign) int nCurrentPage;
@property (nonatomic, strong) NSMutableArray *sourcesMArr;
@end

@implementation SYHistoryCommentViewController

- (instancetype)initWithPropertyRepairModel:(SYPropertyRepairModel *)model{
    if (self = [super init]) {
        self.model = model;
        self.nCurrentPage = 1;
    }
    return self;
}

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
    return @"历史评论";
}


#pragma mark - private
- (void)initUI{
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = UIColorFromRGB(0xebebeb);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];

    WEAK_SELF;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getHistoryCommentWithMore:NO];
    }];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getHistoryCommentWithMore:YES];
    }];
    [self.tableView.mj_header beginRefreshing];
}

- (void)getHistoryCommentWithMore:(BOOL)isMore{
    
    if (isMore) {
        self.nCurrentPage++;
    }else{
        self.nCurrentPage = 1;
    }
    
    WEAK_SELF;
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    [communityHttpDAO getWorkOrderDetailsWithCurrentPage:self.nCurrentPage WithRepairsID:self.model.repair_id WithPageSize:20 Succeed:^(NSArray *modelArr) {
        
        if (modelArr) {
            @synchronized (weakSelf.sourcesMArr) {
                if (!isMore) {
                    [weakSelf.sourcesMArr removeAllObjects];
                }
                weakSelf.tableView.mj_footer.hidden = modelArr.count == 0 ? YES : NO;   //上拉没有更多消息时，隐藏footer
                
                for (SYRepairOrderCommentModel *orderModel in modelArr) {
                    
                    float kNameWidth = kScreenWidth * 0.8 - 15;
                    //comment
                    CGSize size = [orderModel.fcontent sizeWithFont:[UIFont systemFontOfSize:14] andSize:CGSizeMake(kNameWidth, MAXFLOAT)];
                    
                    orderModel.repairOrderCommentHeight = size.height;  //评论高度
                    //评论图片高度
                    if (orderModel.record_imag_list.count > 0) {
                        
                        float fImgWitdh = kNameWidth > 73 ? 73 : kNameWidth;
                        orderModel.repairOrderCommentHeight = fImgWitdh;
                        orderModel.repairOrderCommentImgHeight = fImgWitdh;
                    }
                    orderModel.repairOrderCommentHeight += 20;   // time高度
                    orderModel.repairOrderCommentHeight += 10;  //footer
                    [weakSelf.sourcesMArr addObject:orderModel];
                }
                [weakSelf.tableView reloadData];
            }
            [weakSelf endRefreshWithMore:isMore];
        }
    } fail:^(NSError *error) {
        [weakSelf showErrorWithContent:[error.userInfo objectForKey:@"NSLocalizedDescription"] duration:1];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.sourcesMArr.count > indexPath.row) {
        SYRepairOrderCommentModel *orderModel = [self.sourcesMArr objectAtIndex:indexPath.row];
        return orderModel.repairOrderCommentHeight;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.sourcesMArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identify = @"SYHistoryCommentTableViewCell";
    SYHistoryCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[SYHistoryCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    //update data
    if (self.sourcesMArr.count > indexPath.row) {
        SYRepairOrderCommentModel *orderModel = [self.sourcesMArr objectAtIndex:indexPath.row];
        [cell updataInfo:orderModel];
    }
    return cell;
}


@end
