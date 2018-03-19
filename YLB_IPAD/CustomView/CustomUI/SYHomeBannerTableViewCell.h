//
//  SYHomeBannerTableViewCell.h
//  YLB
//
//  Created by sayee on 17/3/30.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLB_IPAD-Swift.h"

#define SYHomeBannerTableViewCellHeight 200

@interface SYHomeBannerTableViewCell : UITableViewCell

@property (nonatomic,strong) FSPagerView *bannerView;
@property (nonatomic,strong) UIPageControl *pageControl;

-(void)updateBannerInfo:(NSArray *)banners;
- (void)setDataArray:(NSMutableArray *)dataArray;
@end
