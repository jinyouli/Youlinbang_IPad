//
//  SYMyMessgeViewController.m
//  YLB
//
//  Created by sayee on 17/4/7.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYMyMessgeViewController.h"
#import "SYCustomScrollView.h"
#import "SYMyMessageListView.h"

@interface SYMyMessgeViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIView *segmentBottomLine;
@property (nonatomic, strong) SYCustomScrollView *customScrollView;

@property (nonatomic, strong) SYMyMessageListView *myMessageListView;
@property (nonatomic, strong) SYMyMessageListView *neighborMessageListView;
@property (nonatomic, strong) SYMyMessageListView *systemMessageListView;
@property (nonatomic, strong) UIView *underLineView;
@property (nonatomic, strong) UILabel *lblTitle;
@end

@implementation SYMyMessgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - overwrite
- (NSString *)backBtnTitle{
    return @"我的消息";
}

#pragma mark - private
- (void)initUI{
    
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width * 0.7, self.view.frame.size.height);
    
    //添加报修单view
    self.neighborMessageListView = [[SYMyMessageListView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height - 50) WithType:self.type];
    [self.view addSubview:self.neighborMessageListView];
    
    UIButton *btnReturn = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReturn.frame = CGRectMake(0, 10, 70, 50);
    [btnReturn setImage:[UIImage imageNamed:@"last.png"] forState:UIControlStateNormal];
    [btnReturn addTarget:self action:@selector(ExitSubView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnReturn];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    self.lblTitle = lblTitle;
    
    self.underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth - dockWidth - 0, 1)];
    _underLineView.backgroundColor = underLineColor;
    [self.view addSubview:_underLineView];
    
    if (self.type == MyMessageType) {
        lblTitle.text = @"个人通知";
    }else if (self.type == NeighborMessageType) {
        lblTitle.text = @"社区公告";
    }
    
    [self.view addSubview:lblTitle];
}

- (void)viewWillLayoutSubviews
{
    self.view.frame = CGRectMake(screenWidth * 0.3, 0, screenWidth * 0.7, screenHeight);
    self.neighborMessageListView.frame = CGRectMake(0, 60, screenWidth, screenHeight - 50);
    self.lblTitle.frame = CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50);
    self.underLineView.frame = CGRectMake(0, 60, kScreenWidth - dockWidth - 0, 1);
}



- (void)ExitSubView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeDrawer"
                                                        object:nil];
}

//@"个人通知", @"社区公告", @"物业动态" 的frame
- (CGRect)getPropertyViewRect:(NSInteger)index {
    CGRect rect = self.view.bounds;
    rect.size.height = self.customScrollView.height_sd;
    rect.origin.y = 0;
    rect.origin.x = self.view.width * index;
    return rect;
}


#pragma mark - event
- (void)clearBtnClick:(UIButton *)btn{

}

- (void)segmentedControlSelect:(UISegmentedControl *)segmentedCtl{
    
    [self.customScrollView setContentOffset:CGPointMake(self.view.width * segmentedCtl.selectedSegmentIndex, 0) animated:YES];
    
    WEAK_SELF;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.segmentBottomLine.frame = CGRectMake(weakSelf.segmentedControl.selectedSegmentIndex * weakSelf.segmentBottomLine.frame.size.width, weakSelf.segmentBottomLine.frame.origin.y, weakSelf.segmentBottomLine.frame.size.width, weakSelf.segmentBottomLine.frame.size.height);
    }];
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
