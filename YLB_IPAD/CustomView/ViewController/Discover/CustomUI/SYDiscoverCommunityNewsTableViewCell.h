//
//  SYDiscoverCommunityNewsTableViewCell.h
//  YLB
//
//  Created by YAYA on 2017/4/4.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SYDiscoverCommunityNewsTableViewCellHeight 75

@interface SYDiscoverCommunityNewsTableViewCell : UITableViewCell

@property (nonatomic, retain) UIView *mainView;

- (void)updateNews:(SYRecommendModel *)model;
//更新头条
- (void)updateToutiao:(SYTodayNewsModel *)model;
//更新资讯
- (void)updateAdvertInfo:(SYAdvertInfoListModel *)model;
@end
