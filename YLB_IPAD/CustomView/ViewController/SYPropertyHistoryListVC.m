//
//  SYPropertyHistoryListVC.m
//  YLB
//
//  Created by jinyou on 2017/6/20.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYPropertyHistoryListVC.h"
#import "SYPropertyHistoryCell.h"

@interface SYPropertyHistoryListVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) RepairListOrderType oderType;
@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, retain) UITableView *tableView;
@end

@implementation SYPropertyHistoryListVC

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
    return 100.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 10)];
    label.text = @"2016年";
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *identify = @"SYPropertyHistoryCell";
    
    SYPropertyHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[SYPropertyHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        //cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
