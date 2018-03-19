//
//  SYGesturePWViewController.m
//  YLB
//
//  Created by YAYA on 2017/3/19.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYGesturePWViewController.h"
#import "SYResetGesturePassWordViewController.h"
#import "SYSettingTableViewCell.h"

@interface SYGesturePWViewController ()<UITableViewDelegate, UITableViewDataSource, SYSettingTableViewCellDelegate>

@property (nonatomic, retain) UITableView *tableView;

@end

@implementation SYGesturePWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)backBtnTitle{
    return @"手势";
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
 }


#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SYSettingTableViewCellHeight;
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identify = @"SYSettingTableViewCell";
    SYSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[SYSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    //update data
    if (indexPath.section == 0) {
        [cell updateLeftInfo:@"显示手势轨迹" Type:seitchWithSetGesturePWType];
    }else{
        [cell updateLeftInfo:@"修改手势密码" Type:arrowType];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        SYResetGesturePassWordViewController *vc = [[SYResetGesturePassWordViewController alloc] initWithCircleViewType:CircleViewTypeSetting ShowPWBtn:YES];
        vc.isResetGesturePW = YES;
        [FrameManager pushViewController:vc animated:YES];
    }
}


#pragma - mark SYSettingTableViewCellDelegate
- (void)switchChange:(BOOL)change{
    [SYLoginInfoModel shareUserInfo].isShowGesturePath = change;
    [SYLoginInfoModel saveWithSYLoginInfo];
}
@end
