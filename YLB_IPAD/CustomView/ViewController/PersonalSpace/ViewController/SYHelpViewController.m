//
//  SYHelpViewController.m
//  YLB
//
//  Created by YAYA on 2017/3/18.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYHelpViewController.h"
#import "SYHelpTableViewCell.h"
#import "SYFeedbackViewController.h"

@interface SYHelpViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *sourceHeightArr;
@property (nonatomic, strong) UIView *underLineView;

@property (nonatomic, strong) UIButton *btnReturn;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UIButton *routeChangeBtn;
@end

@implementation SYHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initUI];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - overwrite
- (NSString *)backBtnTitle{
    return @"帮助与反馈";
}


#pragma mark - private
- (void)initData{
    
    NSString *str = @"A1:业主初次开通本业务需到小区物业管理中心实名登记业主信息，在系统中录入手机号码，根据该手机号码注册账号（本账号默认为主账号，可为子账号授权），登录后即可看到相应门口机。";
    CGSize size = [str sizeWithFont: [UIFont systemFontOfSize:14.0] andSize:CGSizeMake(self.view.width - 40, MAXFLOAT)];
    NSValue *value = [NSValue valueWithCGSize:size];
    
    str = @"A2:业主可以通过APP设置子账号功能，给家人或租户授权，被授权人须先用手机号码注册账号。";
    size = [str sizeWithFont: [UIFont systemFontOfSize:14.0] andSize:CGSizeMake(self.view.width - 40, MAXFLOAT)];
    NSValue *value_two = [NSValue valueWithCGSize:size];

    str = @"A3:用主账号登录APP，点击【我的】进入【我的】页面，点击【房产管理】进入房产信息页面，选择对应房产信息，点击添加子账号，输入被授权人的手机号码（必须先用此手机号码注册用户账号），点击完成。授权完成后，通过子账号登录APP后即可看到对应的授权门口机。";
    size = [str sizeWithFont: [UIFont systemFontOfSize:14.0] andSize:CGSizeMake(self.view.width - 40, MAXFLOAT)];
    NSValue *value_three = [NSValue valueWithCGSize:size];
    
    _sourceHeightArr = [NSArray arrayWithObjects:value, value_two, value_three, nil];
}

- (void)initUI{
    
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width * 0.7, self.view.frame.size.height);
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 55, self.view.frame.size.width, self.view.frame.size.height - 50) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = UIColorFromRGB(0xebebeb);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    //==========建议按钮=======
    UIButton *routeChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    routeChangeBtn.frame = CGRectMake(self.view.bounds.size.width - 65, 10, 60, 50);
    routeChangeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [routeChangeBtn setTitle:@"建议" forState:UIControlStateNormal];
    [routeChangeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [routeChangeBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:routeChangeBtn];
    self.routeChangeBtn = routeChangeBtn;
    
    UIButton *btnReturn = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReturn.frame = CGRectMake(0, 10, 70, 50);
    [btnReturn setImage:[UIImage imageNamed:@"last.png"] forState:UIControlStateNormal];
    [btnReturn addTarget:self action:@selector(ExitSubView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnReturn];
    self.btnReturn = btnReturn;
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = @"帮助与反馈";
    [self.view addSubview:lblTitle];
    self.lblTitle = lblTitle;
    
    self.underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, kScreenWidth - dockWidth, 1)];
    _underLineView.backgroundColor = underLineColor;
    [self.view addSubview:_underLineView];
}

- (void)viewWillLayoutSubviews
{
    self.view.frame = CGRectMake(screenWidth * 0.3, 0, screenWidth * 0.7, screenHeight);
    _tableView.frame = CGRectMake(0, 55, self.view.frame.size.width, self.view.frame.size.height - 50);
    
    //==========建议按钮=======
    self.routeChangeBtn.frame = CGRectMake(self.view.bounds.size.width - 65, 10, 60, 50);
    self.btnReturn.frame = CGRectMake(0, 10, 70, 50);
    self.lblTitle.frame = CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50);
    self.underLineView.frame = CGRectMake(0, 55, kScreenWidth - dockWidth, 1);
}

- (void)ExitSubView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeDrawer"
                                                        object:nil];
}

#pragma mark - event
- (void)btnClick:(UIButton *)btn{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"openFeedBack" object:nil];
}


#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size ;
    if (indexPath.section < self.sourceHeightArr.count) {
        NSValue *value = [self.sourceHeightArr objectAtIndex:indexPath.section];
        size = [value CGSizeValue];
    }
    return size.height + 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sourceHeightArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identify = @"SYSettingTableViewCell";
    SYHelpTableViewCell *helpTableViewCell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!helpTableViewCell) {
        helpTableViewCell = [[SYHelpTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        helpTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    CGSize size = CGSizeMake(0, 0);
    if (indexPath.section < self.sourceHeightArr.count) {
        NSValue *value = [self.sourceHeightArr objectAtIndex:indexPath.section];
        size = [value CGSizeValue];
    }

    //update data
    if (indexPath.section == 0) {
        [helpTableViewCell updateTitle:@"Q1:业主初次开通本业务，怎样绑定房产？" Content:@"A1:业主初次开通本业务需到小区物业管理中心实名登记业主信息，在系统中录入手机号码，根据该手机号码注册账号（本账号默认为主账号，可为子账号授权），登录后即可看到相应门口机。" ContentHeight:size];
    }else if (indexPath.section == 1) {
        [helpTableViewCell updateTitle:@"Q2:怎样给家人或租户开通本业务功能？" Content:@"A2:业主可以通过APP设置子账号功能，给家人或租户授权，被授权人须先用手机号码注册账号。" ContentHeight:size];
    }
    else if (indexPath.section == 2) {
        [helpTableViewCell updateTitle:@"Q3:主账号怎么授权子账号？" Content:@"A3:用主账号登录APP，点击【我的】进入【我的】页面，点击【房产管理】进入房产信息页面，选择对应房产信息，点击添加子账号，输入被授权人的手机号码（必须先用此手机号码注册用户账号），点击完成。授权完成后，通过子账号登录APP后即可看到对应的授权门口机。" ContentHeight:size];
    }

    return helpTableViewCell;
}
@end
