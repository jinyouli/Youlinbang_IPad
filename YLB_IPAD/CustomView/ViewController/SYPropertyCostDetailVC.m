//
//  SYPropertyCostDetailVC.m
//  YLB
//
//  Created by jinyou on 2017/6/19.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYPropertyCostDetailVC.h"
#import "SYPropertyCostMoneyCell.h"
#import "SYPropertyCostListCell.h"
#import "SYPropertyHistoryListVC.h"

@interface SYPropertyCostDetailVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) RepairListOrderType oderType;
@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, strong) UIButton *historyBtn;
@end

@implementation SYPropertyCostDetailVC

- (instancetype)initWithRepairListOrderType:(RepairListOrderType)type WithTitle:(NSString *)title{
    if (self = [super init]) {
        self.oderType = type;
        self.titleStr = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
    self.view.backgroundColor = [UIColor lightGrayColor];
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
    
    //===添加按钮==
    self.historyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.historyBtn.frame = CGRectMake(0, 0, 70, 44);
    self.historyBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.historyBtn setTitle:@"历史账单" forState:UIControlStateNormal];
    [self.historyBtn addTarget:self action:@selector(pushHistoryClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:self.historyBtn];
    self.navigationItem.rightBarButtonItem = backItem;
//    UIBarButtonItem *flexSpacerl = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
//    self.navigationItem.rightBarButtonItems = @[flexSpacerl, backItem];
    
}

- (void)pushHistoryClick:(UIButton*)btn
{
    SYPropertyHistoryListVC *vc = [[SYPropertyHistoryListVC alloc] initWithRepairListOrderType:propertyComplainListType WithTitle:@"历史账单"];
    [FrameManager pushViewController:vc animated:YES];
}

#pragma mark - overwrite
- (NSString *)backBtnTitle{
    return self.titleStr;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        static NSString *identify = @"SYPropertyCostMoneyCell";
        
        SYPropertyCostMoneyCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[SYPropertyCostMoneyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            //cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        return cell;
    }else{
        
        static NSString *identify = @"SYPropertyCostListCell";
        
        SYPropertyCostListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[SYPropertyCostListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            //cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


@end
