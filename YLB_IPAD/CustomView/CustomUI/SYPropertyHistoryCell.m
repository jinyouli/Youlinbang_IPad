//
//  SYPropertyHistoryCell.m
//  YLB
//
//  Created by jinyou on 2017/6/20.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYPropertyHistoryCell.h"

@implementation SYPropertyHistoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //self.backgroundColor = UIColorFromRGB(0xebebeb);
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 50)];
    label.text = @"7-9月账单";
    [self addSubview:label];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
