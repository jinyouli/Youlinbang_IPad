//
//  SYNewRepairAddImgViewCollectionViewCell.m
//  YLB
//
//  Created by YAYA on 2017/4/6.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYNewRepairAddImgViewCollectionViewCell.h"
#import "SYHistoryCommentTableViewCell.h"

@interface SYNewRepairAddImgViewCollectionViewCell ()

@property (nonatomic, retain) UIImageView *iconImgView; 
@property (nonatomic, retain) UIButton *delImgBtn;
@end

@implementation SYNewRepairAddImgViewCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        [self configUI];
    }
    return self;
}

#pragma mark - private
- (void)configUI{

    self.iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 60, 60)];
    [self.contentView addSubview:self.iconImgView];

    self.delImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.delImgBtn setImage:[UIImage imageNamed:@"sy_new_repair_img_close"] forState:UIControlStateNormal];
    self.delImgBtn.frame = CGRectMake(self.width_sd - 20, 0, 20, 20);
    [self.delImgBtn addTarget:self action:@selector(delBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.delImgBtn];
}


#pragma mark - event
- (void)delBtnClick:(UIButton *)btn{
    
    if ([self.delegate respondsToSelector:@selector(delImgView:)]) {
        [self.delegate delImgView:self.indexPath];
    }
}


#pragma mark - public
- (void)updateImg:(UIImage *)img{
    if (img) {
        self.iconImgView.image = img;
        self.delImgBtn.hidden = NO;
    }else{
        self.iconImgView.image = [UIImage imageNamed:@"sy_new_repair_img_add"];
        self.delImgBtn.hidden = YES;
    }
}
@end
