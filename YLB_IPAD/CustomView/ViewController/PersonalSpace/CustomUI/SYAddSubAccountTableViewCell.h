//
//  SYAddSubAccountTableViewCell.h
//  YLB
//
//  Created by sayee on 17/3/29.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYContactsModel.h"

#define SYAddSubAccountTableViewCellHeight 50

@interface SYAddSubAccountTableViewCell : UITableViewCell

- (void)updateData:(SYContactsModel *)model;
@end
