//
//  SYHelpTableViewCell.h
//  YLB
//
//  Created by YAYA on 2017/3/19.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYHelpTableViewCell : UITableViewCell

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *contentLabel;

- (void)updateTitle:(NSString *)title Content:(NSString *)content ContentHeight:(CGSize)size;
@end
