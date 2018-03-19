//
//  SYCustomAlertView.m
//  YLB
//
//  Created by sayee on 17/4/13.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYCustomAlertView.h"

typedef enum : NSUInteger {
    YesBtnTag,
    NoBtnTag
} BtnTag;

@interface SYCustomAlertView ()
@property (nonatomic, retain) UIView *centerView;
@property (nonatomic, retain) UIView *bgView;
@property (nonatomic, retain) UILabel *titleLab;
@end

@implementation SYCustomAlertView

- (void)dealloc{
    NSLog(@"=====SYCustomAlertView dealloc====");
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {

        self.bgView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
        self.bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [self addSubview:self.bgView];
        
        self.centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width_sd - 20 , 160)];
        self.centerView.center = CGPointMake(self.width_sd * 0.5, self.bgView.height_sd * 0.5);
        self.centerView.backgroundColor = [UIColor whiteColor];
        [self.bgView addSubview:self.centerView];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(20, self.centerView.height_sd - 50, (self.centerView.width_sd - 60) / 2, 40);
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [cancelBtn setTitle:@"返回" forState:UIControlStateNormal];
        cancelBtn.backgroundColor = UIColorFromRGB(0xd23023);
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.tag = NoBtnTag;
        [self.centerView addSubview:cancelBtn];
        
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmBtn.frame = CGRectMake(self.centerView.width_sd - cancelBtn.width_sd - 20, cancelBtn.top_sd, cancelBtn.width_sd, cancelBtn.height_sd);
        confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        confirmBtn.tag = YesBtnTag;
        confirmBtn.backgroundColor = UIColorFromRGB(0x00b300);
        [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
        [confirmBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.centerView addSubview:confirmBtn];
        
        self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.centerView.width_sd, 25)];
        self.titleLab.textAlignment = NSTextAlignmentCenter;
        self.titleLab.center = CGPointMake(self.titleLab.centerX, self.centerView.height_sd * 0.4);
        [self.centerView addSubview:self.titleLab];
    }
    return self;
}



#pragma mark - event
- (void)btnClick:(UIButton *)btn{
    
    if (btn.tag == YesBtnTag) {
        
        if (self.completeBlock) {
            self.completeBlock();
        }
    }else if (btn.tag == NoBtnTag) {

    }
    WEAK_SELF;
    [UIView animateWithDuration:0.1 animations:^{
        weakSelf.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}


#pragma mark - public
- (void)showCustomAlertViewWithTitle:(NSString *)title CompleteBlock:(CompleteBlock)block{

    self.titleLab.text = title;

    self.completeBlock = block;
}
@end
