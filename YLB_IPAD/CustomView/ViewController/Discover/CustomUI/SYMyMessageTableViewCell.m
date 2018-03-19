//
//  SYMyMessageTableViewCell.m
//  YLB
//
//  Created by sayee on 17/4/7.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYMyMessageTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "SYRoundHeadView.h"
@interface SYMyMessageTableViewCell()

@property (nonatomic, retain) UIView *mainView;
@property (nonatomic, retain) UIView *lineView;

@property (nonatomic, retain) UIImageView *headerImgView;
@property (nonatomic, retain) UIImageView *headerNoticeView;    //红点
@property (nonatomic, retain) UILabel *titleLab;
@property (nonatomic, retain) UILabel *contentLab;
@property (nonatomic, retain) UILabel *timeLab;
@property (nonatomic, retain) SYRoundHeadView *tenementMessageHeaderImgView;
@end

@implementation SYMyMessageTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, SYMyMessageTableViewCellHeight)];
        self.mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.mainView];

        UIImage *img = [UIImage imageNamed:@"sy_iconImage"];
        self.headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, SYMyMessageTableViewCellHeight - 20, SYMyMessageTableViewCellHeight - 20)];
        self.headerImgView.image = img;
        self.headerImgView.layer.cornerRadius = self.headerImgView.height_sd * 0.5;
        self.headerImgView.layer.masksToBounds = YES;
        self.headerImgView.center = CGPointMake(self.headerImgView.centerX, self.mainView.height * 0.5f);
        [self.mainView addSubview:self.headerImgView];
        
        self.tenementMessageHeaderImgView = [[SYRoundHeadView alloc] initWithFrame:self.headerImgView.frame];
        self.tenementMessageHeaderImgView.hidden = YES;
        [self.mainView addSubview:self.tenementMessageHeaderImgView];
        
        self.headerNoticeView = [[UIImageView alloc] initWithFrame:CGRectMake(self.headerImgView.right_sd - 10, self.headerImgView.top_sd, 10, 10)];
        self.headerNoticeView.image = [UIImage imageNamed:@"sy_red_point"];
        self.headerNoticeView.hidden = YES;
        [self.mainView addSubview:self.headerNoticeView];
        
        self.timeLab = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth * 0.7 - 90, self.headerImgView.top_sd, 80, 18)];
        self.timeLab.font = [UIFont systemFontOfSize:12.0];
        self.timeLab.textAlignment = NSTextAlignmentRight;
        self.timeLab.textColor = UIColorFromRGB(0x999999);
        [self.mainView addSubview:self.timeLab];
        
        float fTitleLabLeft = self.headerImgView.right_sd + 10;
        self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(fTitleLabLeft, self.headerImgView.top_sd, self.timeLab.left_sd - fTitleLabLeft, 20)];
        self.titleLab.font = [UIFont systemFontOfSize:16.0];
        [self.mainView addSubview:self.titleLab];
        
        self.contentLab = [[UILabel alloc] initWithFrame:CGRectMake(self.titleLab.left_sd, self.titleLab.bottom_sd, self.mainView.width - self.titleLab.left_sd - 10, 18)];
        self.contentLab.font = [UIFont systemFontOfSize:14.0];
        self.contentLab.textColor = UIColorFromRGB(0x999999);
        [self.mainView addSubview:self.contentLab];
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(20, self.frame.size.height + 1, screenWidth - dockWidth - 20, 1)];
        self.lineView.backgroundColor = underLineColor;
        [self.mainView addSubview:self.lineView];
    }
    return self;
}

- (void)layoutSubviews
{
    self.mainView.frame = CGRectMake(0, 0, screenWidth * 0.7, SYMyMessageTableViewCellHeight);

    
    self.timeLab.frame = CGRectMake(self.mainView.frame.size.width - 90, self.headerImgView.top_sd, 80, 18);
    
    float fTitleLabLeft = self.headerImgView.right_sd + 10;
    self.titleLab.frame = CGRectMake(fTitleLabLeft, self.headerImgView.top_sd, self.timeLab.left_sd - fTitleLabLeft, 20);
    
    self.contentLab.frame = CGRectMake(self.titleLab.left_sd, self.titleLab.bottom_sd, screenWidth * 0.7 - self.titleLab.left_sd - 10, 18);
    _lineView.frame = CGRectMake(20, SYMyMessageTableViewCellHeight + 1, screenWidth * 0.7 - 20, 1);
}

#pragma mark - public
- (void)updateMyMessageInfo:(SYNoticeByPagerModel *)model{
    
    if (!model) {
        return;
    }
    self.headerImgView.hidden = NO;
    self.tenementMessageHeaderImgView.hidden = YES;
    self.titleLab.text = model.title;
    self.contentLab.text = model.content;
    self.timeLab.text = [model.time substringToIndex:10];
}

- (void)updateTenementMessageInfo:(SYNoticeByPagerModel *)model{
    
    if (!model) {
        return;
    }
    self.headerImgView.hidden = YES;
    self.tenementMessageHeaderImgView.hidden = NO;
    
    [self.tenementMessageHeaderImgView setTitle:model.fname withshowWordLength:2];
    self.titleLab.text = model.fname;
    self.contentLab.text = model.fcontent;
    self.timeLab.text = model.fcreatetime;
}
@end
