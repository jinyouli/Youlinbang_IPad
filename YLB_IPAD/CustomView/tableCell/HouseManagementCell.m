//
//  HouseManagementCell.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/8/7.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "HouseManagementCell.h"

@interface HouseManagementCell()
@property (nonatomic, retain) UILabel *lblHomeName;
@property (nonatomic, retain) UILabel *lblPerson;
@property (nonatomic, retain) UILabel *lblStatus;
@property (nonatomic, retain) UISwitch *setDisturbSwitch;

@end

@implementation HouseManagementCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.lblHomeName = [[UILabel alloc] init];
    self.lblHomeName.font = [UIFont systemFontOfSize:14.0];
    [self addSubview:self.lblHomeName];
    
    self.lblPerson = [[UILabel alloc] init];
    self.lblPerson.font = [UIFont systemFontOfSize:14.0];
    [self addSubview:self.lblPerson];
    
    self.lblStatus = [[UILabel alloc] init];
    self.lblStatus.font = [UIFont systemFontOfSize:14.0];
    [self addSubview:self.lblStatus];
    
    self.setDisturbSwitch = [[UISwitch alloc] init];
    [self.setDisturbSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.setDisturbSwitch];
}

#pragma mark - event
- (void)switchChange:(UISwitch *)switchChange{
    
    if ([self.delegate respondsToSelector:@selector(switchChange:)]) {
        [self.delegate switchChange:switchChange.on];
    }
}

- (void)layoutSubviews
{
    self.lblHomeName.frame = CGRectMake(10, 0, 100, self.frame.size.height);
    self.lblPerson.frame = CGRectMake(self.frame.size.width - 60, 0, 100, self.frame.size.height);
    self.lblStatus.frame = CGRectMake(10, self.frame.size.height - CGRectGetMaxY(self.lblHomeName.frame), 100, 50);
    self.setDisturbSwitch.frame = CGRectMake(self.frame.size.width - 60, 30, 100, 50);
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
