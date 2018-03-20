//
//  SYHomeBannerCollectionViewCell.m
//  YLB
//
//  Created by sayee on 17/8/25.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYHomeBannerCollectionViewCell.h"
#import "CycleScrollView.h"
#import "UIImageView+WebCache.h"
#import "SYAdvertInfoListModel.h"

@interface SYHomeBannerCollectionViewCell()

@property (nonatomic,strong) CycleScrollView *bannerView;
@property (nonatomic,strong) UIPageControl *pageControl;
@property (nonatomic,strong) UIView *mainView;

@end

@implementation SYHomeBannerCollectionViewCell

- (id)initWithFrame:(CGRect)frame{
    
    if (self=[super initWithFrame:frame]) {
        [self configSubViews];
        
    }
    return self;
}

#pragma mark - private
- (void)configSubViews{
    self.backgroundColor = UIColorFromRGB(0xebebeb);
    
    self.mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, SYHomeBannerCollectionViewCellHeight)];
    self.mainView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.mainView];
    
    self.bannerView = ({
        CycleScrollView *bannerView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, self.mainView.width_sd, self.mainView.height_sd) animationDuration:0];
        bannerView.scrollView.showsHorizontalScrollIndicator = NO;
        bannerView.scrollView.showsVerticalScrollIndicator = NO;
        bannerView.scrollView.pagingEnabled = YES;
        bannerView;
    });
    [self.mainView addSubview:_bannerView];
    //self.bannerView.nType = DiscoverVCType;
    
    self.pageControl = ({
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.bannerView.height_sd - 20, self.mainView.width_sd, 20)];
        [pageControl addTarget:self action:@selector(pageControlClick:) forControlEvents:UIControlEventValueChanged];
        pageControl;
    });
    [self.mainView addSubview:_pageControl];
    
}


#pragma mark - event
- (void)pageControlClick:(UIPageControl *)pageControl{
    //    self.bannerView.currentPageIndex = pageControl.currentPage;
    //    [self.bannerView updateScrollContentOffetWithPage:pageControl.currentPage];
}


#pragma mark - public
-(void)updateBannerInfo:(NSArray *)banners{
    
    NSMutableArray *bannerArr = [[NSMutableArray alloc] init];
    for (SYAdvertInfoListModel *mdoel in banners) {
        if ([mdoel.fposition isEqualToString:@"2"]) {
            for (SYAdvertInfoModel *infoModel in mdoel.pic_list) {
                NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:infoModel.img_path,@"img_path", infoModel.fredirecturl,@"fredirecturl", nil];
                [bannerArr addObject:dic];
            }
        }
    }
    
    self.pageControl.numberOfPages = (bannerArr.count > 0) ? bannerArr.count : 3;
    self.bannerView.currentPageIndex = 0;
    
    WEAK_SELF;
    self.bannerView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        
        weakSelf.pageControl.currentPage = weakSelf.bannerView.currentPageIndex;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, weakSelf.bannerView.width, weakSelf.bannerView.height_sd)];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.clipsToBounds = YES;
        if (!bannerArr || (bannerArr.count - 1) < pageIndex || bannerArr.count == 0) {
            [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"banner_%li",pageIndex]]];
            return imageView;
        }
        
        if (bannerArr.count > pageIndex) {
            NSDictionary *dic = [bannerArr objectAtIndex:pageIndex];
            NSString *img_path =  [dic objectForKey:@"img_path"];
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",img_path]] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"banner_%li",pageIndex]]];
        }
        return imageView;
    };
    self.bannerView.totalPagesCount = ^NSInteger(void){
        
        return bannerArr.count > 0 ? bannerArr.count : 3;
    };
    self.bannerView.TapActionBlock = ^(NSInteger pageIndex){
        NSLog(@"点击了第%ld个",(long)pageIndex);
        if (weakSelf.TapActionBlock) {
            if (bannerArr.count > pageIndex) {
                NSDictionary *dic = [bannerArr objectAtIndex:pageIndex];
                NSString *img_path =  [dic objectForKey:@"fredirecturl"];
                weakSelf.TapActionBlock(img_path);
            }
        }
    };
}

@end
