//
//  SYDiscoverCommunityNewsTableViewCell.m
//  YLB
//
//  Created by YAYA on 2017/4/4.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYDiscoverCommunityNewsTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface SYDiscoverCommunityNewsTableViewCell()

@property (nonatomic, retain) UIImageView *iconImgView;
@property (nonatomic, retain) UILabel *titleLab;
@property (nonatomic, retain) UILabel *titleContent;

@end

@implementation SYDiscoverCommunityNewsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIColorFromRGB(0xebebeb);
        
        self.mainView = [[UIView alloc] initWithFrame:CGRectMake(14, 0, kScreenWidth - dockWidth - 50, SYDiscoverCommunityNewsTableViewCellHeight)];
        self.mainView.layer.borderColor = underLineColor.CGColor;
        self.mainView.layer.borderWidth = 0.5f;
        [self addSubview:self.mainView];

        self.iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 50)];
        self.iconImgView.contentMode = UIViewContentModeScaleToFill;
        [self.mainView addSubview:self.iconImgView];
        
        self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.iconImgView.frame) + 10, 10, screenWidth - dockWidth - 70, 30)];
        self.titleLab.font = [UIFont systemFontOfSize:16.0];
        self.titleLab.numberOfLines = 0;
        [self.mainView addSubview:self.titleLab];
        
        self.titleContent = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.iconImgView.frame) + 10, CGRectGetMaxY(self.titleLab.frame) + 5, screenWidth - dockWidth - 70, 30)];
        self.titleContent.font = [UIFont systemFontOfSize:14.0];
        self.titleContent.numberOfLines = 0;
        [self.mainView addSubview:self.titleContent];
    }
    return self;
}

- (void)layoutSubviews
{
    self.mainView.frame = CGRectMake(14, 0, screenWidth - dockWidth - 28, SYDiscoverCommunityNewsTableViewCellHeight);
    
    self.iconImgView.frame = CGRectMake(10, 10, 60, 50);
    
    self.titleLab.frame = CGRectMake(CGRectGetMaxX(self.iconImgView.frame) + 10, 10, self.mainView.frame.size.width - CGRectGetMaxX(self.iconImgView.frame) - 20, 30);
    
    self.titleContent.frame = CGRectMake(CGRectGetMaxX(self.iconImgView.frame) + 10, CGRectGetMaxY(self.titleLab.frame) + 5, screenWidth - dockWidth - CGRectGetMaxX(self.iconImgView.frame) - 50, 30);
}

#pragma mark - public
- (void)updateNews:(SYRecommendModel *)model{

    if (!model) {
        return;
    }
    
    self.titleLab.text = model.ftitle;
    
    [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",model.fpictureurl]] placeholderImage:[UIImage imageNamed:@"sy_home_placeholder@2x"]];
    
    self.titleContent.text = model.fcontent;
}

//更新头条
- (void)updateToutiao:(SYTodayNewsModel *)model{
    
    if (!model) {
        return;
    }
    self.titleLab.text = model.title;
    
    [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",model.picture_url]] placeholderImage:[UIImage imageNamed:@"sy_home_placeholder"]];
}

//更新资讯
- (void)updateAdvertInfo:(SYAdvertInfoListModel *)model{
    
    if (!model) {
        return;
    }
    self.titleLab.text = model.ftitle;
    self.titleContent.text = model.fcontent;
    
    if (model.pic_list.count > 0) {
        SYAdvertInfoModel *picModel = [model.pic_list objectAtIndex:0];
        [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",picModel.img_path]] placeholderImage:[UIImage imageNamed:@"sy_home_placeholder"]];
    }
}
@end
