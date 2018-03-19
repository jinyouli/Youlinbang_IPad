//
//  SYNewRepairAddImgViewCollectionViewCell.h
//  YLB
//
//  Created by YAYA on 2017/4/6.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SYNewRepairAddImgViewCollectionViewCellHeight 70

@protocol SYNewRepairAddImgViewCollectionViewCellDelegate <NSObject>

- (void)delImgView:(NSIndexPath *)indexPath;

@end

@interface SYNewRepairAddImgViewCollectionViewCell : UICollectionViewCell

@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, weak) id<SYNewRepairAddImgViewCollectionViewCellDelegate> delegate;

#pragma mark - public
- (void)updateImg:(UIImage *)img;

@end
