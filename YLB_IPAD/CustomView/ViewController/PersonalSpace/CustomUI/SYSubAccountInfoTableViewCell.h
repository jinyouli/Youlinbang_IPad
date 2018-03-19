//
//  SYSubAccountInfoTableViewCell.h
//  YLB
//
//  Created by sayee on 17/3/29.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYSubAccountModel;

#define SYSubAccountInfoTableViewCellHeight 50

@protocol SYSubAccountInfoTableViewCellDelegate <NSObject>

- (void)switchChange:(BOOL)change;
- (void)nickNameChange:(NSString *)nickName;
@end

@interface SYSubAccountInfoTableViewCell : UITableViewCell

@property (nonatomic, weak) id<SYSubAccountInfoTableViewCellDelegate> delegate;
@property (nonatomic, assign) BOOL isDelAccount;

- (void)updateLeftInfo:(NSString *)leftInfo Type:(RightType)type SubAccountModel:(SYSubAccountModel *)model;
- (void)updateLeftInfo:(NSString *)leftInfo RightInfo:(NSString *)rightInfo;
@end
