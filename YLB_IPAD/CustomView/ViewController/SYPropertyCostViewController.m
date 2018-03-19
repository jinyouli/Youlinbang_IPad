//
//  SYPropertyCostViewController.m
//  YLB
//
//  Created by jinyou on 2017/6/19.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYPropertyCostViewController.h"
#import "SYPropertyCostTableViewCell.h"

@interface SYPropertyCostViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) RepairListOrderType oderType;
@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic,weak) UIView * cover;
@property (nonatomic, strong) UIButton *btn;
@end

static NSString * paySuccessNotificationName = @"paySuccessNotificationName";

@implementation SYPropertyCostViewController

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
    self.view.backgroundColor = UIColorFromRGB(0xebebeb);
}

#pragma mark - private
- (void)initUI{
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStylePlain];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify = @"SYPropertyCostTableViewCell";
    
    SYPropertyCostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[SYPropertyCostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        //cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSLog(@"高度==%f",cell.frame.size.height);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


@end
