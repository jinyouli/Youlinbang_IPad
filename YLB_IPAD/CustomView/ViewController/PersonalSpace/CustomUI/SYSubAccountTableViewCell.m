//
//  SYSubAccountTableViewCell.m
//  YLB
//
//  Created by sayee on 17/3/29.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYSubAccountTableViewCell.h"
#import "SYSubAccountModel.h"
#import "SYRoundHeadView.h"

@interface SYSubAccountTableViewCell ()

/** 存放下面所有的子view */
@property (strong, nonatomic) UIView *mainView;
/** 紧急呼叫 */
@property (strong, nonatomic) UILabel *emergencyCallLabel;
/** name */
@property (strong, nonatomic) UILabel *nameLabel;
/** 头像 */
@property (strong, nonatomic) SYRoundHeadView *headerImgView;
@end


@implementation SYSubAccountTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIColorFromRGB(0xebebeb);
        
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(10, 8, kScreenWidth - 20, SYSubAccountTableViewCellHeight - 8)];
        [self.mainView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.mainView];
        
        // 头像
        self.headerImgView = [[SYRoundHeadView alloc] initWithFrame:CGRectMake(10, 5, self.mainView.height - 10, self.mainView.height - 10)];
        self.headerImgView.layer.cornerRadius = self.headerImgView.height_sd * 0.5f;
        self.headerImgView.layer.masksToBounds = YES;
        [self.mainView addSubview:self.headerImgView];
        
        // 紧急呼叫
        UIFont *font = [UIFont systemFontOfSize:12];
        CGSize size = [@"紧急呼叫" sizeWithFont:font andSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        self.emergencyCallLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.mainView.width_sd - size.width - 10, 0, size.width, self.mainView.height)];
        [self.emergencyCallLabel setTextColor:UIColorFromRGB(0xD23023)];
        self.emergencyCallLabel.text = @"紧急呼叫";
        [self.emergencyCallLabel setFont:font];
        [self.mainView addSubview:self.emergencyCallLabel];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headerImgView.right_sd + 10, 0, self.emergencyCallLabel.left_sd - self.headerImgView.right_sd - 20, self.mainView.height)];
        [self.nameLabel setTextColor:UIColorFromRGB(0x999999)];
        [self.nameLabel setFont:[UIFont systemFontOfSize:14]];
        [self.mainView addSubview:self.nameLabel];
    }
    return self;
}


#pragma mark - piublic
- (void)updateInfo:(SYSubAccountModel *)model{
    
    if (!model) {
        return;
    }
    [self.headerImgView setTitle:model.username withshowWordLength:3];
    self.nameLabel.text = model.alias.length > 0 ? model.alias : model.username;
    self.emergencyCallLabel.hidden = !model.is_called_number;
}

- (void)updatePhoneNumber:(NSString *)phoneNumber{
    [self.headerImgView setTitle:phoneNumber withshowWordLength:3];
    self.nameLabel.text = phoneNumber;
    self.emergencyCallLabel.hidden = YES;
}
@end
