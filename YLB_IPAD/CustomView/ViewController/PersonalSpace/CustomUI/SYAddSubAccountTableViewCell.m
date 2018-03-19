//
//  SYAddSubAccountTableViewCell.m
//  YLB
//
//  Created by sayee on 17/3/29.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYAddSubAccountTableViewCell.h"
#import "SYRoundHeadView.h"

@interface SYAddSubAccountTableViewCell()
/** 存放下面所有的子view */
@property (strong, nonatomic) UIView *mainView;
/** 紧急呼叫 */
@property (strong, nonatomic) UILabel *phoneNumberLabel;
/** name */
@property (strong, nonatomic) UILabel *nameLabel;
/** 头像 */
@property (strong, nonatomic) SYRoundHeadView *headerView;

@end

@implementation SYAddSubAccountTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIColorFromRGB(0xebebeb);
        
        self.mainView = [[UIView alloc] initWithFrame:CGRectMake(10, 8, kScreenWidth - 20, SYAddSubAccountTableViewCellHeight - 8)];
        [self.mainView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.mainView];
        
        // 头像
        self.headerView = [[SYRoundHeadView alloc] initWithFrame:CGRectMake(10, 5, self.mainView.height - 10, self.mainView.height - 10)];
        self.headerView.layer.cornerRadius = self.headerView.height_sd * 0.5f;
        self.headerView.layer.masksToBounds = YES;
        [self.mainView addSubview:self.headerView];

        self.phoneNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headerView.right_sd + 10, 0, 130, self.mainView.height)];
        [self.phoneNumberLabel setTextColor:UIColorFromRGB(0xD23023)];
        [self.phoneNumberLabel setFont:[UIFont systemFontOfSize:14]];
        [self.mainView addSubview:self.phoneNumberLabel];

        float fNameLeft = self.phoneNumberLabel.right_sd + 0;
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(fNameLeft, 0, self.mainView.width_sd - fNameLeft - 10, self.mainView.height)];
        [self.nameLabel setTextColor:UIColorFromRGB(0x999999)];
        [self.nameLabel setFont:[UIFont systemFontOfSize:14]];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        [self.mainView addSubview:self.nameLabel];
        
    }
    return self;
}


#pragma mark - public
- (void)updateData:(SYContactsModel *)model{

    if (!model) {
        return;
    }
    [self.headerView setTitle:model.phoneNumberStr withshowWordLength:4];
    self.nameLabel.text = [NSString stringWithFormat:@"(%@)",model.fullNameStr ? model.fullNameStr : model.phoneNumberStr] ;
    self.phoneNumberLabel.text = model.phoneNumberStr;
}
@end
