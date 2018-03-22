//
//  SYHomeGuardTableViewCell.h
//  YLB
//
//  Created by sayee on 17/3/30.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SYHomeGuardTableViewCellDelegate <NSObject>

- (void)guardClick:(NSIndexPath *)indexPath LockListModel:(SYLockListModel *)model; //点击门禁
- (void)addGuardClick:(NSIndexPath *)indexPath LockListModel:(SYLockListModel *)model;  //点击添加门禁按钮
- (void)addNewDoor:(NSInteger)selectIndex;
- (void)changeNewDoor:(UIButton *)btn;
- (void)deleteNewDoor:(UIButton *)btn;
@end

@interface SYHomeGuardTableViewCell : UITableViewCell

@property (nonatomic, weak) id<SYHomeGuardTableViewCellDelegate> delegate;
- (void)reloadGuardCollectionView;
@end
