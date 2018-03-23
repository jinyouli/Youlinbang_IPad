//
//  SYHomeCommandMessageCollectionViewCell.m
//  YLB
//
//  Created by sayee on 17/8/24.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYHomeCommandMessageCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@interface SYHomeCommandMessageCollectionViewCell()

@property (nonatomic, retain) UIImageView *iconImgView;
@property (nonatomic, retain) UILabel *titleLab;
@property (nonatomic, retain) UILabel *conmentLab;
@property (nonatomic, retain) UILabel *timeLab;
@property (nonatomic, retain) UIView *mainView;
@property (nonatomic, retain) UIView *line;
@property (nonatomic, retain) UIImageView *tagImgView;//标签
@property (nonatomic, retain) UILabel *tagLab;
@end

@implementation SYHomeCommandMessageCollectionViewCell


- (id)initWithFrame:(CGRect)frame{
    
    if (self=[super initWithFrame:frame]) {
        [self configSubViews];
        
    }
    return self;
}

#pragma mark - private
- (void)configSubViews{
    self.backgroundColor = UIColorFromRGB(0xebebeb);
    
    self.mainView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, kScreenWidth - dockWidth - 10, SYHomeCommandMessageCollectionViewCellHeight)];
    self.mainView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.mainView];
    
    self.iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, (SYHomeCommandMessageCollectionViewCellHeight - 24) * 1.6, SYHomeCommandMessageCollectionViewCellHeight - 24)];
    self.iconImgView.center = CGPointMake(self.iconImgView.centerX, self.mainView.height * 0.5f);
    [self.mainView addSubview:self.iconImgView];
    
    float fLabHeight = (SYHomeCommandMessageCollectionViewCellHeight - 24) / 3;
    
    self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(self.iconImgView.right_sd + 12, self.iconImgView.top_sd, kScreenWidth - self.iconImgView.right_sd - 24, fLabHeight)];
    self.titleLab.font = [UIFont systemFontOfSize:14.0];
    [self.mainView addSubview:self.titleLab];
    
    self.conmentLab = [[UILabel alloc] initWithFrame:CGRectMake(self.titleLab.left_sd, self.titleLab.bottom_sd, self.titleLab.width_sd, fLabHeight)];
    self.conmentLab.font = [UIFont systemFontOfSize:12.0];
    self.conmentLab.textColor = UIColorFromRGB(0x999999);
    [self.mainView addSubview:self.conmentLab];
    
    self.timeLab = [[UILabel alloc] initWithFrame:CGRectMake(self.titleLab.left_sd, self.conmentLab.bottom_sd, self.titleLab.width_sd, fLabHeight)];
    self.timeLab.font = [UIFont systemFontOfSize:12.0];
    self.timeLab.textColor = UIColorFromRGB(0x999999);
    [self.mainView addSubview:self.timeLab];
    
    self.line = [[UIView alloc]initWithFrame:CGRectMake(0, SYHomeCommandMessageCollectionViewCellHeight - 1, kScreenWidth, 1)];
    self.line.backgroundColor = UIColorFromRGB(0xd1d1d1);
    [self.mainView addSubview:self.line];
    
    UIFont *font = [UIFont systemFontOfSize:10];
    NSString *str = @"资讯";
    CGSize size = [str sizeWithFont:font andSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    UIImage *img = [UIImage imageNamed:@"sy_command_tag"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, img.size.width * 0.5 - 1, 0, img.size.width * 0.5) resizingMode:UIImageResizingModeStretch];
    self.tagImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.iconImgView.height_sd - size.height - 2, size.width + 10, size.height + 2)];
    self.tagImgView.image = img;
    self.tagImgView.hidden = YES;
    [self.iconImgView addSubview:self.tagImgView];

    self.tagLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    self.tagLab.font = font;
    self.tagLab.center = CGPointMake(self.tagImgView.width_sd * 0.5, self.tagImgView.height_sd * 0.5);
    self.tagLab.textAlignment = NSTextAlignmentCenter;
    self.tagLab.textColor = [UIColor whiteColor];
    [self.tagImgView addSubview:self.tagLab];
}


#pragma mark - public
- (void)updateRecommandInfo:(SYAdpublishModel *)model ShowTag:(BOOL)isShowTag{
    
    if (!model) {
        return;
    }
    
    self.titleLab.text = model.ftitle;
    self.timeLab.text = model.fcreatetime;
    self.conmentLab.text = model.fcontent;
    self.tagImgView.hidden = !isShowTag;
    if (model.type == 1) {
        self.tagLab.text = @"资讯";
    }else{
        self.tagLab.text = @"头条";
    }
    [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",model.fpictureurl]] placeholderImage:[UIImage imageNamed:@"sy_home_placeholder"]];
}

- (void)layoutSubviews
{
    self.mainView.frame = CGRectMake(5, 0, kScreenWidth - dockWidth - 20, SYHomeCommandMessageCollectionViewCellHeight);
    self.iconImgView.frame = CGRectMake(12, 12, (SYHomeCommandMessageCollectionViewCellHeight - 24) * 1.6, SYHomeCommandMessageCollectionViewCellHeight - 24);
    self.iconImgView.center = CGPointMake(self.iconImgView.centerX, self.mainView.height * 0.5f);
    
    float fLabHeight = (SYHomeCommandMessageCollectionViewCellHeight - 24) / 3;
    self.titleLab.frame = CGRectMake(self.iconImgView.right_sd + 12, self.iconImgView.top_sd, kScreenWidth - dockWidth - self.iconImgView.right_sd - 44, fLabHeight);
    self.conmentLab.frame = CGRectMake(self.titleLab.left_sd, self.titleLab.bottom_sd, self.titleLab.width_sd, fLabHeight);

    self.timeLab.frame = CGRectMake(self.titleLab.left_sd, self.conmentLab.bottom_sd, self.titleLab.width_sd, fLabHeight);
    self.line.frame = CGRectMake(0, SYHomeCommandMessageCollectionViewCellHeight - 1, kScreenWidth - dockWidth - 20, 1);

    UIFont *font = [UIFont systemFontOfSize:10];
    NSString *str = @"资讯";
    CGSize size = [str sizeWithFont:font andSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    self.tagImgView.frame = CGRectMake(0, self.iconImgView.height_sd - size.height - 2, size.width + 10, size.height + 2);
    self.tagLab.frame = CGRectMake(0, 0, size.width, size.height);
}

@end
