//
//  SYHomeAllGuardsTableViewCell.m
//  YLB
//
//  Created by sayee on 17/4/1.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYHomeAllGuardsTableViewCell.h"

@interface SYHomeAllGuardsTableViewCell ()

/** 存放下面所有的子view */
@property (strong, nonatomic) UIView *mainView;
/** title */
@property (strong, nonatomic) UILabel *titleLabel;
/** 添加按钮 */
@property (strong, nonatomic) UIButton *addBtn;
@end

@implementation SYHomeAllGuardsTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIColorFromRGB(0xebebeb);
        
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, kScreenWidth, SYHomeAllGuardsTableViewCellHeight - 8)];
        [self.mainView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.mainView];
        
        UIImage *img = [UIImage imageNamed:@"sy_me_propertyUnclick"];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
        [self.mainView addSubview:imgView];
        
        self.addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.addBtn setBackgroundImage:[UIImage imageNamed:@"sy_home_guard_add"] forState:UIControlStateNormal];
        self.addBtn.frame = CGRectMake(10, 0, self.mainView.height - 10, self.mainView.height - 10);
        self.addBtn.center = CGPointMake(self.addBtn.centerX, self.mainView.height * 0.5);
        [self.addBtn addTarget:self action:@selector(addGuardClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.addBtn];
        
        imgView.center = self.addBtn.center;
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.addBtn.right_sd + 10, 0, self.mainView.width_sd - self.addBtn.right_sd - 20, self.mainView.height)];
        [self.titleLabel setTextColor:UIColorFromRGB(0x999999)];
        [self.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [self.mainView addSubview:self.titleLabel];
    }
    return self;
}


#pragma mark - event
- (void)addGuardClick:(UIButton *)btn{

    if ([self.delegate respondsToSelector:@selector(guardSelect:)]) {
        [self.delegate guardSelect:self.indexPath];
    }
}


#pragma mark - public
- (void)updateGuardTitle:(NSString *)title{
    self.titleLabel.text = title;
}
@end
