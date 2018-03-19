//
//  SYHistoryCommentTableViewCell.m
//  YLB
//
//  Created by YAYA on 2017/4/18.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYHistoryCommentTableViewCell.h"
#import "SYPhotoContainerView.h"

@interface SYHistoryCommentTableViewCell ()

@property (nonatomic, retain) UIView *mainView;
@property (nonatomic, retain) UILabel *myNameLab;
@property (nonatomic, retain) UILabel *timeLab;
@property (nonatomic, retain) UILabel *contentLab;
@property (strong, nonatomic) SYPhotoContainerView *commentImgBGView;
@end

@implementation SYHistoryCommentTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        self.mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
        self.mainView.backgroundColor = UIColorFromRGB(0xebebeb);
        [self.contentView addSubview:self.mainView];

        self.myNameLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.mainView.width_sd * 0.2, 20)];
        self.myNameLab.font = [UIFont systemFontOfSize:14];
        self.myNameLab.textColor = UIColorFromRGB(0xEC5F05);
        [self.mainView addSubview:self.myNameLab];

        self.contentLab = [[UILabel alloc] initWithFrame:CGRectMake(self.myNameLab.right_sd + 5, self.myNameLab.top_sd, self.mainView.width_sd - self.myNameLab.right_sd - 10, 0)];
        self.contentLab.font = [UIFont systemFontOfSize:14];
        self.contentLab.numberOfLines = 0;
        self.contentLab.textColor = UIColorFromRGB(0x555555);
        [self.mainView addSubview:self.contentLab];
  
        self.commentImgBGView = [[SYPhotoContainerView alloc] initWithFrame:CGRectMake(self.contentLab.left, self.contentLab.bottom_sd, self.contentLab.width_sd, 0)];
        [self.mainView addSubview:self.commentImgBGView];
        
        self.timeLab = [[UILabel alloc] initWithFrame:CGRectMake(self.contentLab.left_sd, self.commentImgBGView.bottom_sd + 5, self.contentLab.width_sd, 20)];
        self.timeLab.font = [UIFont systemFontOfSize:12];
        self.timeLab.textColor = UIColorFromRGB(0x999999);
        [self.mainView addSubview:self.timeLab];
    }
    return self;
}


#pragma mark - public
- (void)updataInfo:(SYRepairOrderCommentModel *)orderModel{

    self.myNameLab.text = orderModel.name;
    self.contentLab.text = orderModel.fcontent;
    self.timeLab.text = orderModel.fcreatetime;
    
    NSMutableArray *orderImag = [[NSMutableArray alloc] init];
    for (SYRepairsImagListModel *imgModfel in orderModel.record_imag_list) {
        [orderImag addObject:imgModfel.fimagpath];
    }
    self.commentImgBGView.picPathStringsArray = orderImag;
    
    self.contentLab.height_sd = orderModel.repairOrderCommentHeight - orderModel.repairOrderCommentImgHeight - self.timeLab.height_sd - 10;
    self.commentImgBGView.top_sd = self.contentLab.bottom_sd;
    self.commentImgBGView.height_sd = orderModel.repairOrderCommentImgHeight;
    self.timeLab.top_sd = self.commentImgBGView.bottom_sd;
    self.mainView.height_sd = orderModel.repairOrderCommentHeight;
}
@end
