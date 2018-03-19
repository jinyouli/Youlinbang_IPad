//
//  SYPropertyCostTableViewCell.m
//  YLB
//
//  Created by jinyou on 2017/6/19.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYPropertyCostTableViewCell.h"
#import "SYPropertyCostDetailVC.h"

typedef enum {
    NoCostBtnTag = 0,
    FinishCostBtnTag,
    OtherBtnTag
}btnTag;

@interface SYPropertyCostTableViewCell()
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIButton *goCostViewBtn;
@property (nonatomic, strong) UIView *underLine;

@property (nonatomic, strong) UILabel *lblHouseInfo;
@property (nonatomic, strong) UILabel *lblPaymentDetail;
@end

@implementation SYPropertyCostTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //self.backgroundColor = UIColorFromRGB(0xebebeb);
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.backgroundColor = [UIColor clearColor];
    
    self.backView = [[UIView alloc] init];
    self.backView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.backView];
    
    self.lblHouseInfo = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, screenWidth - 20, 50)];
    self.lblHouseInfo.text = @"小区信息";
    [self.backView addSubview:self.lblHouseInfo];
    

    self.lblPaymentDetail = [[UILabel alloc] init];
    self.lblPaymentDetail.backgroundColor = [UIColor clearColor];
    self.lblPaymentDetail.text = @"全部账单已还清";
    self.lblPaymentDetail.textAlignment = NSTextAlignmentCenter;
    [self.backView addSubview:self.lblPaymentDetail];
    
    self.underLine = [[UIView alloc] init];
    self.underLine.backgroundColor = [UIColor lightGrayColor];
    [self.backView addSubview:self.underLine];
    
    
    UIButton *goCostViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    goCostViewBtn.tag = NoCostBtnTag;
    [goCostViewBtn setTitle:@"去缴费" forState:UIControlStateNormal];
    [goCostViewBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    //goCostViewBtn.backgroundColor = UIColorFromRGB(0xEC5F05);
    [goCostViewBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:goCostViewBtn];
    self.goCostViewBtn = goCostViewBtn;
}

#pragma mark - event
- (void)btnClick:(UIButton *)btn{
    if (btn.tag == NoCostBtnTag) {
        
        SYPropertyCostDetailVC *vc = [[SYPropertyCostDetailVC alloc] initWithRepairListOrderType:propertyComplainListType WithTitle:@"绿盈山庄 5单元 403"];
        [FrameManager pushViewController:vc animated:YES];
    }
}

-(void)layoutSubviews
{
    self.backView.frame = CGRectMake(10,0,screenWidth - 20,self.frame.size.height);
    self.lblPaymentDetail.frame = CGRectMake(10, self.lblHouseInfo.origin.y + self.lblHouseInfo.size.height, self.backView.frame.size.width - 20, self.frame.size.height - self.goCostViewBtn.frame.size.height - self.lblHouseInfo.frame.size.height - 10);
    self.underLine.frame = CGRectMake(10, self.backView.frame.size.height - 40, self.backView.frame.size.width - 20, 1);
    self.goCostViewBtn.frame = CGRectMake(screenWidth - 90, self.frame.size.height - 30, 80, 30);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
