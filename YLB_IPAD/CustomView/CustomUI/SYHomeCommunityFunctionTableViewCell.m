//
//  SYHomeCommunityFunctionTableViewCell.m
//  YLB
//
//  Created by sayee on 17/3/30.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYHomeCommunityFunctionTableViewCell.h"

@interface SYHomeCommunityFunctionTableViewCell()

@property (nonatomic, retain) UIImageView *iconImgView;
@property (nonatomic, retain) UILabel *nameLab;
@property (nonatomic, retain) UIView *mainView;
@property (nonatomic, retain) UIButton *functionBtn;    //在图片上覆盖一个btn，增加点击区域
@end

@implementation SYHomeCommunityFunctionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIColorFromRGB(0xebebeb);
        
        self.mainView = [[UIView alloc] initWithFrame:CGRectMake(14, 0, kScreenWidth - 28, SYHomeCommunityFunctionTableViewCellHeight)];
        self.mainView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.mainView];

        int nCount = 4; //总共有4个图片
        UIImage *img = [UIImage imageNamed:@"sy_home_smart_home"];
        float fMargin = (self.mainView.width_sd - img.size.width * nCount) / (nCount * 2); //点击区域宽度
        float fFunctionBtnWidth = 2 * fMargin + img.size.width;
        
        for (int i = 0; i < nCount; i++) {
            
            if (i == 0) {
                [self updateInfo:@"我的社区" LabTag:sy_home_my_communityLabTag BtnTag:sy_home_my_communityBtnTag Img:[UIImage imageNamed:@"sy_home_my_community"] Index:i FunctionBtnWidth:fFunctionBtnWidth];
                
            }else if (i == 1) {
                [self updateInfo:@"物业报修" LabTag:sy_home_repair_propertyLabTag BtnTag:sy_home_repair_propertyBtnTag Img:[UIImage imageNamed:@"sy_home_repair_property"] Index:i FunctionBtnWidth:fFunctionBtnWidth];
                
            }else if (i == 2) {
                [self updateInfo:@"物业投诉" LabTag:sy_home_property_complaintsLabTag BtnTag:sy_home_property_complaintsBtnTag Img:[UIImage imageNamed:@"sy_home_property_complaints"] Index:i FunctionBtnWidth:fFunctionBtnWidth];
            }
            else{
                [self updateInfo:@"物业缴费" LabTag:sy_home_smart_homeLabTag BtnTag:sy_home_smart_homeBtnTag Img:[UIImage imageNamed:@"sy_home_smart_home"] Index:i FunctionBtnWidth:fFunctionBtnWidth];
            }
        }
    }
    return self;
}


#pragma mark - event
- (void)functionBtnClick:(UIButton *)btn{

    if ([self.delegate respondsToSelector:@selector(functionBtnSelect:)]) {
        [self.delegate functionBtnSelect:btn.tag];
    }
}


#pragma mark - private
- (void)updateInfo:(NSString *)title LabTag:(functionTag)labTag BtnTag:(functionTag)btnTag Img:(UIImage *)img Index:(int)index FunctionBtnWidth:(float)fFunctionBtnWidth{
    
    self.functionBtn = nil;
    self.functionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.functionBtn addTarget:self action:@selector(functionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.functionBtn.tag = btnTag;
    self.functionBtn.frame = CGRectMake(index * fFunctionBtnWidth, 0, fFunctionBtnWidth, self.mainView.height_sd);
    [self.mainView addSubview:self.functionBtn];
    
    self.iconImgView = nil;
    self.iconImgView = [[UIImageView alloc] init];
    self.iconImgView.image = img;
    self.iconImgView.frame = CGRectMake(0, 20, img.size.width, img.size.height);
    self.iconImgView.center = CGPointMake(self.functionBtn.centerX, self.iconImgView.centerY);
    [self.mainView addSubview:self.iconImgView];
    
    self.nameLab = nil;
    self.nameLab = [[UILabel alloc] init];
    self.nameLab.textAlignment = NSTextAlignmentCenter;
    self.nameLab.font = [UIFont systemFontOfSize:14.0];
    self.nameLab.text = title;
    self.nameLab.textColor = UIColorFromRGB(0x999999);
    self.nameLab.tag = labTag;
    self.nameLab.frame = CGRectMake(0, self.iconImgView.bottom_sd + 10, self.functionBtn.width_sd, 20);
    self.nameLab.center = CGPointMake(self.iconImgView.centerX, self.nameLab.centerY);
    [self.mainView addSubview:self.nameLab];
}
@end
