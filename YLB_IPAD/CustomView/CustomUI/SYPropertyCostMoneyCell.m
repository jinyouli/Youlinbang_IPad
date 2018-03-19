//
//  SYPropertyCostMoneyCell.m
//  YLB
//
//  Created by jinyou on 2017/6/19.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYPropertyCostMoneyCell.h"

@interface SYPropertyCostMoneyCell()
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UIView *underLine_first;
@property (nonatomic, strong) UILabel *lblTip;
@property (nonatomic, strong) UILabel *lblMoneyAccount;
@property (nonatomic, strong) UIView *underLine_second;
@property (nonatomic, strong) UIButton *moneyPayBtn;
@end

@implementation SYPropertyCostMoneyCell

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
    
    
    self.lblTitle = [[UILabel alloc] init];
    self.lblTitle.text = @"7-9月物业缴费单";
    [self.backView addSubview:self.lblTitle];
    
    self.underLine_first = [[UIView alloc] init];
    self.underLine_first.backgroundColor = [UIColor lightGrayColor];
    [self.backView addSubview:self.underLine_first];
    
    self.lblTip = [[UILabel alloc] init];
    self.lblTip.backgroundColor = [UIColor clearColor];
    self.lblTip.text = @"本期总计应缴";
    self.lblTip.textAlignment = NSTextAlignmentLeft;
    [self.backView addSubview:self.lblTip];
    
    self.lblMoneyAccount = [[UILabel alloc] init];
    self.lblMoneyAccount.backgroundColor = [UIColor clearColor];
    self.lblMoneyAccount.text = @"￥500.00";
    self.lblMoneyAccount.textAlignment = NSTextAlignmentCenter;
    [self.backView addSubview:self.lblMoneyAccount];
    
    self.underLine_second = [[UIView alloc] init];
    self.underLine_second.backgroundColor = [UIColor lightGrayColor];
    [self.backView addSubview:self.underLine_second];
    
    
    UIButton *moneyPayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moneyPayBtn setTitle:@"全额支付" forState:UIControlStateNormal];
    [moneyPayBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [moneyPayBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:moneyPayBtn];
    self.moneyPayBtn = moneyPayBtn;
}

-(void)layoutSubviews
{
    _backView.frame = CGRectMake(10,0,screenWidth - 20,self.frame.size.height);
    _lblTitle.frame = CGRectMake(10,0,_backView.frame.size.width - 20,20);
    _underLine_first.frame = CGRectMake(10,_lblTitle.frame.origin.y + _lblTitle.frame.size.height,_backView.frame.size.width - 20,1);
    _lblTip.frame = CGRectMake(10,_underLine_first.frame.origin.y + 1,200,20);
    _lblMoneyAccount.frame = CGRectMake(10,_lblTip.frame.origin.y + _lblTip.frame.size.height,_backView.frame.size.width - 20,50);
    _underLine_second.frame = CGRectMake(10,_lblMoneyAccount.frame.origin.y + _lblMoneyAccount.frame.size.height,_backView.frame.size.width - 20,1);
    _moneyPayBtn.frame = CGRectMake(_backView.frame.size.width - 100,_underLine_second.frame.origin.y + 1,100,50);

}

- (void)btnClick
{
    
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
