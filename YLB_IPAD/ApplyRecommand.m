//
//  InfomationViewController.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/8/7.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "ApplyRecommand.h"
#import "SYDiscoverHttpDAO.h"
#import "SYDiscoverAppCommandTableViewCell.h"

@interface ApplyRecommand ()<UITableViewDataSource, UITableViewDelegate, SYDiscoverAppCommandTableViewCellDelegate>

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *sourcesMArr;
@property (nonatomic, strong) UIView *underLineView;
@property (nonatomic, strong) UILabel *lblTitle;
@end

@implementation ApplyRecommand

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
    [self reflashData];
}

- (void)initUI
{
    self.view.backgroundColor = UIColorFromRGB(0xebebeb);
    self.sourcesMArr = [[NSMutableArray alloc] init];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width * 0.7, self.view.frame.size.height);
    
    UIButton *btnReturn = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReturn.frame = CGRectMake(0, 10, 70, 50);
    [btnReturn setImage:[UIImage imageNamed:@"last.png"] forState:UIControlStateNormal];
    [btnReturn addTarget:self action:@selector(ExitSubView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnReturn];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = @"应用推荐";
    self.lblTitle = lblTitle;
    [self.view addSubview:lblTitle];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 56, self.view.width_sd, self.view.height_sd - 50) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth - dockWidth - 0, 1)];
    _underLineView.backgroundColor = underLineColor;
    [self.view addSubview:_underLineView];
    
}

- (void)viewWillLayoutSubviews{
    
    self.view.frame = CGRectMake(screenWidth * 0.3, 0, screenWidth * 0.7, screenHeight);
    
    self.lblTitle.frame = CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50);
}

#pragma mark - private
- (void)reflashData{
    
    WEAK_SELF;
    SYDiscoverHttpDAO *discoverHttpDAO = [[SYDiscoverHttpDAO alloc] init];
    
    //应用推荐
    [discoverHttpDAO getAppManageListSucceed:^(NSArray *modelArr) {
        
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        // 过滤android应用
        [modelArr enumerateObjectsUsingBlock:^(SYAppManageListModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (![model.app_url hasSuffix:@"apk"]) {
                [tempArr addObject:model];
            }
        }];
        
        @synchronized (weakSelf.sourcesMArr) {
            [weakSelf.sourcesMArr removeAllObjects];
            [weakSelf.sourcesMArr addObjectsFromArray:tempArr];
        }
        [weakSelf.tableView reloadData];
    } fail:^(NSError *error) {
        
    }];
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sourcesMArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SYDiscoverAppCommandTableViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width_sd, 5)];
    view.backgroundColor = UIColorFromRGB(0xebebeb);
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify = @"SYDiscoverAppCommandTableViewCell";
    
    SYDiscoverAppCommandTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[SYDiscoverAppCommandTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.delegte = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.indexPath = indexPath;
    
    if (self.sourcesMArr.count > indexPath.section) {
        SYAppManageListModel *model = [self.sourcesMArr objectAtIndex:indexPath.section];
        [cell updataInfo:model];
    }
    
    return cell;
}


#pragma mark - SYDiscoverAppCommandTableViewCell
- (void)openAPP:(NSIndexPath *)indexPath Model:(SYAppManageListModel *)model{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.app_url]];
}

- (void)ExitSubView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeDrawer"
                                                        object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
