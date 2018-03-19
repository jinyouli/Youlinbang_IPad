//
//  SYHomeGuardCollectionViewCell.h
//  YLB
//
//  Created by sayee on 17/3/31.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SYHomeGuardCollectionViewCellDelegate <NSObject>

- (void)guardAddToLocal:(NSIndexPath *)indexPath LockListModel:(SYLockListModel *)model;

@end

typedef enum : NSUInteger {
    backTag = 0,
    openLockTag,
    monitorTag,
    lockCancel
} BtnTag;

@interface SYHomeGuardCollectionViewCell : UICollectionViewCell

@property (nonatomic, retain) UILabel *guardNameLab;    //门禁名
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, retain) UIButton *lockDeleteBtn;
@property (nonatomic, retain) UIButton *lockChangeBtn;

@property (nonatomic, weak) id<SYHomeGuardCollectionViewCellDelegate> delegate;

#pragma mark - public
- (void)updateguardName:(SYLockListModel *)model;
@end
