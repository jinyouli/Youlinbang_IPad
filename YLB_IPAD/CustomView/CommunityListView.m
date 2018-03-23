//
//  CommunityListView.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/8/7.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "CommunityListView.h"
#import "SYNeighborListTableViewCell.h"

@interface CommunityListView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *sourcesMArr;
@end

@implementation CommunityListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initUI];
        [self getNeighborList];
    }
    return self;
}

- (void)initUI
{
    self.sourcesMArr = [[NSMutableArray alloc] init];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor redColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNeighborList) name:@"allLocks" object:nil];
}

- (void)getNeighborList{
    
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    WEAK_SELF;
    //获取的社区列表
    [communityHttpDAO getNeiIPListWithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id Succeed:^(NSArray *neiIPList) {
        
        [weakSelf.sourcesMArr removeAllObjects];
        for (int i=0; i<neiIPList.count; i++) {
            SYNeiIPListModel *model = [neiIPList objectAtIndex:i];
            if (model.fuser_id) {
                [weakSelf.sourcesMArr addObject:model];
            }
        }
        [weakSelf.tableView reloadData];
        
    } fail:^(NSError *error) {
        [Common showAlert:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
    }];
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.sourcesMArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
        
        SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
        //绑定社区
        NSString *strURL = [NSString stringWithFormat:@"https://%@:%@",model.fip, model.fport];
        
        [communityHttpDAO getCanBindingWithNeiName:model.fneib_name WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username WithUserID:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id URL:strURL Succeed:^(SYCanBindingModel *canBindingModel) {
            [SYAppConfig shareInstance].secondPlatformIPStr = strURL;
            [SYAppConfig shareInstance].bindedModel = canBindingModel;
            [SYAppConfig shareInstance].bindedModel.neibor_id.fopen_mode = canBindingModel.neibor_id.fopen_mode;
            [SYAppConfig saveUserLoginInfo];
            [SYAppConfig getUserLoginInfoWithUserID:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id];
            
            [Common saveNeiBindingUser];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[NSUserDefaults standardUserDefaults] setObject:model.fneib_name forKey:@"fneib_name"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_Binded_Neighbor object:model.fneib_name];
                [Common addAlertWithTitle:@"切换成功"];
                [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_REFRESH_GUARD object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPage" object:nil];
            });
            
        } fail:^(NSError *error) {
            [Common addAlertWithTitle:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
        }];
    }
}


- (void)layoutSubviews
{
    self.tableView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}



@end
