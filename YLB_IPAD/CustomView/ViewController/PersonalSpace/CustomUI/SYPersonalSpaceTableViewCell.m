//
//  SYPersonalSpaceTableViewCell.m
//  YLB
//
//  Created by YAYA on 2017/3/14.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYPersonalSpaceTableViewCell.h"
#import "SYPersonalSpaceModel.h"

@interface SYPersonalSpaceTableViewCell()

@property (nonatomic, retain) UIImageView *iconImgView;
@property (nonatomic, retain) UILabel *nameLab;
@property (nonatomic, retain) UIView *mainView;
@property (nonatomic, retain) UIView *lineView;
@property (nonatomic, strong) UIImageView *arrowImgView;
@end

@implementation SYPersonalSpaceTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - dockWidth, self.frame.size.height)];
        self.mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.mainView];
        
        UIImage *img = [UIImage imageNamed:@"sy_me_about"];
        _iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, img.size.width, img.size.height)];
        self.iconImgView.center = CGPointMake(self.iconImgView.centerX, self.mainView.height * 0.5f);
        [self.mainView addSubview:self.iconImgView];
        
        UIImage *imgArrow = [UIImage imageNamed:@"sy_me_rightArrow"];
        _arrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth - dockWidth - 50, 0, 50, self.mainView.height)];
        self.arrowImgView.image = imgArrow;
        self.arrowImgView.contentMode = UIViewContentModeCenter;
        self.arrowImgView.center = CGPointMake(self.arrowImgView.centerX, self.mainView.height * 0.5f);
        [self.mainView addSubview:self.arrowImgView];
        
        float fNameLabLeft = self.iconImgView.right + 10;
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(self.iconImgView.right + 10, 0, self.mainView.width - fNameLabLeft, self.mainView.height)];
        self.nameLab.font = [UIFont systemFontOfSize:14.0];
        [self.mainView addSubview:self.nameLab];

        _lineView = [[UIView alloc] initWithFrame:CGRectMake(20, SYPersonalSpaceTableViewCellHeight , self.mainView.width, 1)];
        self.lineView.backgroundColor = UIColorFromRGB(0xebebeb);
        self.lineView.center = CGPointMake(self.mainView.width * 0.5, self.lineView.centerY);
        [self.mainView addSubview:self.lineView];
    }
    return self;
}

- (void)layoutSubviews
{
    _mainView.frame = CGRectMake(0, 0, kScreenWidth - dockWidth, self.frame.size.height);
    _lineView.frame = CGRectMake(20, SYPersonalSpaceTableViewCellHeight - 1, self.mainView.width - 20, 1);
    _arrowImgView.frame = CGRectMake(screenWidth - dockWidth - 50, 0, 50, self.mainView.height);
    self.arrowImgView.center = CGPointMake(self.arrowImgView.centerX, self.mainView.height * 0.5f);
}


#pragma mark public
- (void)setLineHidden:(BOOL)hidden{
    self.lineView.hidden = hidden;
}

- (void)updateData:(SYPersonalSpaceModel *)model{

    if (!model) {
        return;
    }
    self.iconImgView.image = model.iconImg;
    self.nameLab.text = model.nameStr;
}
@end
