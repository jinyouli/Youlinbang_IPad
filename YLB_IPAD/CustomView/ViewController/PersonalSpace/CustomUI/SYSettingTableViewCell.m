//
//  SYSettingTableViewCell.m
//  YLB
//
//  Created by YAYA on 2017/3/18.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYSettingTableViewCell.h"
#import "SYPersonalSpaceModel.h"

@interface SYSettingTableViewCell()

@property (nonatomic, retain) UIView *mainView;
@property (nonatomic, retain) UILabel *phoneLab;
@end

@implementation SYSettingTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIColorFromRGB(0xebebeb);
        
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (screenWidth - dockWidth) * 0.7, SYSettingTableViewCellHeight)];
        self.mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.mainView];
        
        _leftLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.mainView.width * 0.5, self.mainView.height)];
        self.leftLab.font = [UIFont systemFontOfSize:14.0];
        [self.mainView addSubview:self.leftLab];
        
        _rightSwitch = [[UISwitch alloc] init];
        self.rightSwitch.frame = CGRectMake(self.mainView.width - self.rightSwitch.width - 10, 0, self.rightSwitch.width, self.rightSwitch.height);
        [self.rightSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
        self.rightSwitch.center = CGPointMake(self.rightSwitch.centerX, self.mainView.height * 0.5f);
        [self.mainView addSubview:self.rightSwitch];
        
        UIImage *img = [UIImage imageNamed:@"sy_me_rightArrow"];
        _arrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.rightSwitch.right - img.size.width, 0, img.size.width, img.size.height)];
        self.arrowImgView.image = img;
        self.arrowImgView.center = CGPointMake(self.arrowImgView.centerX, self.mainView.height * 0.5f);
        [self.mainView addSubview:self.arrowImgView];
        
        _phoneLab = [[UILabel alloc] initWithFrame:CGRectMake(self.mainView.width * 0.5 - 10, 0, self.mainView.width * 0.5 - 10, self.mainView.height)];
        self.phoneLab.font = [UIFont systemFontOfSize:14.0];
        self.phoneLab.textAlignment = NSTextAlignmentRight;
        [self.mainView addSubview:self.phoneLab];
        
        self.otherLab = [[UILabel alloc] init];
        self.otherLab.font = [UIFont systemFontOfSize:14.0];
        self.otherLab.textAlignment = NSTextAlignmentCenter;
        self.otherLab.textColor = [UIColor redColor];
        self.otherLab.text = @"退出登录";
        self.otherLab.hidden = YES;
        [self.mainView addSubview:self.otherLab];
        
        _underLineView = [[UIView alloc] initWithFrame:CGRectMake(10, self.frame.size.height + 1, kScreenWidth - dockWidth - 10, 1)];
        _underLineView.backgroundColor = UIColorFromRGB(0xebebeb);
        _underLineView.hidden = YES;
        [self addSubview:_underLineView];
    }
    return self;
}

- (void)layoutSubviews
{
    _mainView.frame = CGRectMake(0, 0, screenWidth - dockWidth, SYSettingTableViewCellHeight);
    _underLineView.frame = CGRectMake(10, self.frame.size.height + 1, kScreenWidth - dockWidth - 10, 1);
    
    _leftLab.frame = CGRectMake(10, 0, self.mainView.width * 0.5, self.mainView.height);
    
    self.rightSwitch.frame = self.rectCell;;
    self.rightSwitch.center = CGPointMake(self.rightSwitch.centerX, self.mainView.height * 0.5f);
    
    UIImage *img = [UIImage imageNamed:@"sy_me_rightArrow"];
    _arrowImgView.frame = CGRectMake(self.rightSwitch.right - img.size.width, 0, img.size.width, img.size.height);
    self.arrowImgView.center = CGPointMake(self.arrowImgView.centerX, self.mainView.height * 0.5f);
    
    _phoneLab.frame = CGRectMake(self.mainView.width * 0.5 - 10, 0, self.mainView.width * 0.5 - 10, self.mainView.height);
    self.otherLab.frame = CGRectMake(0, 0, self.mainView.width, self.mainView.height);
}

#pragma mark - event
- (void)switchChange:(UISwitch *)switchChange{

    if ([self.delegate respondsToSelector:@selector(switchChange:)]) {
        [self.delegate switchChange:switchChange.on];
    }
}


#pragma mark - public
- (void)updateLeftInfo:(NSString *)leftInfo Type:(RightType)type{
    
    if (!leftInfo) {
        return;
    }

    self.leftLab.text = leftInfo;
    self.phoneLab.text = [SYLoginInfoModel shareUserInfo].userInfoModel.username;
    
    if (type == switchType) {
        self.rightSwitch.hidden = NO;
        self.arrowImgView.hidden = YES;
        self.phoneLab.hidden = YES;
        //self.rightSwitch.on = [SYLoginInfoModel shareUserInfo].isAllowPushMessage;
        if(iOS8_OR_LATER){

            if ([SYAppConfig shareInstance].nMessageNotificationState == 0) {
                self.rightSwitch.on = NO;
            } else if ([SYAppConfig shareInstance].nMessageNotificationState == 1){
                self.rightSwitch.on = YES;
            }
        }
    }
    else if (type == arrowType) {
        self.rightSwitch.hidden = YES;
        self.arrowImgView.hidden = NO;
        self.phoneLab.hidden = YES;
    }
    else if (type == phoneType) {
        self.rightSwitch.hidden = YES;
        self.arrowImgView.hidden = YES;
        self.phoneLab.hidden = NO;
    }
    else if (type == seitchWithSetGesturePWType){
        self.rightSwitch.hidden = NO;
        self.arrowImgView.hidden = YES;
        self.phoneLab.hidden = YES;
        self.rightSwitch.on = [SYLoginInfoModel shareUserInfo].isShowGesturePath;
    }
}
@end
