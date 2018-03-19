//
//  SYSetMyConfigInfoTableViewCell.h
//  YLB
//
//  Created by YAYA on 2017/4/8.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SYSetMyConfigInfoTableViewCellHeight 50

@protocol SYSetMyConfigInfoTableViewCellDelegate <NSObject>

- (void)headerClick:(NSIndexPath *)indexPath;
- (void)txtFieldMotto:(NSString *)motto Alias:(NSString *)alias;
@end


@interface SYSetMyConfigInfoTableViewCell : UITableViewCell

@property (nonatomic, weak) id<SYSetMyConfigInfoTableViewCellDelegate> delegate;
@property (nonatomic, retain) NSIndexPath *indexPath;

- (void)updateLeftTitle:(NSString *)title Alias:(BOOL)isShowalias Motto:(BOOL)isShowMotto HeaderImg:(UIImage *)headerImg HeaderHidden:(BOOL)isShowHeader;
@end
