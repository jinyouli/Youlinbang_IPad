//
//  SYMyMessageDetailViewController.m
//  YLB
//
//  Created by sayee on 17/4/7.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYMyMessageDetailViewController.h"
#import "SYNoticeByPagerModel.h"
#import "SYCustomScrollView.h"

@interface SYMyMessageDetailViewController ()
@property (nonatomic, strong) SYCustomScrollView *customScrollView;
@property (nonatomic, retain) UIImageView *headerImgView;
@property (nonatomic, retain) UILabel *titleLab;
@property (nonatomic, retain) UILabel *timeLab;
@property (nonatomic, assign) SYMyMessageNoticeType type;
@property (nonatomic, strong) UIButton *btnReturn;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) SYNoticeByPagerModel *model;
@property (nonatomic, strong) UILabel *contentLab;

@end

@implementation SYMyMessageDetailViewController

- (instancetype)initWithModel:(SYNoticeByPagerModel *)model WithType:(SYMyMessageNoticeType)type{

    if (self = [super init]) {
        self.type = type;
        [self initUIWithModel:model];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma overwrite
- (NSString *)backBtnTitle{
    return @"消息详情";
}


#pragma mark - private
- (void)initUIWithModel:(SYNoticeByPagerModel *)model{
    
    self.model = model;
    self.view.backgroundColor = UIColorFromRGB(0xebebeb);
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width * 0.7, self.view.frame.size.height);
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, self.view.width_sd, 50)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    self.topView = topView;
    
    UIImage *img = [UIImage imageNamed:@"sy_navigation_normal_header"];
    self.headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, topView.height_sd - 10, topView.height_sd - 10)];
    self.headerImgView.image = img;
    self.headerImgView.layer.cornerRadius = self.headerImgView.height_sd * 0.5;
    self.headerImgView.layer.masksToBounds = YES;
    self.headerImgView.center = CGPointMake(self.headerImgView.centerX, topView.height * 0.5f);
    [topView addSubview:self.headerImgView];
    
    float fTitleLabLeft = self.headerImgView.right_sd + 10;
    self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(fTitleLabLeft, self.headerImgView.top_sd, topView.width_sd - fTitleLabLeft - 10, 20)];
    self.titleLab.font = [UIFont systemFontOfSize:14.0];
    self.titleLab.text = model.title;
    [topView addSubview:self.titleLab];
    
    self.timeLab = [[UILabel alloc] initWithFrame:CGRectMake(self.titleLab.left_sd, self.titleLab.bottom_sd, self.titleLab.width_sd, 18)];
    self.timeLab.font = [UIFont systemFontOfSize:12.0];
    self.timeLab.textColor = UIColorFromRGB(0x999999);
    self.timeLab.text = model.time;
    [topView addSubview:self.timeLab];
    
    //======中间view========
    UIFont *font = [UIFont systemFontOfSize:14];
    CGSize size;
    if (self.type == TenementMessageType) {
        size = [model.fcontent sizeWithFont:font andSize:CGSizeMake(self.view.width_sd - self.titleLab.left_sd, MAXFLOAT)];
    }else{
        size = [model.content sizeWithFont:font andSize:CGSizeMake(self.view.width_sd - self.titleLab.left_sd, MAXFLOAT)];
    }
    
    self.customScrollView = [[SYCustomScrollView alloc] initWithFrame:CGRectMake(0, topView.bottom_sd + 5, self.view.width_sd, self.view.height_sd - topView.bottom_sd - 5)];
    self.customScrollView.contentSize = CGSizeMake(0, size.height);
    self.customScrollView.bounces = NO;
    self.customScrollView.backgroundColor = [UIColor whiteColor];
    self.customScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.customScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.customScrollView];
    
    UILabel *contentLab = [[UILabel alloc] initWithFrame:CGRectMake(self.titleLab.left_sd * 0.5, 0, size.width, size.height)];
    contentLab.font = font;
    contentLab.text = model.content;
    contentLab.textAlignment = NSTextAlignmentLeft;
    contentLab.backgroundColor = [UIColor clearColor];
    contentLab.numberOfLines = 0;
    //contentLab.lineBreakMode = NSLineBreakByCharWrapping;
    [self.customScrollView addSubview:contentLab];
    self.contentLab = contentLab;
    
    //物业动态
    if (self.type == TenementMessageType) {
        self.titleLab.text = model.fname;
        contentLab.text = model.fcontent;
        self.timeLab.text = model.fcreatetime;
    }
    
    UIButton *btnReturn = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReturn.frame = CGRectMake(0, 10, 70, 50);
    [btnReturn setImage:[UIImage imageNamed:@"last.png"] forState:UIControlStateNormal];
    [btnReturn addTarget:self action:@selector(ExitSubView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnReturn];
    self.btnReturn = btnReturn;
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, self.view.bounds.size.width - 100, 50)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = model.title;
    [self.view addSubview:lblTitle];
    self.lblTitle = lblTitle;
}

- (void)viewWillLayoutSubviews
{
    self.view.frame = CGRectMake(screenWidth * 0.3, 0, screenWidth * 0.7, screenHeight);
    
    self.topView.frame = CGRectMake(0, 50, self.view.width_sd, 50);
    
    self.headerImgView.frame = CGRectMake(10, 0, self.topView.height_sd - 10, self.topView.height_sd - 10);
    
    float fTitleLabLeft = self.headerImgView.right_sd + 10;
    self.titleLab.frame = CGRectMake(fTitleLabLeft, self.headerImgView.top_sd, self.topView.width_sd - fTitleLabLeft - 10, 20);
    
    self.timeLab.frame = CGRectMake(self.titleLab.left_sd, self.titleLab.bottom_sd, self.titleLab.width_sd, 18);
    
    self.customScrollView.frame = CGRectMake(0, self.topView.bottom_sd + 5, self.view.width_sd, self.view.height_sd - self.topView.bottom_sd - 5);
    
    UIFont *font = [UIFont systemFontOfSize:14];
    CGSize size;
    if (self.type == TenementMessageType) {
        size = [self.model.fcontent sizeWithFont:font andSize:CGSizeMake(self.view.width_sd - self.titleLab.left_sd, MAXFLOAT)];
    }else{
        size = [self.model.content sizeWithFont:font andSize:CGSizeMake(self.view.width_sd - self.titleLab.left_sd, MAXFLOAT)];
    }
    self.contentLab.frame = CGRectMake(self.titleLab.left_sd * 0.5, 0, size.width, size.height);
    self.btnReturn.frame = CGRectMake(0, 10, 70, 50);
    self.lblTitle.frame = CGRectMake(50, 10, self.view.bounds.size.width - 100, 50);
}

- (void)ExitSubView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeDrawerDetail"
                                                        object:nil];
}

@end
