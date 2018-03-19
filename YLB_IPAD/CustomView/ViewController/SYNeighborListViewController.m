//
//  SYNeighborListViewController.m
//  YLB
//
//  Created by sayee on 17/4/5.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYNeighborListViewController.h"
#import "SYCommunityHttpDAO.h"
#import "SYNeighborListTableViewCell.h"
#import "SYLoginViewController.h"
#import "SYPersonalSpaceHttpDAO.h"

@interface SYNeighborListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *sourcesMArr;
@end

@implementation SYNeighborListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sourcesMArr = [[NSMutableArray alloc] init];
    [self initUI];
    [self getNeighborList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    if (![SYAppConfig shareInstance].bindedModel) {
        [SYLoginInfoModel loginOut];
        return;
    }
}


#pragma mark - overwrite
- (void)backButtonClick{
    if (![SYAppConfig shareInstance].bindedModel) {
        [SYLoginInfoModel loginOut];
        SYLoginViewController *loginVC = [[SYLoginViewController alloc] initWithShowLaunchViewAnim:NO];
        [FrameManager pushViewController:loginVC animated:NO];
        return;
    }
    [FrameManager popToRootViewControllerAnimated:YES];
}

- (NSString *)backBtnTitle{
    return @"绑定社区";
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
}

- (void)getNeighborList{
    
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    WEAK_SELF;
    //获取的社区列表
    [communityHttpDAO getNeiIPListWithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id Succeed:^(NSArray *neiIPList) {
        
        [weakSelf.sourcesMArr removeAllObjects];
        [weakSelf.sourcesMArr addObjectsFromArray:neiIPList];
        [weakSelf.tableView reloadData];
    
    } fail:^(NSError *error) {
        [weakSelf showErrorWithContent:[error.userInfo objectForKey:NSLocalizedDescriptionKey] duration:1];
    }];
}

//保存用户绑定小区信息
- (void)saveNeiBindingUser{
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    WEAK_SELF;
    [communityHttpDAO saveNeiBindingUserWithNeighborHoodsID:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id WithUserID:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id Succeed:^(NSString *resultID) {
        
    } fail:^(NSError *error) {
        [weakSelf showErrorWithContent:[error.userInfo objectForKey:NSLocalizedDescriptionKey] duration:1];
    }];
}


#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.sourcesMArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SYNeighborListTableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identify = @"SYNeighborListTableViewCell";
    SYNeighborListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[SYNeighborListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    //update data
    if (self.sourcesMArr.count > indexPath.row) {
        SYNeiIPListModel *model = [self.sourcesMArr objectAtIndex:indexPath.row];
        [cell updataInfo:model];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.sourcesMArr.count > indexPath.row) {
        SYNeiIPListModel *model = [self.sourcesMArr objectAtIndex:indexPath.row];
        [self showWithContent:nil];
        
        WEAK_SELF;
        SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
        //绑定社区
        NSString *strURL = [NSString stringWithFormat:@"https://%@:%@",model.fip, model.fport];
        
//        [communityHttpDAO getCanBindingWithNeiName:model.fneib_name WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username WithUserID:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id URL:strURL Succeed:^(SYCanBindingModel *canBindingModel) {
//            
//            if (canBindingModel.can_binding) {
//                [SYAppConfig shareInstance].secondPlatformIPStr = strURL;
//                [SYAppConfig shareInstance].bindedModel = canBindingModel;
//                [SYAppConfig saveUserLoginInfo];
//                [SYAppConfig getUserLoginInfoWithUserID:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id];
//                
//                [weakSelf saveNeiBindingUser];
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_Binded_Neighbor object:nil];
//                });
//                
//                [weakSelf dismissHud:YES];
//                [FrameManager popToRootViewControllerAnimated:YES];
//            }
//            else{
//                [weakSelf showErrorWithContent:@"您在该小区没有对应房产" duration:1];
//            }
//            
//        } fail:^(NSError *error) {
//            [weakSelf showErrorWithContent:[error.userInfo objectForKey:NSLocalizedDescriptionKey] duration:1];
//        }];
    }
}

@end
