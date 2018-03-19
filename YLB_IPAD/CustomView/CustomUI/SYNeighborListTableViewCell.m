//
//  SYNeighborListTableViewCell.m
//  YLB
//
//  Created by sayee on 17/4/5.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYNeighborListTableViewCell.h"
#import "SYNeiIPListModel.h"


@interface SYNeighborListTableViewCell ()

@property (nonatomic, retain) UIView *mainView;
@property (nonatomic, retain) UIImageView *iconImgView;
@property (nonatomic, retain) UILabel *neighborNameLab;
@property (nonatomic, retain) UILabel *bindLab;
@property (nonatomic,strong) UIView *lineView;
@end


@implementation SYNeighborListTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIColorFromRGB(0xebebeb);
        
        self.mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, SYNeighborListTableViewCellHeight)];
        self.mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.mainView];
        
        self.iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 18, 40, 40)];
        self.iconImgView.layer.cornerRadius = self.iconImgView.height * 0.5;
        self.iconImgView.layer.masksToBounds = YES;
        self.iconImgView.center = CGPointMake(self.iconImgView.centerX, self.mainView.centerY);
        [self.mainView addSubview:self.iconImgView];
        
        float fneighborNameLabLeft = self.iconImgView.right_sd + 18;
        self.neighborNameLab = [[UILabel alloc] initWithFrame:CGRectMake(fneighborNameLabLeft, self.iconImgView.top_sd, self.mainView.width_sd - fneighborNameLabLeft - 10, 20)];
        self.neighborNameLab.font = [UIFont systemFontOfSize:16];
        self.neighborNameLab.textColor = [UIColor blackColor];
        [self.mainView addSubview:self.neighborNameLab];

        self.bindLab = [[UILabel alloc] initWithFrame:CGRectMake(self.neighborNameLab.left_sd, self.neighborNameLab.bottom_sd, self.neighborNameLab.width_sd, self.neighborNameLab.height_sd)];
        self.bindLab.font = [UIFont systemFontOfSize:14];
        self.bindLab.textColor = UIColorFromRGB(0x999999);
        [self.mainView addSubview:self.bindLab];
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = UIColorFromRGB(0xebebeb);
        [self addSubview:self.lineView];
    }
    return self;
}


#pragma mark - public
- (void)updataInfo:(SYNeiIPListModel *)model{

    if (!model) {
        return;
    }
    self.iconImgView.image = [UIImage imageNamed:@"sy_navigation_normal_header"];
    self.bindLab.text = model.fcity;
    self.neighborNameLab.text = model.fneib_name;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.lineView.frame = CGRectMake(60, self.bounds.size.height, self.bounds.size.width - 60, 1);
}

@end
