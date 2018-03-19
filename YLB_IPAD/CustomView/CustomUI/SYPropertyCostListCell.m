//
//  SYPropertyCostListCell.m
//  YLB
//
//  Created by jinyou on 2017/6/19.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYPropertyCostListCell.h"
#import <CoreText/CoreText.h>

@interface SYPropertyCostListCell()
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UIView *underLine;
@property (nonatomic, strong) NSMutableArray *arrayProjectList;
@property (nonatomic, strong) UILabel *lblMoneyAccount;
@end

@implementation SYPropertyCostListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //self.backgroundColor = UIColorFromRGB(0xebebeb);
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.arrayProjectList = [NSMutableArray array];
    self.backgroundColor = [UIColor clearColor];
    
    self.backView = [[UIView alloc] init];
    self.backView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.backView];

    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:@"费用明细清单：本期共计缴费￥500"];
    
    [attributeString addAttribute:(NSString *)kCTForegroundColorAttributeName
                            value:(id)[UIColor blackColor].CGColor
                            range:NSMakeRange(0, 5)];
    
    [attributeString addAttribute:(NSString *)kCTForegroundColorAttributeName
                        value:(id)[UIColor greenColor].CGColor
                        range:NSMakeRange(6, attributeString.length)];

    self.lblTitle = [[UILabel alloc] init];
    self.lblTitle.attributedText = attributeString;
    [self.backView addSubview:self.lblTitle];
    
    self.underLine = [[UIView alloc] init];
    self.underLine.backgroundColor = [UIColor lightGrayColor];
    [self.backView addSubview:self.underLine];
    
    
    NSArray *arrayList = [[NSArray alloc] initWithObjects:@"电费：",@"水费：",@"固话费：",@"宽带费：",@"天然气费：", nil];
    for (int i=0; i<arrayList.count; i++) {
        UILabel *lblName = [[UILabel alloc] init];
        lblName.text = [arrayList objectAtIndex:i];
        [self.backView addSubview:lblName];
        [self.arrayProjectList addObject:lblName];
        
        UILabel *lblMoney = [[UILabel alloc] init];
        lblMoney.text = @"￥100.00";
        [self.backView addSubview:lblMoney];
        [self.arrayProjectList addObject:lblMoney];
        
        UILabel *lblStatus = [[UILabel alloc] init];
        lblStatus.text = @"已缴";
        [self.backView addSubview:lblStatus];
        [self.arrayProjectList addObject:lblStatus];
    }
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:@"已选共计：￥0.00 去支付"];
    NSRange contentRange = {0,[content length]};
    [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
    
    self.lblMoneyAccount = [[UILabel alloc] init];
    self.lblMoneyAccount.backgroundColor = [UIColor clearColor];
    self.lblMoneyAccount.attributedText = content;
    self.lblMoneyAccount.textAlignment = NSTextAlignmentCenter;
    [self.backView addSubview:self.lblMoneyAccount];
    
}

- (void)layoutSubviews
{
    _backView.frame = CGRectMake(10,0,screenWidth - 20,self.frame.size.height);
    _lblTitle.frame = CGRectMake(10,0,_backView.frame.size.width - 20,20);
    _underLine.frame = CGRectMake(10,_lblTitle.frame.origin.y + _lblTitle.frame.size.height,_backView.frame.size.width - 20,1);
    
    for (int i=0; i<self.arrayProjectList.count; i++) {
        UILabel *label = (UILabel*)[self.arrayProjectList objectAtIndex:i];
        if (i%3 == 0) {
            label.frame = CGRectMake(10,0,70,50);
        }else if (i%3 == 1){
            label.frame = CGRectMake(_backView.frame.size.width - 70,0,70,50);
        }else if (i%3 == 2){
            label.frame = CGRectMake(_backView.frame.size.width - 140,70,_backView.frame.size.width - 140,50);
        }
    }
    
    _lblMoneyAccount.frame = CGRectMake(10,_backView.frame.size.height - 60,_backView.frame.size.width - 20,50);
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
