//
//  SYHouseManageTableViewCell.h
//  YLB
//
//  Created by sayee on 17/3/28.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SYHouseManageTableViewCellHeight 100

@protocol SYHouseManageTableViewCellDelegate <NSObject>

- (void)houseManageTableViewCellSelectUnDisturbViewWithIndexPath:(NSIndexPath *)indexPath isdisturb:(BOOL)isdisturb;

@end

@interface SYHouseManageTableViewCell : UITableViewCell

@property (nonatomic, weak) id<SYHouseManageTableViewCellDelegate> delegate;
@property (nonatomic, retain) NSIndexPath *indexPath;

//显示勿打扰的view
- (void)showUnDisturb:(BOOL)isShow;
- (void)setInfoModel:(SipInfoModel *)model;
@end
