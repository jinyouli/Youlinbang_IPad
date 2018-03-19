//
//  SYDiscoverAppCommandTableViewCell.m
//  YLB
//
//  Created by YAYA on 2017/4/4.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYDiscoverAppCommandTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface SYDiscoverAppCommandTableViewCell()

@property (nonatomic, retain) UIImageView *iconImgView;
@property (nonatomic, retain) UILabel *titleLab;
@property (nonatomic, retain) UILabel *versionLab;
@property (nonatomic, retain) UILabel *detailLab;
@property (nonatomic, retain) UIView *mainView;
@property (nonatomic, retain) UIButton *openBtn;

@property (nonatomic, retain) SYAppManageListModel *model;
@end

@implementation SYDiscoverAppCommandTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIColorFromRGB(0xebebeb);
        
        self.mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellWidth, SYDiscoverAppCommandTableViewCellHeight)];
        self.mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.mainView];
        
        self.iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, self.mainView.height_sd - 10, self.mainView.height_sd - 10)];
        self.iconImgView.center = CGPointMake(self.iconImgView.centerX, self.mainView.height * 0.5f);self.iconImgView.backgroundColor = [UIColor redColor];
        [self.mainView addSubview:self.iconImgView];
        
        self.openBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        [self.openBtn setTitle:@"下载" forState:UIControlStateNormal];
        self.openBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.openBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        self.openBtn.frame = CGRectMake(self.mainView.width_sd - 70, 0, 60, 30);
        [self.openBtn setTitleColor:UIColorFromRGB(0xf23023) forState:UIControlStateNormal];
        self.openBtn.center = CGPointMake(self.openBtn.centerX, self.mainView.height_sd * 0.5);
        self.openBtn.layer.borderWidth = 1;
        self.openBtn.layer.borderColor = UIColorFromRGB(0xf23023).CGColor;
        [self.mainView addSubview:self.openBtn];
        
        float fNameLabLeft = self.iconImgView.right + 10;
        self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(fNameLabLeft, self.iconImgView.top_sd + 5, self.openBtn.left_sd - fNameLabLeft - 10, 16)];
        self.titleLab.font = [UIFont systemFontOfSize:14.0];
        [self.mainView addSubview:self.titleLab];
        
        self.versionLab = [[UILabel alloc] initWithFrame:CGRectMake(fNameLabLeft, self.titleLab.bottom_sd, self.titleLab.width , 0)];
        self.versionLab.textColor = UIColorFromRGB(0x999999);
        self.versionLab.font = [UIFont systemFontOfSize:10.0];
        [self.mainView addSubview:self.versionLab];
        
        self.detailLab = [[UILabel alloc] initWithFrame:CGRectMake(fNameLabLeft, self.versionLab.bottom_sd, self.titleLab.width , 13)];
        self.detailLab.textColor = UIColorFromRGB(0x999999);
        self.detailLab.font = [UIFont systemFontOfSize:10.0];
        [self.mainView addSubview:self.detailLab];
    }
    return self;
}


#pragma mark - event
- (void)btnClick:(UIButton *)btn{

    if ([self.delegte respondsToSelector:@selector(openAPP:Model:)]) {
        [self.delegte openAPP:self.indexPath Model:self.model];
    }
}


#pragma mark - public
- (void)updataInfo:(SYAppManageListModel *)model{
  
    if (!model) {
        return;
    }
    self.model = model;
    [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",model.ficon_url]] placeholderImage:[UIImage imageNamed:@"sy_home_placeholder"]];
    self.titleLab.text = model.fapp_name;
//    self.versionLab.text = [NSString stringWithFormat:@"版本号: %@  %.2fM",model.fversionname ? model.fversionname : @"", model.fappsize / 1000.0];
    self.detailLab.text = model.fversiondes;
}

@end
