//
//  SYPersonalSpaceTableViewCell.h
//  YLB
//
//  Created by YAYA on 2017/3/14.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYPersonalSpaceModel;

#define SYPersonalSpaceTableViewCellHeight 50

@interface SYPersonalSpaceTableViewCell : UITableViewCell

- (void)setLineHidden:(BOOL)hidden;
- (void)updateData:(SYPersonalSpaceModel *)model;
@end
