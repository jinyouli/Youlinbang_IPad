//
//  SYHouseManageTableViewCell.m
//  YLB
//
//  Created by sayee on 17/3/28.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYHouseManageTableViewCell.h"

@interface SYHouseManageTableViewCell ()
/** 存放下面所有的子view */
@property (strong, nonatomic) UIView *mainView;
/** 房产名字 */
@property (strong, nonatomic) UILabel *housePropertyNameLabel;
/** 业主或者子账号 */
@property (strong, nonatomic) UILabel *proprietorLabel;
/** 勾选免打扰按钮，用于扩大点击区域 */
@property (strong, nonatomic) UIButton *unDisturbButton;
/** 勾选免打图片 */
@property (strong, nonatomic) UIImageView *unDisturbImgView;
/** 免打扰图片 (铃铃的那个图片)*/
@property (strong, nonatomic) UIImageView *unDisturbImageView;
/** 业主和免打扰勾选图片区域，用于整体左移 */
@property (strong, nonatomic) UIView *proprietorView;

@property (assign, nonatomic) float fProprietorViewLeft;
@property (nonatomic, strong) UISwitch *rightSwitch;
@property (nonatomic, strong) UILabel *lblStatus;

@property (nonatomic, strong) SipInfoModel *model;
@end


@implementation SYHouseManageTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIColorFromRGB(0xebebeb);
        
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cellWidth, SYHouseManageTableViewCellHeight - 8)];
        [self.mainView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.mainView];
        
        UIImage *img = [UIImage imageNamed:@"sy_me_propertyClick"]; //勾勾图片
        UIImage *unDisturbImg = [UIImage imageNamed:@"sy_me_undisturb"];//(铃铃的那个图片)

        // 免打扰按钮
        UIFont *font = [UIFont systemFontOfSize:12];
        CGSize size = [@"子账号" sizeWithFont:font andSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        float fProprietorViewWidth = size.width + self.mainView.height_sd;
        
        self.proprietorView = [[UIView alloc] initWithFrame:CGRectMake(self.mainView.width_sd - fProprietorViewWidth + self.mainView.height_sd, 0, fProprietorViewWidth, self.mainView.height_sd)];
        self.fProprietorViewLeft = self.proprietorView.left;
        [self.mainView addSubview:self.proprietorView];
        
        // 业主还是非业主
        _proprietorLabel = [[UILabel alloc] initWithFrame:CGRectMake(-10, 0, size.width, 50)];
        [self.proprietorLabel setTextColor:UIColorFromRGB(0x999999)];
        self.proprietorLabel.textAlignment = NSTextAlignmentRight;
        [self.proprietorLabel setFont:font];
        [self.proprietorView addSubview:self.proprietorLabel];
        
        UIView *underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_proprietorLabel.frame) - 5, screenWidth * 0.7, 1)];
        underLineView.backgroundColor = underLineColor;
        [self.mainView addSubview:underLineView];
        
        // 业主还是非业主和免打扰按钮区域  勾勾图片
        _unDisturbImgView = [[UIImageView alloc] initWithImage:img];
        self.unDisturbImgView.alpha = 0;
        self.unDisturbImgView.frame = CGRectMake(0, 0, img.size.width, img.size.height);
        [self.proprietorView addSubview:self.unDisturbImgView];
        
        _unDisturbButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.unDisturbButton.frame = CGRectMake(self.proprietorView.width_sd - self.proprietorView.height_sd, 0, self.proprietorView.height_sd, self.proprietorView.height_sd);
        [self.unDisturbButton addTarget:self action:@selector(unDisturbButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.proprietorView addSubview:self.unDisturbButton];
        
        self.unDisturbImgView.center = self.unDisturbButton.center;
        
        // 免打扰的图片 (铃铃的那个图片)
        _unDisturbImageView = [[UIImageView alloc] initWithImage:unDisturbImg];
        self.unDisturbImageView.frame = CGRectMake(self.mainView.width_sd - fProprietorViewWidth - unDisturbImg.size.width - 5, 0, unDisturbImg.size.width, unDisturbImg.size.height);
        self.unDisturbImageView.hidden = YES;
        self.unDisturbImageView.center = CGPointMake(self.unDisturbImageView.centerX, self.proprietorView.centerY);
        [self.mainView addSubview:self.unDisturbImageView];
        
        // 房产名字
        _housePropertyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width - 100, self.size.height)];
        _housePropertyNameLabel.numberOfLines = 0;
        [self.housePropertyNameLabel setTextColor:UIColorFromRGB(0x555555)];
        _housePropertyNameLabel.backgroundColor = [UIColor clearColor];
        [self.housePropertyNameLabel setFont:[UIFont systemFontOfSize:13]];
        [self.mainView addSubview:self.housePropertyNameLabel];
        
        //下面是iPad上新增的
        _rightSwitch = [[UISwitch alloc] init];
        self.rightSwitch.frame = CGRectMake(self.mainView.width - self.rightSwitch.width - 10, 50, 100, 50);
        [self.rightSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
        [self.mainView addSubview:self.rightSwitch];
        
        self.lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 100, 50)];
        self.lblStatus.text = @"免打扰";
        [self.lblStatus setTextColor:UIColorFromRGB(0x555555)];
        self.lblStatus.backgroundColor = [UIColor clearColor];
        [self.lblStatus setFont:[UIFont systemFontOfSize:13]];
        [self.mainView addSubview:self.lblStatus];
    }
    return self;
}

- (void)switchChange:(UISwitch *)switchChange{
    if ([self.delegate respondsToSelector:@selector(houseManageTableViewCellSelectUnDisturbViewWithIndexPath: isdisturb:)]) {
        [self.delegate houseManageTableViewCellSelectUnDisturbViewWithIndexPath:self.indexPath isdisturb:(BOOL)switchChange.isOn];
    }
}

#pragma mark - piublic
- (void)showUnDisturb:(BOOL)isShow{
    WEAK_SELF;
    if (isShow) {
        if (self.unDisturbImgView.alpha == 1) {
            return;
        }
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.proprietorView.frame = (CGRect){{weakSelf.proprietorView.left_sd - weakSelf.mainView.height_sd, weakSelf.proprietorView.top_sd}, weakSelf.proprietorView.size_sd};
            weakSelf.unDisturbImgView.alpha = 1;
        }];
    }
    else{
        if (self.unDisturbImgView.alpha == 0) {
            return;
        }
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.proprietorView.frame = (CGRect){{weakSelf.fProprietorViewLeft, weakSelf.proprietorView.top_sd}, weakSelf.proprietorView.size_sd};
            weakSelf.unDisturbImgView.alpha = 0;
        }];
    }
}

- (void)setInfoModel:(SipInfoModel *)model{
    if (!model) {
        return;
    }
    
    self.model = model;
    model.house_address = [model.house_address stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    
    self.housePropertyNameLabel.text = model.house_address;
    self.proprietorLabel.text = model.is_owner ? @"业主" : @"子账号";
    self.rightSwitch.on = model.disturbing;
    //self.unDisturbImageView.hidden = !model.disturbing;
    self.unDisturbImgView.image = model.disturbing ? [UIImage imageNamed:@"sy_me_propertyClick"] : [UIImage imageNamed:@"sy_me_propertyUnclick"];
}


#pragma mark - Event Response
//免打扰按钮选择
- (void)unDisturbButtonAction:(UIButton *)button {

    
}

@end
