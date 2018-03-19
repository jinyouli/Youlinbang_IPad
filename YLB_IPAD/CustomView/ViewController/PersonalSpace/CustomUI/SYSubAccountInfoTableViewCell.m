//
//  SYSubAccountInfoTableViewCell.m
//  YLB
//
//  Created by sayee on 17/3/29.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYSubAccountInfoTableViewCell.h"
#import "SYSubAccountModel.h"

@interface SYSubAccountInfoTableViewCell()<UITextFieldDelegate>

@property (nonatomic, retain) UIView *mainView;
@property (nonatomic, retain) UILabel *leftLab;
@property (nonatomic, retain) UISwitch *rightSwitch;
@property (nonatomic, retain) UITextField *rightTxtField;

@end


@implementation SYSubAccountInfoTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIColorFromRGB(0xebebeb);
        
        self.mainView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, SYSubAccountInfoTableViewCellHeight)];
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

        self.rightTxtField = [[UITextField alloc] initWithFrame:CGRectMake(self.mainView.width * 0.5 - 10, 0, self.mainView.width * 0.5 - 10, self.mainView.height)];
        self.rightTxtField.delegate = self;
        self.rightTxtField.font = [UIFont systemFontOfSize:14.0];
        self.rightTxtField.textAlignment = NSTextAlignmentRight;
        [self.mainView addSubview:self.rightTxtField];
    }
    return self;
}


#pragma mark - event
- (void)switchChange:(UISwitch *)switchChange{
    
    if ([self.delegate respondsToSelector:@selector(switchChange:)]) {
        [self.delegate switchChange:switchChange.on];
    }
}


#pragma mark - public
- (void)updateLeftInfo:(NSString *)leftInfo Type:(RightType)type SubAccountModel:(SYSubAccountModel *)model{
    
    if (!leftInfo) {
        return;
    }
    self.rightTxtField.enabled = !self.isDelAccount;

    self.leftLab.text = leftInfo;
    self.rightTxtField.text = model.username;
    
    if (type == switchType) {
        self.rightSwitch.on = model.is_called_number;
        self.rightSwitch.hidden = NO;
        self.rightTxtField.hidden = YES;
    }
    else if (type == labelType) {
        self.rightSwitch.hidden = YES;
        self.rightTxtField.hidden = NO;
    }
    else if (type == txtFieldType) {
        self.rightSwitch.hidden = YES;
        self.rightTxtField.hidden = NO;
        self.rightTxtField.text = model.alias ? model.alias : model.username;
    }
}

- (void)updateLeftInfo:(NSString *)leftInfo RightInfo:(NSString *)rightInfo{
    
    self.leftLab.text = leftInfo;
    self.rightSwitch.hidden = YES;
    self.rightTxtField.hidden = NO;
    self.rightTxtField.text = rightInfo;
    self.rightTxtField.enabled = !self.isDelAccount;
}


#pragma mark - UITextField delegate
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if ([self.delegate respondsToSelector:@selector(nickNameChange:)]) {
        [self.delegate nickNameChange:textField.text];
    }
}
@end
