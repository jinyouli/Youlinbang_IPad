//
//  DoorListViewController.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/8/5.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "DoorListViewController.h"
#import "DoorListTableViewCell.h"
#import "SYGuardMonitorViewController.h"

@interface DoorListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayLockList;
@property (nonatomic, strong) UILabel *lblTitle;
@end

@implementation DoorListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColorFromRGB(0xebebeb);
    [self initUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeFunction) name:@"closeFunction" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)initUI
{
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width * 0.7, self.view.frame.size.height);
    self.arrayLockList = [NSMutableArray array];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    UIButton *btnReturn = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReturn.frame = CGRectMake(0, 10, 70, 50);
    [btnReturn setImage:[UIImage imageNamed:@"last.png"] forState:UIControlStateNormal];
    [btnReturn addTarget:self action:@selector(ExitSubView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnReturn];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = @"门禁列表";
    [self.view addSubview:lblTitle];
    self.lblTitle = lblTitle;
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"allLocks" object:nil];
    [self loadData];
}

- (void)closeFunction
{
    for (int i=0; i<self.arrayLockList.count; i++) {
        DoorListTableViewCell *cell = (DoorListTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cell showCancel];
    }
}

- (void)loadData
{
    WEAK_SELF;
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    //全部门禁
    [communityHttpDAO getMyLockListWithNeigborID:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username Succeed:^(NSArray *modelArr) {
        
        if (modelArr.count > 0) {
            weakSelf.arrayLockList = [[NSMutableArray alloc] initWithArray:modelArr];
            
            if ([SYAppConfig shareInstance].selectedGuardMArr.count == 0) {
                NSInteger count = modelArr.count;
                if (count > 3) {
                    count = 3;
                }
                for (int i = 0; i < count; i++) {
                    SYLockListModel *model = [modelArr objectAtIndex:i];
                    [[SYAppConfig shareInstance].selectedGuardMArr addObject:model];
                }
            }
            [SYAppConfig saveMyHistoryNeighborLockList];
            [weakSelf.tableView reloadData];
        }
        
    } fail:^(NSError *error) {
        
        //[Common addAlertWithTitle:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
    }];
}

- (void)viewWillLayoutSubviews
{
    self.view.frame = CGRectMake(screenWidth * 0.3, 0, screenWidth * 0.7, screenHeight);
    
    self.tableView.frame = CGRectMake(0, 50, self.view.bounds.size.width, self.view.bounds.size.height - 50);
    self.lblTitle.frame = CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50);
}

- (void)ExitSubView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeDrawer"
                                                        object:nil];
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.arrayLockList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify = @"DoorListTableViewCell";
    
    DoorListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[DoorListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.btnCallManager.tag = indexPath.row;
    if (self.LockSelectTag == otherTag) {
        cell.btnMoreFunction.hidden = NO;
        cell.btnCallManager.hidden = YES;
    }else{
        cell.btnMoreFunction.hidden = YES;
        cell.btnCallManager.hidden = NO;
        [cell.btnCallManager addTarget:self action:@selector(addNewDoor:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    SYLockListModel *model = [self.arrayLockList objectAtIndex:indexPath.row];
    [cell updateFrames:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    SYLockListModel *model = [self.arrayLockList objectAtIndex:indexPath.row];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"openMonitor"
//                                                        object:model];
    
    if (self.LockSelectTag == addTag) {
        
    }else if (self.LockSelectTag == changeTag) {
        [self guardChange:indexPath];
    }
}

- (void)addNewDoor:(UIButton *)btn
{
    if (self.LockSelectTag == addTag) {
        [self guardSelect:btn.tag];
    }else if (self.LockSelectTag == changeTag) {
        [self guardChange:[NSIndexPath indexPathForRow:btn.tag inSection:0]];
    }
}

#pragma mark - SYHomeAllGuardsTableViewCell delegate

//添加门锁
- (void)guardSelect:(NSInteger )selectedCell{
    
    if (self.arrayLockList.count > selectedCell) {
        SYLockListModel *model = [self.arrayLockList objectAtIndex:selectedCell];
        
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
            [Common showAlert:@"已添加该门锁"];
            return;
        }
    }
    [self ExitSubView];
}

//修改门锁
- (void)guardChange:(NSIndexPath *)indexPath{
    
    if (self.arrayLockList.count > indexPath.row) {
        SYLockListModel *model = [self.arrayLockList objectAtIndex:indexPath.row];
        
        if (![SYAppConfig shareInstance].selectedGuardMArr) {
            [SYAppConfig shareInstance].selectedGuardMArr = [[NSMutableArray alloc] init];
        }
        
        [[SYAppConfig shareInstance].selectedGuardMArr removeObjectAtIndex:self.clickIndex];
        [[SYAppConfig shareInstance].selectedGuardMArr insertObject:model atIndex:self.clickIndex];
        
        [SYAppConfig saveMyHistoryNeighborLockList];
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_REFRESH_GUARD object:nil];
    }
    [self ExitSubView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
