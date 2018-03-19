//
//  SYHomeAllGuardsViewController.m
//  YLB
//
//  Created by sayee on 17/4/1.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYHomeAllGuardsViewController.h"
#import "MJRefresh.h"
#import "SYHomeAllGuardsTableViewCell.h"
#import "SYCommunityHttpDAO.h"
#import "SYGuardMonitorViewController.h"
#import "SYGuardMontorView.h"

@interface SYHomeAllGuardsViewController ()<UITableViewDataSource, UITableViewDelegate, SYHomeAllGuardsTableViewCellDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *allGuardsMArr;
@property (nonatomic, retain) SYGuardMontorView *guardMontorView;

@end

@implementation SYHomeAllGuardsViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showReflashing:) name:SYNOTICE_ShowReflashingLinphone object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dissMissGuardView:) name:SYNOTICE_DissMissGuardView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChange) name:SYNOTICE_LOGIN_CHANGED object:nil];
    
    self.allGuardsMArr = [[NSMutableArray alloc] init];
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - overwrite
- (NSString *)backBtnTitle{
    return @"全部门禁";
}


#pragma mark - private
- (void)reflashData{
    
    if ([SYAppConfig shareInstance].selectedGuardMArr.count > 4) {
        [[SYAppConfig shareInstance].selectedGuardMArr removeObjectsInRange:NSMakeRange(4, [SYAppConfig shareInstance].selectedGuardMArr.count - 4)];
    }
    
    WEAK_SELF;
    SYCommunityHttpDAO *communityHttpDAO =[[SYCommunityHttpDAO alloc] init];
    //全部门禁
    [communityHttpDAO getMyLockListWithNeigborID:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username Succeed:^(NSArray *modelArr) {
        if (modelArr) {

            @synchronized (weakSelf.allGuardsMArr) {
                [weakSelf.allGuardsMArr removeAllObjects];
                [weakSelf.allGuardsMArr addObjectsFromArray:modelArr];
            }
            [weakSelf.tableView reloadData];
        }
        [weakSelf.tableView.mj_header endRefreshing];
    } fail:^(NSError *error) {
        [weakSelf.tableView.mj_header endRefreshing];
        //[weakSelf showErrorWithContent:[error.userInfo objectForKey:NSLocalizedDescriptionKey] duration:1];
    }];
}

- (void)initUI{
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = UIColorFromRGB(0xebebeb);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    WEAK_SELF;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf reflashData];
    }];
    [self.tableView.mj_header beginRefreshing];
}

- (void)hangUpCall{
    
    [[SYLinphoneManager instance] hangUpCall];
//    [[SYLinphoneManager instance] resignActive];
}


#pragma mark - noti
- (void)showReflashing:(NSNotification *)noti{
//    [self performSelector:@selector(hangUpCall) withObject:nil afterDelay:1.0]; //跨FS呼叫要等10秒才会收到call end 所以，直接退出登录就可以不需要等
    [self showMessageWithContent:@"门口机不在线" duration:2];
    
}

- (void)dissMissGuardView:(NSNotification *)noti{
    if (self.guardMontorView){
        [self.guardMontorView removeFromSuperview];
    }
}

//登录状态改变
- (void)loginChange{
    if (![SYLoginInfoModel isLogin] && self.guardMontorView) {
        [self.guardMontorView removeFromSuperview];
    }
}


#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allGuardsMArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SYHomeAllGuardsTableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify = @"SYHomeAllGuardsTableViewCell";
    
    SYHomeAllGuardsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[SYHomeAllGuardsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.indexPath = indexPath;
    
    if (self.allGuardsMArr.count > indexPath.row) {
        SYLockListModel *model = [self.allGuardsMArr objectAtIndex:indexPath.row];
        [cell updateGuardTitle:model.lock_name];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
    if (self.isAllGuardIn) {
        if (self.allGuardsMArr.count > indexPath.row) {
            SYLockListModel *model = [self.allGuardsMArr objectAtIndex:indexPath.row];
            
//            self.guardMontorView = [[SYGuardMontorView alloc] initWithFrame:[UIApplication sharedApplication].delegate.window.bounds WithLockListModel:model];
//            [[UIApplication sharedApplication].delegate.window addSubview:self.guardMontorView];
            
            SYGuardMonitorViewController *subAccountInfoViewController = [[SYGuardMonitorViewController alloc] initWithCall:nil GuardInfo:model InComingCall:NO];
            [FrameManager pushViewController:subAccountInfoViewController animated:YES];
        }
    }
    else{
        [self guardSelect:indexPath];
    }
}


#pragma mark - SYHomeAllGuardsTableViewCell delegate
- (void)guardSelect:(NSIndexPath *)indexPath{

    if (self.allGuardsMArr.count > indexPath.row) {
        SYLockListModel *model = [self.allGuardsMArr objectAtIndex:indexPath.row];
        
        BOOL isHadModel = NO;
        for(SYLockListModel *modelTemp in [SYAppConfig shareInstance].selectedGuardMArr){
            if ([modelTemp.sip_number isEqualToString:model.sip_number]) {
                isHadModel = YES;
                break;
            }
        }
        
        //已经添加门禁则不再添加
        if (!isHadModel) {
            if (![SYAppConfig shareInstance].selectedGuardMArr) {
                [SYAppConfig shareInstance].selectedGuardMArr = [[NSMutableArray alloc] init];
            }
        
            if ([SYAppConfig shareInstance].selectedGuardMArr.count >= 4) {
                
                @synchronized ([SYAppConfig shareInstance].selectedGuardMArr) {
                    if (self.clickIndex >= 0 &&self.clickIndex < [SYAppConfig shareInstance].selectedGuardMArr.count) {
                        [[SYAppConfig shareInstance].selectedGuardMArr removeObjectAtIndex:self.clickIndex];
                        [[SYAppConfig shareInstance].selectedGuardMArr insertObject:model atIndex:self.clickIndex];
                    }
                    else{
                        [[SYAppConfig shareInstance].selectedGuardMArr removeLastObject];
                        [[SYAppConfig shareInstance].selectedGuardMArr addObject:model];
                    }
                }
            }else{
                [[SYAppConfig shareInstance].selectedGuardMArr addObject:model];
            }
            
            [SYAppConfig saveMyHistoryNeighborLockList];
            [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_REFRESH_GUARD object:nil];
        }
        else{
            [self showMessageWithContent:@"已添加该门锁" duration:1];
            return;
        }
    }
    [FrameManager popViewControllerAnimated:YES];
}


@end
