//
//  SYDiscoverViewController.m
//  YLB
//
//  Created by YAYA on 2017/3/12.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYDiscoverViewController.h"
#import "SYCustomScrollView.h"
#import "SYDiscoverCommunityNewsView.h"
#import "SYDiscoverAppCommandView.h"

@interface SYDiscoverViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIView *segmentBottomLine;
@property (nonatomic, strong) SYCustomScrollView *customScrollView;
@property (nonatomic, strong) SYDiscoverCommunityNewsView *discoverCommunityNewsView;
@property (nonatomic, strong) SYDiscoverAppCommandView *discoverAppCommandView;
@end

@implementation SYDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reflashNeighborData:) name:SYNOTICE_Binded_Neighbor object:nil];
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - overwrite
- (BOOL) showBackButton{
    return NO;
}


#pragma mark - private
- (void)initUI{
    
    self.view.backgroundColor = UIColorFromRGB(0xebebeb);
    
    //=====顶部  @"应用推荐", @"社区头条"=========
    float fSegmentedControlHeight = 40;
    NSArray *itemArr = [[NSArray alloc] initWithObjects:@"应用推荐", @"社区头条", nil];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.width_sd, 40)];
    topView.backgroundColor = UIColorFromRGB(0xebebeb);
    [self.view addSubview:topView];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArr];
    self.segmentedControl.frame = CGRectMake(14, 10, self.view.width_sd - 28, fSegmentedControlHeight);
    self.segmentedControl.backgroundColor = [UIColor whiteColor];
    self.segmentedControl.tintColor = [UIColor clearColor];
    [self.segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x999999), NSFontAttributeName : [UIFont systemFontOfSize:14.0]} forState:UIControlStateNormal];
    [self.segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName :  UIColorFromRGB(0xf23023), NSFontAttributeName : [UIFont systemFontOfSize:14.0]} forState:UIControlStateSelected];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlSelect:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.selectedSegmentIndex = 0;
    [topView addSubview:self.segmentedControl];
    
    self.segmentBottomLine = [[UIView alloc] initWithFrame:CGRectMake(self.segmentedControl.selectedSegmentIndex * (self.segmentedControl.width / itemArr.count), fSegmentedControlHeight - 4, (self.segmentedControl.width + 0) / itemArr.count, 4)];
    self.segmentBottomLine.backgroundColor = UIColorFromRGB(0xf23023);
    [self.segmentedControl addSubview:self.segmentBottomLine];
    
    
    //======中间各种view========
    self.customScrollView = [[SYCustomScrollView alloc] initWithFrame:CGRectMake(0, topView.bottom_sd + 5, self.view.width_sd, self.view.height_sd - self.segmentedControl.bottom_sd - 60)];
    self.customScrollView.contentSize = CGSizeMake(self.view.width * itemArr.count, 0);
    self.customScrollView.delegate = self;
    self.customScrollView.pagingEnabled = YES;
    self.customScrollView.bounces = NO;
    self.customScrollView.showsVerticalScrollIndicator = NO;
    self.customScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.customScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.customScrollView];

    self.discoverCommunityNewsView = [[SYDiscoverCommunityNewsView alloc] initWithFrame:[self getPropertyViewRect:1]];
    self.discoverAppCommandView = [[SYDiscoverAppCommandView alloc] initWithFrame:[self getPropertyViewRect:0]];
    [self.customScrollView addSubview:self.discoverAppCommandView];
    [self.customScrollView addSubview:self.discoverCommunityNewsView];

}

//"应用推荐", @"社区头条" 的frame
- (CGRect)getPropertyViewRect:(NSInteger)index {
    CGRect rect = self.view.bounds;
    rect.size.height = self.customScrollView.height_sd;
    rect.origin.y = 10;
    rect.origin.x = self.view.width * index;
    return rect;
}


#pragma mark - event
- (void)segmentedControlSelect:(UISegmentedControl *)segmentedCtl{
    
    [self.customScrollView setContentOffset:CGPointMake(self.view.width * segmentedCtl.selectedSegmentIndex, 0) animated:YES];
    
    WEAK_SELF;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.segmentBottomLine.frame = CGRectMake(weakSelf.segmentedControl.selectedSegmentIndex * weakSelf.segmentBottomLine.frame.size.width, weakSelf.segmentBottomLine.frame.origin.y, weakSelf.segmentBottomLine.frame.size.width, weakSelf.segmentBottomLine.frame.size.height);
    }];
}


#pragma mark - noti
//切换社区后，刷新社区头条及其他信息
- (void)reflashNeighborData:(NSNotification *)noti{
    //[self.discoverCommunityNewsView updateNewsData];
    [self.discoverAppCommandView updateAppsData];
}


#pragma mark - scrollview delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    double page = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
    
    if (self.segmentedControl.selectedSegmentIndex == page) {
        return;
    }
    
    WEAK_SELF;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.segmentBottomLine.frame = CGRectMake(page * weakSelf.segmentBottomLine.frame.size.width, weakSelf.segmentBottomLine.frame.origin.y, weakSelf.segmentBottomLine.frame.size.width, weakSelf.segmentBottomLine.frame.size.height);
    }];
    self.segmentedControl.selectedSegmentIndex = page;
}

@end
