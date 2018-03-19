//
//  SYSubAccountTableViewCell.h
//  YLB
//
//  Created by sayee on 17/3/29.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYSubAccountModel;
#define SYSubAccountTableViewCellHeight 50

@interface SYSubAccountTableViewCell : UITableViewCell

- (void)updateInfo:(SYSubAccountModel *)model;
- (void)updatePhoneNumber:(NSString *)phoneNumber;

@end
