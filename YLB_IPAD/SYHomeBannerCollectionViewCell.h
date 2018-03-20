//
//  SYHomeBannerCollectionViewCell.h
//  YLB
//
//  Created by sayee on 17/8/25.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>
#define SYHomeBannerCollectionViewCellHeight (kScreenWidth * 0.4)
@interface SYHomeBannerCollectionViewCell : UICollectionViewCell


@property (nonatomic , copy) void (^TapActionBlock)(NSString *fredirecturl);

-(void)updateBannerInfo:(NSArray *)model;
@end
