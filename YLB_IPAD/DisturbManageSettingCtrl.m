//
//  RoomManageCtrl.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/8/7.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "DisturbManageSettingCtrl.h"

@interface DisturbManageSettingCtrl ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, retain) UITableView *tableView;

@end

@implementation DisturbManageSettingCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(0xebebeb);
    [self initUI];
}

- (void)initUI
{
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width * 0.7, self.view.frame.size.height);
    
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
    lblTitle.text = @"勿扰设置";
    [self.view addSubview:lblTitle];
    
    self.underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth - dockWidth - 0, 1)];
    _underLineView.backgroundColor = underLineColor;
    [self.view addSubview:_underLineView];
}

- (void)viewWillLayoutSubviews
{
    self.view.frame = CGRectMake(screenWidth * 0.3, 0, screenWidth * 0.7, screenHeight);
    
    self.tableView.frame = CGRectMake(0, 55, self.view.bounds.size.width, self.view.bounds.size.height - 50);
}

- (void)ExitSubView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeDrawer"
                                                        object:nil];
}

#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SYVideoClearTableViewCellHeight;
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identify = @"SYVideoClearTableViewCell";
    SYVideoClearTableViewCell *videoClearTableViewCell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!videoClearTableViewCell) {
        videoClearTableViewCell = [[SYVideoClearTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        videoClearTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    //update data
    BOOL isShowRightImg = NO;
    NSString *leftInfo;
    if (indexPath.section == 0) {
        leftInfo = @"全天开启";
        
        
        if ([SYLoginInfoModel shareUserInfo].isAllowNoDusturbMode && ![SYLoginInfoModel shareUserInfo].isAllowHardDusturbMode) {
            isShowRightImg = YES;
        }
        
    }else if (indexPath.section == 1) {
        leftInfo = @"仅夜间开启";
        
        if ([SYLoginInfoModel shareUserInfo].isAllowNoDusturbMode && [SYLoginInfoModel shareUserInfo].isAllowHardDusturbMode) {
            isShowRightImg = YES;
        }
        
    }else if (indexPath.section == 2) {
        
        if (![SYLoginInfoModel shareUserInfo].isAllowNoDusturbMode) {
            isShowRightImg = YES;
        }
        leftInfo = @"关闭";
    }
    [videoClearTableViewCell updateLeftInfo:leftInfo ShowRightImg:isShowRightImg];
    
    return videoClearTableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    for (int i=0; i<3; i++) {
        SYVideoClearTableViewCell *disturbCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        disturbCell.arrowImgView.hidden = YES;
    }
    
    SYVideoClearTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        
        cell.arrowImgView.hidden = NO;
        [SYLoginInfoModel shareUserInfo].isAllowNoDusturbMode = YES;
        [SYLoginInfoModel shareUserInfo].isAllowHardDusturbMode = NO;
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isAllowNoDusturbMode"];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"isAllowHardDusturbMode"];
    }else if (indexPath.section == 1) {
        
        cell.arrowImgView.hidden = NO;
        [SYLoginInfoModel shareUserInfo].isAllowNoDusturbMode = YES;
        [SYLoginInfoModel shareUserInfo].isAllowHardDusturbMode = YES;
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isAllowNoDusturbMode"];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isAllowHardDusturbMode"];
        
    }else if (indexPath.section == 2) {
        
        cell.arrowImgView.hidden = NO;
        [SYLoginInfoModel shareUserInfo].isAllowNoDusturbMode = NO;
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"isAllowNoDusturbMode"];
    }
//    else{
//        if (cell.arrowImgView.isHidden) {
//            cell.arrowImgView.hidden = NO;
//            [SYLoginInfoModel shareUserInfo].isAllowNoDusturbMode = YES;
//        }else{
//            cell.arrowImgView.hidden = YES;
//            [SYLoginInfoModel shareUserInfo].isAllowNoDusturbMode = NO;
//        }
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
