//
//  SYDiscoverAppCommandTableViewCell.h
//  YLB
//
//  Created by YAYA on 2017/4/4.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYAppManageListModel.h"
#define SYDiscoverAppCommandTableViewCellHeight 50

@protocol SYDiscoverAppCommandTableViewCellDelegate <NSObject>

- (void)openAPP:(NSIndexPath *)indexPath Model:(SYAppManageListModel *)model;

@end

@interface SYDiscoverAppCommandTableViewCell : UITableViewCell

@property (nonatomic, weak) id<SYDiscoverAppCommandTableViewCellDelegate> delegte;
@property (nonatomic, retain) NSIndexPath *indexPath;

- (void)updataInfo:(SYAppManageListModel *)model;
@end
