//
//  SYHouseManageViewController.m
//  YLB
//
//  Created by YAYA on 2017/3/18.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYHouseManageViewController.h"
#import "SYHouseManageTableViewCell.h"
#import "SYCommunityHttpDAO.h"
#import "SYSubAccountViewController.h"
#import "MBProgressHUD.h"


@interface SYHouseManageViewController ()<UITableViewDelegate, UITableViewDataSource, SYHouseManageTableViewCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, retain) NSArray *sourcesArr;
@end

@implementation SYHouseManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //NSKeyedUnarchiver是真正意义上的深复制
    self.sourcesArr = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:[SYLoginInfoModel shareUserInfo].configInfoModel.sipInfoList]];

    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = UIColorFromRGB(0xebebeb);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];


    //===提交按钮==
    self.submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.submitButton.frame = CGRectMake(0, 0, 70, 44);
    self.submitButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.submitButton setTitle:@"免打扰" forState:UIControlStateNormal];

    [self.submitButton addTarget:self action:@selector(submitButtonClick:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:self.submitButton];
    UIBarButtonItem *flexSpacerl = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    flexSpacerl.width = -15;
    self.navigationItem.rightBarButtonItems = @[flexSpacerl, backItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - overwrite
- (NSString *)backBtnTitle{
    return @"房产管理";
}


#pragma mark - private



#pragma mark - event 
- (void)submitButtonClick:(UIButton *)btn{
    
    if ([self.submitButton.titleLabel.text isEqualToString:@"提交"]) {
        WEAK_SELF;
        [self showWithContent:@"提交中"];
        
        __block int nCount = self.sourcesArr.count; //接口要一个一个提交，所以只能用for循环
        for (int i = 0 ; i < self.sourcesArr.count ; i++) {
            
            SipInfoModel *model = [self.sourcesArr objectAtIndex:i];

            [[[SYCommunityHttpDAO alloc] init] updateDisturbingWithHouseID:model.house_id WithDisturbing:model.disturbing Succeed:^{
                
                if (nCount <= 0) {
                    @synchronized ([SYLoginInfoModel shareUserInfo].configInfoModel.sipInfoList) {
                        [[SYLoginInfoModel shareUserInfo].configInfoModel.sipInfoList removeAllObjects];
                        [[SYLoginInfoModel shareUserInfo].configInfoModel.sipInfoList addObjectsFromArray:weakSelf.sourcesArr];
                    }
                    [SYLoginInfoModel saveWithSYLoginInfo];
                    [weakSelf.tableView reloadData];
                    [weakSelf.submitButton setTitle:@"免打扰" forState:UIControlStateNormal];
                    [weakSelf showSuccessWithContent:@"免打扰设置成功" duration:1];
                }
            } fail:^(NSError *error) {
                if (nCount <= 0) {
                    [weakSelf.tableView reloadData];
                    [weakSelf showErrorWithContent:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]] duration:1];
                    [weakSelf.submitButton setTitle:@"免打扰" forState:UIControlStateNormal];
                }
            }];
            nCount--;
        }
        return;
    }
    
    [self.submitButton setTitle:@"提交" forState:UIControlStateNormal];
    [self.tableView reloadData];
}


#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourcesArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SYHouseManageTableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify = @"SYHouseManageTableViewCell";
    
    SYHouseManageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[SYHouseManageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }

    cell.indexPath = indexPath;
    if ([self.submitButton.titleLabel.text isEqualToString:@"提交"]) {
        [cell showUnDisturb:YES];
    }else{
        [cell showUnDisturb:NO];
    }

    if (self.sourcesArr.count > indexPath.row) {
        SipInfoModel *model = [self.sourcesArr objectAtIndex:indexPath.row];
        [cell setInfoModel:model];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.sourcesArr.count > indexPath.row) {
        SipInfoModel *model = [self.sourcesArr objectAtIndex:indexPath.row];
        
        if (!model.is_owner) {
            MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hub.mode = MBProgressHUDModeText;
            hub.label.text = @"非户主没有权限操作子账号";
            [hub hideAnimated:YES afterDelay:1.0];
            return;
        }
        
        SYSubAccountViewController *subAccountViewController = [[SYSubAccountViewController alloc] initWithSipInfoModel:model];
        [FrameManager pushViewController:subAccountViewController animated:YES];
    }
}


#pragma mark - SYHouseManageTableViewCell delegate
- (void)houseManageTableViewCellSelectUnDisturbViewWithIndexPath:(NSIndexPath *)indexPath{
    
    if (self.sourcesArr.count > indexPath.row) {
        SipInfoModel *model = [self.sourcesArr objectAtIndex:indexPath.row];
        model.disturbing = !model.disturbing;
        [self.tableView reloadData];
    }
}
@end
