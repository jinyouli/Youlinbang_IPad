//
//  SYPropertyRepairTableViewCell.m
//  YLB
//
//  Created by YAYA on 2017/4/2.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYPropertyRepairTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "SYPhotoContainerView.h"

@interface SYPropertyRepairTableViewCell ()

@property (nonatomic, retain) UIView *mainView;
@property (nonatomic, retain) UIImageView *headerImgView;
@property (nonatomic, retain) UILabel *myNameLab;
@property (nonatomic, retain) UILabel *addressLab;
@property (nonatomic, retain) UILabel *contentLab;
@property (strong, nonatomic) SYPhotoContainerView *repairsImgBGView;   //工单区域图片
@property (nonatomic, retain) UILabel *timeLab;
@property (nonatomic, retain) UILabel *orderNumLab;

@property (nonatomic, assign) float repairsImgHeight;   //工单图片高度
@property (nonatomic, retain) NSMutableArray *repairsBtnMArr;

//==========评论===========
@property (nonatomic, retain) UIView *commentBGView;    //评论区域
@property (nonatomic, retain) UIButton *historyCommentBtn;  //历史评论

//评论区域
@property (strong, nonatomic) UIView *commnetOneView;
@property (strong, nonatomic) UIView *commnetTwoView;
@property (strong, nonatomic) UIView *commnetThreeView;

//评论区域图片
@property (strong, nonatomic) SYPhotoContainerView *commnetOneImgBGView;
@property (strong, nonatomic) SYPhotoContainerView *commnetTwoImgBGView;
@property (strong, nonatomic) SYPhotoContainerView *commnetThreeImgBGView;

//评论区域内容
@property (nonatomic, retain) UILabel *commnetoneLab;
@property (nonatomic, retain) UILabel *commnetTwoLab;
@property (nonatomic, retain) UILabel *commnetThreeLab;

//存放底部按钮
@property (nonatomic, retain) UIView *bottomRepairsBtnView;

@property (nonatomic, assign) BOOL isExtensioned;
@end

@implementation SYPropertyRepairTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.repairsBtnMArr = [[NSMutableArray alloc] init];
        
        self.backgroundColor = UIColorFromRGB(0xebebeb);
        
        self.mainView = [[UIView alloc] initWithFrame:CGRectMake(10, 8, kScreenWidth - 20, 30)];
        self.mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.mainView];
        
        self.headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 18, 40, 40)];
        self.headerImgView.layer.cornerRadius = self.headerImgView.height * 0.5;
        self.headerImgView.layer.masksToBounds = YES;
        [self.mainView addSubview:self.headerImgView];
        
        float fMyNameLabLeft = self.headerImgView.right_sd + 18;
        self.myNameLab = [[UILabel alloc] initWithFrame:CGRectMake(fMyNameLabLeft, self.headerImgView.top_sd, kNameWidth, 20)];
        self.myNameLab.font = [UIFont systemFontOfSize:16];
        self.myNameLab.textColor = UIColorFromRGB(0x555555);
        [self.mainView addSubview:self.myNameLab];
        
        self.addressLab = [[UILabel alloc] initWithFrame:CGRectMake(self.myNameLab.left_sd, self.myNameLab.bottom_sd + 5, self.myNameLab.width_sd, 16)];
        self.addressLab.font = [UIFont systemFontOfSize:12];
        self.addressLab.textColor = UIColorFromRGB(0x999999);
        [self.mainView addSubview:self.addressLab];
        
        self.contentLab = [[UILabel alloc] initWithFrame:CGRectMake(self.myNameLab.left_sd, self.addressLab.bottom_sd + 5, self.myNameLab.width_sd, 0)];
        self.contentLab.font = [UIFont systemFontOfSize:16];
        self.contentLab.numberOfLines = 0;
        self.contentLab.textColor = UIColorFromRGB(0x555555);
        [self.mainView addSubview:self.contentLab];

        //===========报修图片，最多3张===========
        float fImgWitdh = (self.myNameLab.width_sd - 10.0) / 3.0;
        fImgWitdh = fImgWitdh > 73 ? 73 : fImgWitdh;
        self.repairsImgBGView = [[SYPhotoContainerView alloc] initWithFrame:CGRectMake(self.myNameLab.left_sd, self.contentLab.bottom_sd + 5, self.myNameLab.width_sd, fImgWitdh)];
        [self.mainView addSubview:self.repairsImgBGView];
        self.repairsImgHeight = fImgWitdh;

        //===========时间、工单===========
        self.timeLab = [[UILabel alloc] initWithFrame:CGRectMake(self.myNameLab.left_sd, self.repairsImgBGView.bottom_sd + 5, self.myNameLab.width_sd * 0.4, 16)];
        self.timeLab.font = [UIFont systemFontOfSize:12];
        self.timeLab.textColor = UIColorFromRGB(0x999999);
        [self.mainView addSubview:self.timeLab];
        
        self.orderNumLab = [[UILabel alloc] initWithFrame:CGRectMake(self.timeLab.right_sd, self.timeLab.top_sd, self.myNameLab.width_sd * 0.6, 16)];
        self.orderNumLab.textAlignment = NSTextAlignmentRight;
        self.orderNumLab.font = [UIFont systemFontOfSize:12];
        self.orderNumLab.textColor = UIColorFromRGB(0x999999);
        [self.mainView addSubview:self.orderNumLab];
        

        //=======评论区域===========
        self.commentBGView = [[UIView alloc] initWithFrame:CGRectMake(self.myNameLab.left_sd, self.timeLab.bottom_sd + 10, self.myNameLab.width_sd, 0)];
        self.commentBGView.clipsToBounds = YES;
        [self.mainView addSubview:self.commentBGView];
        
        NSString *historyStr = @"历史评论 >";
        self.historyCommentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.historyCommentBtn setTitle:historyStr forState:UIControlStateNormal];
        self.historyCommentBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        CGSize historySize = [historyStr sizeWithFont:self.historyCommentBtn.titleLabel.font andSize:CGSizeMake(self.commentBGView.width_sd, MAXFLOAT)];
        self.historyCommentBtn.frame = CGRectMake(self.commentBGView.width_sd - historySize.width, 0, historySize.width, 20);
        [self.historyCommentBtn setTitleColor: UIColorFromRGB(0x555555) forState:UIControlStateNormal];
        [self.historyCommentBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.commentBGView addSubview:self.historyCommentBtn];

        //==第一个评论区域==
        self.commnetOneView = [[UIView alloc] initWithFrame:CGRectMake(0, self.historyCommentBtn.bottom_sd, self.commentBGView.width_sd, 0)];
        self.commnetOneView.clipsToBounds = YES;
        [self.commentBGView addSubview:self.commnetOneView];

        self.commnetoneLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.commnetOneView.width_sd, 0)];
        self.commnetoneLab.font = [UIFont systemFontOfSize:14];
        self.commnetoneLab.textColor = UIColorFromRGB(0x555555);
        [self.commnetOneView addSubview:self.commnetoneLab];
        
        self.commnetOneImgBGView = [[SYPhotoContainerView alloc] initWithFrame:CGRectMake(0, self.commnetoneLab.bottom_sd, self.myNameLab.width_sd, fImgWitdh - 20)];
        [self.commnetOneView addSubview:self.commnetOneImgBGView];
        
        //==第二个评论区域==
        self.commnetTwoView = [[UIView alloc] initWithFrame:CGRectMake(0, self.commnetOneView.bottom_sd, self.commnetOneView.width_sd, 0)];
        self.commnetTwoView.clipsToBounds = YES;
        [self.commentBGView addSubview:self.commnetTwoView];
        
        self.commnetTwoLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.commnetTwoView.width_sd, 0)];
        self.commnetTwoLab.font = [UIFont systemFontOfSize:14];
        self.commnetTwoLab.textColor = UIColorFromRGB(0x555555);
        [self.commnetTwoView addSubview:self.commnetTwoLab];
        
        self.commnetTwoImgBGView = [[SYPhotoContainerView alloc] initWithFrame:CGRectMake(0, self.commnetTwoLab.bottom_sd, self.myNameLab.width_sd, fImgWitdh - 20)];
        [self.commnetTwoView addSubview:self.commnetTwoImgBGView];
        
        //==第三个评论区域==
        self.commnetThreeView = [[UIView alloc] initWithFrame:CGRectMake(0, self.commnetTwoView.bottom_sd, self.commnetOneView.width_sd, 0)];
        self.commnetThreeView.clipsToBounds = YES;
        [self.commentBGView addSubview:self.commnetThreeView];
        
        self.commnetThreeLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.commnetThreeView.width_sd, 0)];
        self.commnetThreeLab.font = [UIFont systemFontOfSize:14];
        self.commnetThreeLab.textColor = UIColorFromRGB(0x555555);
        [self.commnetThreeView addSubview:self.commnetThreeLab];
        
        self.commnetThreeImgBGView = [[SYPhotoContainerView alloc] initWithFrame:CGRectMake(0, self.commnetThreeLab.bottom_sd, self.myNameLab.width_sd, fImgWitdh - 20)];
        [self.commnetThreeView addSubview:self.commnetThreeImgBGView];
        

        
        //===========底部按钮===========
        fImgWitdh = (self.myNameLab.width_sd - 15.0) / 4.0;
        for (int i = 0; i < 4; i++) {
            UIButton *repairsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [repairsBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            repairsBtn.frame = CGRectMake((i * fImgWitdh) + (i * 5.0) + self.myNameLab.left_sd, self.commentBGView.bottom_sd + 20, fImgWitdh, 30);
            repairsBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            [self.mainView addSubview:repairsBtn];
            
            [self.repairsBtnMArr addObject:repairsBtn];
        }
    }
    return self;
}


#pragma mark - private
- (void)repairBtnTitleWithRepairType:(PropertyRepairType)type OrderType:(RepairListOrderType)oderType{

    if (type == propertyNoFixViewType) {
        for (int i = 0; i < self.repairsBtnMArr.count ; i++) {
            UIButton *btn = [self.repairsBtnMArr objectAtIndex:i];
            if (i == 0) {
                [btn setTitle:@"取消" forState:UIControlStateNormal];
                btn.backgroundColor = UIColorFromRGB(0xFF638A);
            }else if (i == 1) {
                [btn setTitle:@"催单" forState:UIControlStateNormal];
                btn.backgroundColor = UIColorFromRGB(0xFFD21F);
            }else if (i == 2) {
                [btn setTitle:@"评论" forState:UIControlStateNormal];
                btn.backgroundColor = UIColorFromRGB(0x54EEFF);
            }else if (i == 3) {
                [btn setTitle:self.isExtensioned ? @"合起" : @"展开" forState:UIControlStateNormal];
                btn.backgroundColor = UIColorFromRGB(0xD466FF);
            }
        }
    }else if (type == propertyFixingiewType){
        for (int i = 0; i < self.repairsBtnMArr.count ; i++) {
            UIButton *btn = [self.repairsBtnMArr objectAtIndex:i];
            if (i == 0) {
                btn.hidden = YES;
            }else if (i == 1) {
                [btn setTitle:@"催单" forState:UIControlStateNormal];
                btn.backgroundColor = UIColorFromRGB(0xFFD21F);
            }else if (i == 2) {
                [btn setTitle:@"评论" forState:UIControlStateNormal];
                btn.backgroundColor = UIColorFromRGB(0x54EEFF);
            }else if (i == 3) {
                [btn setTitle:self.isExtensioned ? @"合起" : @"展开" forState:UIControlStateNormal];
                btn.backgroundColor = UIColorFromRGB(0xD466FF);
            }
        }
    }else if (type == propertyNoComfirmViewType){
        for (int i = 0; i < self.repairsBtnMArr.count ; i++) {
            UIButton *btn = [self.repairsBtnMArr objectAtIndex:i];
            if (i == 0) {
                [btn setTitle:@"返单" forState:UIControlStateNormal];
                btn.backgroundColor = UIColorFromRGB(0xFF638A);
            }else if (i == 1) {
                [btn setTitle:@"确认" forState:UIControlStateNormal];
                btn.backgroundColor = UIColorFromRGB(0xFFD21F);
            }else if (i == 2) {
                [btn setTitle:@"评论" forState:UIControlStateNormal];
                btn.backgroundColor = UIColorFromRGB(0x54EEFF);
            }else if (i == 3) {
                [btn setTitle:self.isExtensioned ? @"合起" : @"展开" forState:UIControlStateNormal];
                btn.backgroundColor = UIColorFromRGB(0xD466FF);
            }
        }
    }else if (type == propertyFinishViewType){
        for (int i = 0; i < self.repairsBtnMArr.count ; i++) {
            UIButton *btn = [self.repairsBtnMArr objectAtIndex:i];
            if (i == 0) {
                [btn setTitle:@"dd" forState:UIControlStateNormal];
            }else if (i == 1) {
                [btn setTitle:@"aa" forState:UIControlStateNormal];
            }else if (i == 2) {
                [btn setTitle:@"评论" forState:UIControlStateNormal];
                btn.backgroundColor = UIColorFromRGB(0x54EEFF);
            }else if (i == 3) {
                [btn setTitle:self.isExtensioned ? @"合起" : @"展开" forState:UIControlStateNormal];
                btn.backgroundColor = UIColorFromRGB(0xD466FF);
            }
        }
    }
}


#pragma mark - event
- (void)btnClick:(UIButton *)btn{
    PropertyBtnClickType type = -1;
    if ([btn.titleLabel.text isEqualToString:@"取消"]) {
        type = PropertyCancelType;
    }else if ([btn.titleLabel.text isEqualToString:@"催单"]) {
        type = PropertyUrgeType;
    }else if ([btn.titleLabel.text isEqualToString:@"评论"]) {
        type = PropertyCommentType;
    }else if ([btn.titleLabel.text isEqualToString:@"展开"] || [btn.titleLabel.text isEqualToString:@"合起"]) {
        type = PropertExtensionType;
    }else if ([btn.titleLabel.text isEqualToString:@"返单"]) {
        type = PropertyBackType;
    }else if ([btn.titleLabel.text isEqualToString:@"确认"]) {
        type = PropertConfirmType;
    }else if ([btn.titleLabel.text isEqualToString:@"历史评论 >"]) {
        type = PropertHistoryCommentType;
    }

    if ([self.delegate respondsToSelector:@selector(propertyBtnClickType:IndexPath:Button:)]) {
        [self.delegate propertyBtnClickType:type IndexPath:self.indexPath Button:btn];
    }
}


#pragma mark - public
- (void)setDataWithPropertyRepairType:(PropertyRepairType)type OrderType:(RepairListOrderType)oderType PropertyRepairModel:(SYPropertyRepairModel *)repairModel{

    if (!repairModel) {
        return;
    }
    self.isExtensioned = repairModel.isExtensioned;
    self.myNameLab.text = [SYLoginInfoModel shareUserInfo].userInfoModel.username;
    self.addressLab.text = repairModel.faddress;
    self.contentLab.text = repairModel.fservicecontent;
    self.timeLab.text = repairModel.fcreatetime;
    self.orderNumLab.text = repairModel.fordernum;

    //===设置工单图片 用于工单图片点击====
    NSMutableArray *repairsImagMArr = [[NSMutableArray alloc] init];
    for (SYRepairsImagListModel *imgModfel in repairModel.repairs_imag_list) {
        [repairsImagMArr addObject:imgModfel.fimagpath];
    }
    self.repairsImgBGView.picPathStringsArray = repairsImagMArr;
    
    
    //===工单图片区域===
    if (repairModel.repairs_imag_list.count > 0) {
        self.repairsImgBGView.height_sd = self.repairsImgHeight;
    }else{
        self.repairsImgBGView.height_sd = 0;
    }

    //========评论 只显示3条数据========
    WEAK_SELF;
    if (repairModel.isExtensioned && repairModel.repairOrderCommentModelArr.count > 0) {
        [repairModel.repairOrderCommentModelArr enumerateObjectsUsingBlock:^(SYRepairOrderCommentModel *orderModel, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@",orderModel.name, orderModel.fcontent]];
            [attStr setAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xec5f05)} range:NSMakeRange(0, orderModel.name.length)];
            
            NSMutableArray *orderImag = [[NSMutableArray alloc] init];
            for (SYRepairsImagListModel *imgModfel in orderModel.record_imag_list) {
                [orderImag addObject:imgModfel.fimagpath];
            }
            if (idx == 0) {
                weakSelf.commnetoneLab.attributedText = attStr;
                weakSelf.commnetoneLab.height_sd = orderModel.repairOrderCommentHeight;
                
                weakSelf.commnetOneImgBGView.picPathStringsArray = orderImag;
                weakSelf.commnetOneImgBGView.top_sd = weakSelf.commnetoneLab.height_sd;
                weakSelf.commnetOneImgBGView.height_sd = orderImag.count > 0 ? self.repairsImgHeight : 0;
                
                weakSelf.commnetOneView.height_sd = weakSelf.commnetOneImgBGView.bottom_sd;
                weakSelf.commnetOneView.top_sd = weakSelf.historyCommentBtn.height_sd;

                weakSelf.commentBGView.height_sd = weakSelf.commnetOneView.bottom_sd;
            }
            else if (idx == 1) {
                weakSelf.commnetTwoLab.attributedText = attStr;
                weakSelf.commnetTwoLab.height_sd = orderModel.repairOrderCommentHeight;

                weakSelf.commnetTwoImgBGView.picPathStringsArray = orderImag;
                weakSelf.commnetTwoImgBGView.top_sd = weakSelf.commnetTwoLab.height_sd;
                weakSelf.commnetTwoImgBGView.height_sd = orderImag.count > 0 ? self.repairsImgHeight : 0;

                weakSelf.commnetTwoView.height_sd = weakSelf.commnetTwoImgBGView.bottom_sd;
                weakSelf.commnetTwoView.top_sd = weakSelf.commnetOneView.bottom_sd;
                
                weakSelf.commentBGView.height_sd = weakSelf.commnetTwoView.bottom_sd;
            }
            else if (idx == 2) {
                weakSelf.commnetThreeLab.attributedText = attStr;
                weakSelf.commnetThreeLab.height_sd = orderModel.repairOrderCommentHeight;

                weakSelf.commnetThreeImgBGView.picPathStringsArray = orderImag;
                weakSelf.commnetThreeImgBGView.top_sd = weakSelf.commnetThreeLab.height_sd;
                weakSelf.commnetThreeImgBGView.height_sd = orderImag.count > 0 ? self.repairsImgHeight : 0;
                
                weakSelf.commnetThreeView.height_sd = weakSelf.commnetThreeImgBGView.bottom_sd;
                weakSelf.commnetThreeView.top_sd = weakSelf.commnetTwoView.bottom_sd;
                
                weakSelf.commentBGView.height_sd = weakSelf.commnetThreeView.bottom_sd;
            }
        }];
    }
    else{
        weakSelf.commentBGView.height_sd = 0;
    }

    //===底部按钮set title===
    [self repairBtnTitleWithRepairType:type OrderType:oderType];

    //头像
    if ([SYLoginInfoModel shareUserInfo].personalSpaceModel.headerImg) {
        self.headerImgView.image = [SYLoginInfoModel shareUserInfo].personalSpaceModel.headerImg;
    }else{
        [self.headerImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[SYLoginInfoModel shareUserInfo].personalSpaceModel.head_url]]  placeholderImage:[UIImage imageNamed:@"sy_navigation_normal_header"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (image) {
                [SYLoginInfoModel shareUserInfo].personalSpaceModel.headerImg = image;
                [SYLoginInfoModel saveWithSYLoginInfo];
            }
        }];
    }
    
    //=====set frame======
    self.contentLab.height_sd = repairModel.fservicecontentHeight;
    self.repairsImgBGView.top_sd = self.contentLab.bottom_sd + 5;
    self.timeLab.top_sd = self.repairsImgBGView.bottom_sd;
    self.orderNumLab.top_sd = self.timeLab.top_sd;
    self.commentBGView.top_sd = self.timeLab.bottom_sd + 10;

    
    float fRepairsBtnBottom = 0;
    for (UIButton *repairsBtn in self.repairsBtnMArr) {
        fRepairsBtnBottom = repairsBtn.bottom_sd;
        repairsBtn.top_sd = self.commentBGView.bottom_sd + 5;
    }
    
    if (self.repairsBtnMArr.count > 0) {
        self.mainView.height_sd = repairModel.propertyRepairCellHeight - 8 + repairModel.repairOrderCommentHeight;
    }
}
@end
