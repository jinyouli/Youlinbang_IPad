//
//  RoomManageCtrl.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/8/7.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "DeviceSaveCtrl.h"

@interface DeviceSaveCtrl ()<UITableViewDelegate,UITableViewDataSource,SYSettingTableViewCellDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, strong) UIView *underLineView;
@end

@implementation DeviceSaveCtrl

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
    lblTitle.text = @"应用保护";
    [self.view addSubview:lblTitle];
    
    self.underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth - dockWidth - 0, 1)];
    _underLineView.backgroundColor = underLineColor;
    [self.view addSubview:_underLineView];
}

- (void)viewWillLayoutSubviews
{
    self.tableView.frame = CGRectMake(0, 50, self.view.bounds.size.width, self.view.bounds.size.height - 50);
    
    self.view.frame = CGRectMake(screenWidth * 0.3, 0, screenWidth * 0.7, screenHeight);
}

- (void)ExitSubView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeDrawer"
                                                        object:nil];
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth - dockWidth , 50)];
    view.backgroundColor = [UIColor clearColor];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify = @"SYSettingTableViewCell";
    SYSettingTableViewCell *settingableViewCell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!settingableViewCell) {
        settingableViewCell = [[SYSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        settingableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        settingableViewCell.delegate = self;
    }
    
    settingableViewCell.rectCell = CGRectMake(self.view.frame.size.width - 80, 0, 110, 50);
    [settingableViewCell updateLeftInfo:@"允许指纹方式解锁" Type:switchType];
    
//    if (indexPath.section == 0) {
//        [settingableViewCell updateLeftInfo:@"应用保护" Type:switchType];
//    }else if (indexPath.section == 1) {
//        if (indexPath.row == 0) {
//            [settingableViewCell updateLeftInfo:@"显示手势轨迹" Type:switchType];
//            settingableViewCell.underLineView.hidden = NO;
//        }else if (indexPath.row == 1) {
//            [settingableViewCell updateLeftInfo:@"允许指纹方式解锁" Type:switchType];
//        }
//    }
    
    NSString *isDeviceSave = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceSave"];
    
    if ([isDeviceSave isEqualToString:@"YES"]) {
        settingableViewCell.rightSwitch.on = YES;
    }else{
        settingableViewCell.rightSwitch.on = NO;
    }
    
    return settingableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)switchChange:(BOOL)change
{
    if (change) {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"DeviceSave"];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"DeviceSave"];
    }
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
