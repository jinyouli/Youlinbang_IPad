//
//  SYFirstLaunchView.m
//  YLB
//
//  Created by sayee on 17/4/19.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYFirstLaunchView.h"


@interface SYFirstLaunchView () <UIScrollViewDelegate>

@property (nonatomic , retain) UIScrollView *scrollView;
@property (nonatomic , retain) UIPageControl *pageControl;
@end

@implementation SYFirstLaunchView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        
        self.backgroundColor = [UIColor redColor];
        
        //=====init ui=====
        int nTotalPageCount = 3;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:frame];
        self.scrollView.contentSize = CGSizeMake(nTotalPageCount * self.scrollView.width_sd, self.scrollView.height_sd);
        self.scrollView.delegate = self;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.bounces = NO;   //尾页的弹簧效果
        self.scrollView.pagingEnabled = YES;    //粘性效果
        [self addSubview:_scrollView];
        
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, _scrollView.frame.size.height - 24.0, _scrollView.frame.size.width, 20)];
        [_pageControl setNumberOfPages:nTotalPageCount];
        [self addSubview:self.pageControl];
        
        
        //添加引导图片
        for (int page = 0; page < 3; page++)
        {
            UIImage *imgPG = [UIImage imageNamed:[NSString stringWithFormat:@"sy_newFeature_%i",(page + 1)]];
            UIImageView *imgViewPG = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollView.width_sd * page, 0, self.frame.size.width, self.scrollView.height)];
            imgViewPG.image = imgPG;
            [self.scrollView addSubview:imgViewPG];
        }
        
        UIButton *gotoLoginViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        gotoLoginViewBtn.frame = CGRectMake(self.scrollView.width_sd * 2, self.scrollView.height_sd - self.scrollView.height_sd * 0.15 - 40, self.scrollView.width_sd, self.scrollView.height_sd * 0.15);
        [gotoLoginViewBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView  addSubview:gotoLoginViewBtn];

    }
    return self;
}



#pragma mark - event
- (void)btnClick:(UIButton *)btn{
    WEAK_SELF;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:1];
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         weakSelf.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [weakSelf removeFromSuperview];
                     }];
}


#pragma mark - UIScrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    uint page = (scrollView.contentOffset.x / scrollView.bounds.size.width);
    self.pageControl.currentPage = page;
}
@end
