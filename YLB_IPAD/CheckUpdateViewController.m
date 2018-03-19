//
//  InfomationViewController.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/8/7.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "CheckUpdateViewController.h"

@interface CheckUpdateViewController ()
@property (nonatomic, strong) UIImageView *iconImage;
@property (nonatomic, strong) UILabel *lblName;
@property (nonatomic, strong) UILabel *lblVersion;
@property (nonatomic, strong) UIButton *btnInfo;
@property (nonatomic, strong) UIButton *btnUpdate;
@property (nonatomic, strong) UIView *underLineView;
@property (nonatomic, strong) UILabel *lblTitle;
@end

@implementation CheckUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
}

- (void)initUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.frame = CGRectMake(0, 0, screenWidth * 0.7, screenHeight);
    
    UIButton *btnReturn = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReturn.frame = CGRectMake(0, 10, 70, 50);
    [btnReturn setImage:[UIImage imageNamed:@"last.png"] forState:UIControlStateNormal];
    [btnReturn addTarget:self action:@selector(ExitSubView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnReturn];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = @"版本信息";
    self.lblTitle = lblTitle;
    [self.view addSubview:lblTitle];
    
    UIImageView *iconImage = [[UIImageView alloc] init];
    iconImage.image = [UIImage imageNamed:@"sy_iconImage@2x"];
    [self.view addSubview:iconImage];
    self.iconImage = iconImage;
    
    self.lblName = [[UILabel alloc] init];
    self.lblName.textAlignment = NSTextAlignmentCenter;
    self.lblName.text = @"友邻邦HD";
    [self.view addSubview:self.lblName];
    
    self.lblVersion = [[UILabel alloc] init];
    self.lblVersion.textAlignment = NSTextAlignmentCenter;
    self.lblVersion.text = [NSString stringWithFormat:@"当前版本号：%@",[SYAppConfig appVersion]];
    [self.view addSubview:self.lblVersion];
    
    self.btnInfo = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnInfo setTitle:@"版本信息" forState:UIControlStateNormal];
    [self.btnInfo setBackgroundColor:UIColorFromRGB(0xEC5F05)];
    [self.btnInfo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btnInfo.layer.cornerRadius = 20.0f;
    self.btnInfo.layer.masksToBounds = YES;
    [self.view addSubview:self.btnInfo];
    
    self.btnUpdate = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnUpdate setTitle:@"检查更新" forState:UIControlStateNormal];
    [self.btnUpdate setBackgroundColor:UIColorFromRGB(0xEC5F05)];
    [self.btnUpdate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btnUpdate.layer.cornerRadius = 20.0f;
    self.btnUpdate.layer.masksToBounds = YES;
    //[self.view addSubview:self.btnUpdate];
    
    _underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth - dockWidth - 0, 1)];
    _underLineView.backgroundColor = underLineColor;
    [self.view addSubview:_underLineView];
}

- (void)viewWillLayoutSubviews{
    
    self.view.frame = CGRectMake(screenWidth * 0.3, 0, screenWidth * 0.7, screenHeight);
    
    self.iconImage.frame = CGRectMake(self.view.frame.size.width * 0.5 - 50, 200, 100, 100);
    self.lblName.frame = CGRectMake(0, CGRectGetMaxY(self.iconImage.frame) + 5, self.view.frame.size.width, 30);
    self.lblVersion.frame = CGRectMake(0, CGRectGetMaxY(self.lblName.frame) + 5, self.view.frame.size.width, 30);
    self.btnInfo.frame = CGRectMake(70, CGRectGetMaxY(self.lblVersion.frame) + 120, self.view.frame.size.width - 140, 40);
    self.btnUpdate.frame = CGRectMake(70, CGRectGetMaxY(self.btnInfo.frame) + 10, self.view.frame.size.width - 140, 40);
    
    self.lblTitle.frame = CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50);
}

- (void)ExitSubView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeDrawer"
                                                        object:nil];
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
