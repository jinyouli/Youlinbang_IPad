//
//  EmptyView.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/8/25.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "EmptyView.h"

@implementation EmptyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.backgroundColor = [UIColor whiteColor];
    self.emptyIcon = [[UIImageView alloc] init];
    self.emptyIcon.image = [UIImage imageNamed:@"icon_empty"];
    self.emptyIcon.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.emptyIcon];
    
    self.lblEmpty = [[UILabel alloc] init];
    self.lblEmpty.text = @"暂无更多数据";
    self.lblEmpty.font = [UIFont systemFontOfSize:14.0f];
    self.lblEmpty.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.lblEmpty];
}

- (void)layoutSubviews
{
    self.emptyIcon.frame = CGRectMake(self.frame.size.width * 0.5 - 35, self.frame.size.height * 0.5 - 50, 70, 100);
    self.lblEmpty.frame = CGRectMake(0, CGRectGetMaxY(self.emptyIcon.frame), self.frame.size.width, 50);
}

@end
