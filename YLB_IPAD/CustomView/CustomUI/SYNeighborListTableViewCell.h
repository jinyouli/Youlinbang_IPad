//
//  SYNeighborListTableViewCell.h
//  YLB
//
//  Created by sayee on 17/4/5.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYNeiIPListModel;

#define SYNeighborListTableViewCellHeight 50

@interface SYNeighborListTableViewCell : UITableViewCell

- (void)updataInfo:(SYNeiIPListModel *)model;
@end
