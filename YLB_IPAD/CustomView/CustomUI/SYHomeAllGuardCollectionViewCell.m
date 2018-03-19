//
//  SYHomeAllGuardCollectionViewCell.m
//  YLB
//
//  Created by sayee on 17/3/31.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYHomeAllGuardCollectionViewCell.h"


@interface SYHomeAllGuardCollectionViewCell ()

@property (nonatomic, retain) UIImageView *iconImgView;
@property (nonatomic, retain) UILabel *allGuardLab;

@end


@implementation SYHomeAllGuardCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        [self configUI];
    }
    return self;
}

#pragma mark - private
- (void)configUI{

    self.allGuardLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - dockWidth, SYHomeAllGuardCollectionViewCellHeight)];
    self.allGuardLab.textAlignment = NSTextAlignmentCenter;
    self.allGuardLab.font = [UIFont systemFontOfSize:14.0];
    self.allGuardLab.text = @"全部门禁";
    self.allGuardLab.textColor = UIColorFromRGB(0x999999);
    [self.contentView addSubview:self.allGuardLab];
    
    UIImage *img = [UIImage imageNamed:@"sy_home_all_houses"];
    self.iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, img.size.width, img.size.height)];
    self.iconImgView.image = img;
    self.iconImgView.center = CGPointMake(self.iconImgView.centerX, SYHomeAllGuardCollectionViewCellHeight * 0.5);
    [self.contentView addSubview:self.iconImgView];
    
}

@end
