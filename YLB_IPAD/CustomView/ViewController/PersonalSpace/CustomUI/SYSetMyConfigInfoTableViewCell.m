//
//  SYSetMyConfigInfoTableViewCell.m
//  YLB
//
//  Created by YAYA on 2017/4/8.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYSetMyConfigInfoTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface SYSetMyConfigInfoTableViewCell()<UITextFieldDelegate>

@property (nonatomic, retain) UIView *mainView;
@property (nonatomic, retain) UIImageView *headerImgView;
@property (nonatomic, retain) UILabel *leftLab;
@property (nonatomic, retain) UITextField *righttxtField;
@property (nonatomic, assign) BOOL isShowMotto;
@property (nonatomic, assign) BOOL isShowalias;
@end


@implementation SYSetMyConfigInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIColorFromRGB(0xebebeb);
        
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, SYSetMyConfigInfoTableViewCellHeight)];
        self.mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.mainView];
        
        _leftLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 50, self.mainView.height)];
        self.leftLab.font = [UIFont systemFontOfSize:14.0];
        [self.mainView addSubview:self.leftLab];
        
        self.headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.mainView.width_sd - self.mainView.height_sd - 20, 0, self.mainView.height_sd - 10, self.mainView.height_sd - 10)];
        self.headerImgView.center = CGPointMake(self.headerImgView.centerX, self.mainView.height * 0.5f);
        self.headerImgView.userInteractionEnabled = YES;
        [self.mainView addSubview:self.headerImgView];
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerClick)];
        [self.headerImgView addGestureRecognizer:ges];
        
        _righttxtField = [[UITextField alloc] initWithFrame:CGRectMake(self.leftLab.right_sd - 10, 0, self.mainView.width - self.leftLab.right_sd - 20, self.mainView.height)];
        self.righttxtField.font = [UIFont systemFontOfSize:14.0];
        self.righttxtField.textAlignment = NSTextAlignmentRight;
        self.righttxtField.delegate = self;
        [self.mainView addSubview:self.righttxtField];
    }
    return self;
}


#pragma mark - event
- (void)headerClick{
    
    if ([self.delegate respondsToSelector:@selector(headerClick:)]) {
        [self.delegate headerClick:self.indexPath];
    }
}


#pragma mark - UITextField delegate
- (void)textFieldDidEndEditing:(UITextField *)textField{

    if ([self.delegate respondsToSelector:@selector(txtFieldMotto:Alias:)]) {
        
        if (self.isShowalias) {
            [self.delegate txtFieldMotto:[SYLoginInfoModel shareUserInfo].personalSpaceModel.motto Alias:textField.text];
        }
        else if (self.isShowMotto){
            [self.delegate txtFieldMotto:textField.text Alias:[SYLoginInfoModel shareUserInfo].personalSpaceModel.alias];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSLog(@"%@====%@", textField.text, string);
//    NSString *strMessage = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    if (strMessage.length >= 100) {
//        textView.text = [textView.text substringToIndex:100];
//    }
//    
//    NSString *leftNumber = [NSString stringWithFormat:@"%u",100 - textView.text.length];
//    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"还剩%@个字", leftNumber]];
//    [attStr setAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xd23023)} range:NSMakeRange(2, leftNumber.length)];
//    self.leftLetters.attributedText = attStr;
    return YES;
}

#pragma mark - public
- (void)updateLeftTitle:(NSString *)title Alias:(BOOL)isShowalias Motto:(BOOL)isShowMotto HeaderImg:(UIImage *)headerImg HeaderHidden:(BOOL)isShowHeader{
    
    self.isShowalias = isShowalias;
    self.isShowMotto = isShowMotto;
    self.righttxtField.hidden = isShowHeader;
    self.headerImgView.hidden = !isShowHeader;
    
    self.leftLab.text = title;
    if (isShowalias) {
        if ([SYLoginInfoModel shareUserInfo].personalSpaceModel.alias.length == 0) {
            NSString *userName = [SYLoginInfoModel shareUserInfo].userInfoModel.username;
            
             self.righttxtField.placeholder = [userName substringFromIndex:userName.length - 2];
        }else{
            self.righttxtField.text = [SYLoginInfoModel shareUserInfo].personalSpaceModel.alias;
        }
    }else if (isShowMotto){
        if ([SYLoginInfoModel shareUserInfo].personalSpaceModel.motto.length == 0) {
            self.righttxtField.placeholder = @"这家伙很懒，什么都没留下";
        }else{
            self.righttxtField.text = [SYLoginInfoModel shareUserInfo].personalSpaceModel.motto;
        }
    }
    
    if (headerImg) {
        self.headerImgView.image = headerImg;
    }
    else if(!isShowalias && !isShowMotto){
        [self.headerImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[SYLoginInfoModel shareUserInfo].personalSpaceModel.head_url]]  placeholderImage:[UIImage imageNamed:@"sy_navigation_normal_header"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (image) {
                [SYLoginInfoModel shareUserInfo].personalSpaceModel.headerImg = image;
                [SYLoginInfoModel saveWithSYLoginInfo];
            }
        }];
    }
}
@end
