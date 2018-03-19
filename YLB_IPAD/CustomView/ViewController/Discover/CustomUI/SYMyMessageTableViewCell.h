//
//  SYMyMessageTableViewCell.h
//  YLB
//
//  Created by sayee on 17/4/7.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNoticeByPagerModel.h"

#define SYMyMessageTableViewCellHeight 50

@interface SYMyMessageTableViewCell : UITableViewCell

- (void)updateMyMessageInfo:(SYNoticeByPagerModel *)model;

- (void)updateTenementMessageInfo:(SYNoticeByPagerModel *)model;//物业动态
@end
