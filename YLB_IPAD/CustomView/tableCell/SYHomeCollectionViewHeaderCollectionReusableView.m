//
//  SYHomeCollectionViewHeaderCollectionReusableView.m
//  YLB
//
//  Created by sayee on 17/8/25.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYHomeCollectionViewHeaderCollectionReusableView.h"

@interface SYHomeCollectionViewHeaderCollectionReusableView ()
@property(nonatomic, strong) UIButton *button;
@property(nonatomic, strong) UIView *bgView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *moreLabel;
@property(nonatomic, strong) UIImageView *iconImageView;
@end

@implementation SYHomeCollectionViewHeaderCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0xebebeb);
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, (kScreenWidth - dockWidth) * 0.5 - 10, SYHomeCollectionViewHeaderCollectionReusableViewHeight)];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textColor = UIColorFromRGB(0x555555);
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.titleLabel];
        
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - dockWidth) - 20, 0, 8, 13)];
        self.iconImageView.image = [UIImage imageNamed:@"sy_me_rightArrow"];
        self.iconImageView.center = CGPointMake(self.iconImageView.centerX, SYHomeCollectionViewHeaderCollectionReusableViewHeight * 0.5);
        [self addSubview:self.iconImageView];

        self.moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.iconImageView.left_sd - ((kScreenWidth - dockWidth) * 0.3), 0, (kScreenWidth - dockWidth) * 0.3, SYHomeCollectionViewHeaderCollectionReusableViewHeight)];
        self.moreLabel.font = [UIFont systemFontOfSize:12];
        self.moreLabel.textColor = UIColorFromRGB(0x555555);
        self.moreLabel.textAlignment = NSTextAlignmentRight;
        self.moreLabel.text = @"更多";
        [self addSubview:self.moreLabel];

        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.backgroundColor = [UIColor clearColor];
        self.button.frame = CGRectMake((kScreenWidth - dockWidth) * 0.7, 0, (kScreenWidth - dockWidth) * 0.3, SYHomeCollectionViewHeaderCollectionReusableViewHeight);
        [self.button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
        
    }
    return self;
}


#pragma mark - event
- (void)buttonClick:(UIButton *)sender {
    if (self.clickCallBack) {
        self.clickCallBack();
    }
}


#pragma mark - public
- (void)updateTitle:(NSString *)title moreLabel:(NSString *)moreLabel{
    self.titleLabel.text = title;
    self.moreLabel.text = moreLabel;
}

@end
