//
//  DoorListTableViewCell.h
//  YLB_IPAD
//
//  Created by jinyou on 2017/8/5.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoorListTableViewCell : UITableViewCell

@property (nonatomic,strong) UIButton *btnMoreFunction;
@property (nonatomic,strong) UIButton *btnCallManager;

#pragma mark - public
- (void)updateFrames:(SYLockListModel *)model;
- (void)showCancel;

@end
