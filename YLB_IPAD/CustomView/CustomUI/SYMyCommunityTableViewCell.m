//
//  SYMyCommunityTableViewCell.m
//  YLB
//
//  Created by sayee on 17/4/1.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYMyCommunityTableViewCell.h"

@interface SYMyCommunityTableViewCell()

@property (nonatomic, retain) UIView *mainView;
@property (nonatomic, retain) UILabel *leftLab;
@property (nonatomic, retain) UIButton *callBtn;
@property (nonatomic, retain) UIImageView *arrowImgView;

@end


@implementation SYMyCommunityTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIColorFromRGB(0xebebeb);
        
        self.mainView = [[UIView alloc] initWithFrame:CGRectMake(10, 8, kScreenWidth - 20, SYMyCommunityTableViewCellHeight - 8)];
        self.mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.mainView];
        
        self.callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.callBtn setTitle:@"快捷呼叫" forState:UIControlStateNormal];
        self.callBtn.backgroundColor = UIColorFromRGB(0xD23023);
        self.callBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.callBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.callBtn.frame = CGRectMake(self.mainView.width - 80 - 10, 5, 80, self.mainView.height - 10);
        [self.callBtn addTarget:self action:@selector(callServiceClick:) forControlEvents:UIControlEventTouchUpInside];
        self.callBtn.center = CGPointMake(self.callBtn.centerX, self.mainView.height * 0.5f);
        [self.mainView addSubview:self.callBtn];
        self.callBtn.hidden = YES;
        
        self.leftLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.callBtn.left_sd - 20, self.mainView.height)];
        self.leftLab.font = [UIFont systemFontOfSize:14.0];
        [self.mainView addSubview:self.leftLab];

        
        UIImage *img = [UIImage imageNamed:@"sy_me_rightArrow"];
        self.arrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.mainView.width - 10 - img.size.width, 0, img.size.width, img.size.height)];
        self.arrowImgView.image = img;
        self.arrowImgView.center = CGPointMake(self.arrowImgView.centerX, self.mainView.height_sd * 0.5);
        [self.mainView addSubview:self.arrowImgView];

    }
    return self;
}



#pragma mark - event
- (void)callServiceClick:(UIButton *)btn{
    
    if ([self.delegate respondsToSelector:@selector(callService:)]) {
        [self.delegate callService:self.strTel];
    }
}


#pragma mark - public
- (void)updateLeftInfo:(NSString *)leftInfo Type:(RightType)type{
    
    if (!leftInfo) {
        return;
    }
    
    self.leftLab.text = leftInfo;
    
    if (type == btnType) {
        self.callBtn.hidden = NO;
        self.arrowImgView.hidden = YES;
    }
    else if (type == arrowType) {
        self.callBtn.hidden = YES;
        self.arrowImgView.hidden = NO;
    }
}

@end
