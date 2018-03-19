//
//  SYSubAccountInfoViewController.m
//  YLB
//
//  Created by sayee on 17/3/29.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYSubAccountInfoViewController.h"
#import "SYSubAccountInfoTableViewCell.h"
#import "SYSubAccountTableViewCell.h"
#import "SYSubAccountModel.h"
#import "SYCommunityHttpDAO.h"
#import "SYSubAccountViewController.h"

@interface SYSubAccountInfoViewController ()<UITableViewDataSource, UITableViewDelegate, SYSubAccountInfoTableViewCellDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, strong) SYSubAccountModel *model;
@property (nonatomic, strong) SipInfoModel *sipInfoModel;

//添加子账号才会有值传进来
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *phoneNumber;
@end

@implementation SYSubAccountInfoViewController

- (instancetype)initWithSipInfoModel:(SYSubAccountModel *)model SipInfoModel:(SipInfoModel *)sipInfoModel{
    if (self = [super init]) {
        self.model = model;
        self.sipInfoModel = sipInfoModel;
    }
    return self;
}

- (instancetype)initWithNickName:(NSString *)nickName PhoneNumber:(NSString *)phoneNumber SipInfoModel:(SipInfoModel *)sipInfoModel{
    if (self = [super init]) {
        self.nickName = nickName;
        self.phoneNumber = phoneNumber;
        self.sipInfoModel = sipInfoModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - overwrite
- (NSString *)backBtnTitle{
    return @"子账号管理";
}


#pragma mark - private
- (void)initUI{
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = UIColorFromRGB(0xebebeb);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, SYSubAccountInfoTableViewCellHeight)];
    
    UIButton *subAccoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    subAccoutBtn.frame = CGRectMake(10, 0, footerView.width - 20, footerView.height);
    if (self.nickName) {
        [subAccoutBtn setTitle:@"添加子账号" forState:UIControlStateNormal];
    }else{
        [subAccoutBtn setTitle:@"删除子账号" forState:UIControlStateNormal];
    }
    subAccoutBtn.backgroundColor = [UIColor whiteColor];
    [subAccoutBtn setTitleColor:UIColorFromRGB(0xD23023) forState:UIControlStateNormal];
    [subAccoutBtn addTarget:self action:@selector(delSubAccountClick:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:subAccoutBtn];
    
    self.tableView.tableFooterView = footerView;
}


#pragma mark - event
- (void)delSubAccountClick:(UIButton *)btn{
    
    [self.view endEditing:YES];
    BOOL isAdd = self.nickName ? YES : NO;  //删除还是添加
    if (!isAdd && self.model.is_called_number) {
        [self showMessageWithContent:@"不能删除紧急被叫子账号" duration:1];
        return;
    }
    
    WEAK_SELF;
    NSString *calledNumber = self.nickName ? self.phoneNumber : self.model.mobile_phone;
    NSString *nickName = self.nickName ? self.nickName : self.model.alias;
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    [communityHttpDAO setHouseSubAccountWithCalledNumber:calledNumber WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username WithHouseID:self.sipInfoModel.house_id WithAlias:nickName WithIsAdd:isAdd WithIsCalledNumber:self.model.is_called_number Succeed:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_REFLASH_HOUSE_SUBACCOUNT object:nil];
        for (UIViewController *temp in [FrameManager tabBarViewController].navigationController.viewControllers) {
            if ([temp isKindOfClass:[SYSubAccountViewController class]]) {
                [FrameManager popToViewController:temp animated:YES];
            }
        }
    } fail:^(NSError *error) {
        [weakSelf showErrorWithContent:[error.userInfo objectForKey:@"NSLocalizedDescription"] duration:1];
    }];
}


#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SYSubAccountInfoTableViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 8;
    }
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 1) {
        return self.nickName ? 2 : 3;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        
        static NSString *identify = @"SYSubAccountTableViewCell";
        SYSubAccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[SYSubAccountTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (self.nickName) {
            [cell updatePhoneNumber:self.nickName];
        }else{
            [cell updateInfo:self.model];
        }
        return cell;
    }

    static NSString *identify = @"SYSubAccountInfoTableViewCell";
    
    SYSubAccountInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[SYSubAccountInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    //update data
    if (self.nickName) {
        cell.isDelAccount = NO;
    }else{
        cell.isDelAccount = YES;
    }
    
    if (self.nickName) {
        if (indexPath.row == 0) {
            [cell updateLeftInfo:@"手机" RightInfo:self.phoneNumber];
        }else if (indexPath.row == 1){
            [cell updateLeftInfo:@"昵称" RightInfo:self.nickName];
        }
    }
    else{
        if (indexPath.row == 0) {
            [cell updateLeftInfo:@"手机" Type:labelType SubAccountModel:self.model];
        }else if (indexPath.row == 1){
            [cell updateLeftInfo:@"紧急被叫" Type:switchType SubAccountModel:self.model];
        }else if (indexPath.row == 2){
            [cell updateLeftInfo:@"昵称" Type:txtFieldType SubAccountModel:self.model];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}


#pragma - mark SYSubAccountInfoTableViewCellDelegate
- (void)switchChange:(BOOL)change{
    
    NSString *callNumber = nil;
    if (change) {
        self.model.is_called_number = YES;
        callNumber = self.model.mobile_phone;
    }else{
        self.model.is_called_number = NO;
        callNumber = [SYLoginInfoModel shareUserInfo].userInfoModel.username;
    }
    WEAK_SELF;
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    [communityHttpDAO setCalledNumberWithCalledNumber:callNumber WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username WithHouseID:self.sipInfoModel.house_id Succeed:^{
        
        [weakSelf.tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_REFLASH_HOUSE_SUBACCOUNT object:nil];
    } fail:^(NSError *error) {
        
    }];
}

- (void)nickNameChange:(NSString *)nickName{
    self.nickName = nickName;
}

@end
