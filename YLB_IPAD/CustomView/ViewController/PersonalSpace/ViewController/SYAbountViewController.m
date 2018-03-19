//
//  SYAbountViewController.m
//  YLB
//
//  Created by YAYA on 2017/3/18.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYAbountViewController.h"
#import "SYTextDescriptionViewController.h"

#define APPID   @"1127316147"
typedef enum {
    GradBtnTag = 0,
    FunctionBtnTag,
    ItemBtnTag
}btnTag;

@interface SYAbountViewController ()
@property (nonatomic, strong) UIView *underLineView;
@property (nonatomic, strong) UILabel *lblTitle;
@end

@implementation SYAbountViewController

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
    return @"关于";
}


- (void)initUI{
    
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width * 0.7, self.view.frame.size.height);
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.view.width - 20, self.view.height - 20)];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    UIImage *img = [UIImage imageNamed:@"sy_iconImage"];
    UIImageView *iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
    iconImgView.image = img;
    iconImgView.center = CGPointMake(bgView.width * 0.5, bgView.height * 0.3);
    [bgView addSubview:iconImgView];
    
    UILabel *appNameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, iconImgView.bottom + 10, bgView.width, 20)];
    appNameLab.textColor = UIColorFromRGB(0x555555);
    appNameLab.font = [UIFont systemFontOfSize:16.0];
    appNameLab.textAlignment = NSTextAlignmentCenter;
    appNameLab.text = [SYAppConfig appDisplayName];
    [bgView addSubview:appNameLab];
    
    UILabel *appVersionLab = [[UILabel alloc] initWithFrame:CGRectMake(0, appNameLab.bottom + 10, bgView.width, 20)];
    appVersionLab.textColor = UIColorFromRGB(0x999999);
    appVersionLab.font = [UIFont systemFontOfSize:12.0];
    appVersionLab.textAlignment = NSTextAlignmentCenter;
    appVersionLab.text = [NSString stringWithFormat:@"当前版本号：%@",[SYAppConfig appVersion]];
    [bgView addSubview:appVersionLab];
    
    UIButton *gradBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    gradBtn.tag = GradBtnTag;
    gradBtn.frame = CGRectMake(70, appVersionLab.bottom + 100, bgView.width - 140, 40);
    gradBtn.layer.cornerRadius = 20;
    gradBtn.layer.masksToBounds = YES;
    [gradBtn setTitle:@"去评分" forState:UIControlStateNormal];
    gradBtn.backgroundColor = UIColorFromRGB(0xEC5F05);
    [gradBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    gradBtn.center = CGPointMake(bgView.width * 0.5, gradBtn.centerY);
    //[bgView addSubview:gradBtn];
    
    UIButton *functionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    functionBtn.frame = CGRectMake(70, gradBtn.bottom + 10, bgView.width - 140, gradBtn.height);
    functionBtn.layer.cornerRadius = 20;
    functionBtn.layer.masksToBounds = YES;
    [functionBtn setTitle:@"功能介绍" forState:UIControlStateNormal];
    functionBtn.backgroundColor = UIColorFromRGB(0xEC5F05);
    [functionBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    functionBtn.tag = FunctionBtnTag;
    functionBtn.center = CGPointMake(bgView.width * 0.5, functionBtn.centerY);
    [bgView addSubview:functionBtn];

    UILabel *companyCopyRightLab = [[UILabel alloc] initWithFrame:CGRectMake(0, bgView.height - 25, bgView.width, 15)];
    companyCopyRightLab.textColor = UIColorFromRGB(0x999999);
    companyCopyRightLab.font = [UIFont systemFontOfSize:12.0];
    companyCopyRightLab.text = @"Copyright © 2015 - 2017 Sayee. All Rights Reserved.";
    companyCopyRightLab.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    companyCopyRightLab.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:companyCopyRightLab];
    
    UILabel *companyLab = [[UILabel alloc] initWithFrame:CGRectMake(0, companyCopyRightLab.top - 25, bgView.width, 15)];
    companyLab.textColor = UIColorFromRGB(0x999999);
    companyLab.font = [UIFont systemFontOfSize:12.0];
    companyLab.text = @"赛翼智能 版权所有";
    companyLab.textAlignment = NSTextAlignmentCenter;
    companyLab.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [bgView addSubview:companyLab];
    
    UIButton *itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    itemBtn.frame = CGRectMake(0, companyLab.top - 30, bgView.width, 20);
    itemBtn.tag = ItemBtnTag;
    [itemBtn setTitle:@"用户服务协议" forState:UIControlStateNormal];
    [itemBtn titleLabel].font = [UIFont systemFontOfSize:14.0];
    [itemBtn setTitleColor:UIColorFromRGB(0xEC5F05) forState:UIControlStateNormal];
    [itemBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    itemBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [bgView addSubview:itemBtn];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btnReturn = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReturn.frame = CGRectMake(0, 10, 70, 50);
    [btnReturn setImage:[UIImage imageNamed:@"last.png"] forState:UIControlStateNormal];
    [btnReturn addTarget:self action:@selector(ExitSubView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnReturn];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = @"友邻邦HD";
    [self.view addSubview:lblTitle];
    self.lblTitle = lblTitle;
    
    self.underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth - dockWidth - 0, 1)];
    _underLineView.backgroundColor = underLineColor;
    [self.view addSubview:_underLineView];
}

- (void)ExitSubView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeDrawer"
                                                        object:nil];
}

- (void)viewWillLayoutSubviews{
    
    self.view.frame = CGRectMake(screenWidth * 0.3, 0, screenWidth * 0.7, screenHeight);
    
    self.lblTitle.frame = CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50);
}

#pragma mark - event
- (void)btnClick:(UIButton *)btn{

    //使用条款和隐私政策
    if (btn.tag == ItemBtnTag) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openPrivate" object:nil];
        return;
        
        SYTextDescriptionViewController *textDescriptionViewController = [[SYTextDescriptionViewController alloc] initWithType:itemType];
        [FrameManager pushViewController:textDescriptionViewController animated:YES];
        
    }//去评分
    else if (btn.tag == GradBtnTag) {
        NSString *string = [NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8", APPID];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
    }//功能介绍
    else if (btn.tag == FunctionBtnTag) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openFunction" object:nil];
        return;
        
        SYTextDescriptionViewController *textDescriptionViewController = [[SYTextDescriptionViewController alloc] initWithType:functionType];
        [FrameManager pushViewController:textDescriptionViewController animated:YES];
        
    }
}
@end
