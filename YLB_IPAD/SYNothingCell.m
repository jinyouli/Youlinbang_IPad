//
//  SYNothingCell.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/11/1.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "SYNothingCell.h"

@interface SYNothingCell()

@property (nonatomic, retain) UIImageView *iconImgView;
@property (nonatomic, retain) UILabel *titleLab;

@end

@implementation SYNothingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIColorFromRGB(0xebebeb);
        
        self.iconImgView = [[UIImageView alloc] init];
        self.iconImgView.image = [UIImage imageNamed:@"icon_empty"];
        self.iconImgView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.iconImgView];
        
        self.titleLab = [[UILabel alloc] init];
        self.titleLab.text = @"暂无更多数据";
        self.titleLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLab];
    }
    return self;
}

- (void)layoutSubviews
{
    self.iconImgView.frame = CGRectMake(self.bounds.size.width * 0.5 - 50, self.bounds.size.height * 0.5 - 50, 100, 100);
    self.titleLab.frame = CGRectMake(0, CGRectGetMaxY(self.iconImgView.frame) + 10, self.bounds.size.width, 50);
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
