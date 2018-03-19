//
//  YLBDockItem.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/6/26.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "YLBDockItem.h"

@implementation YLBDockItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setTitleEdgeInsets:UIEdgeInsetsMake(50, -30, 0, 40)];
        [self setImageEdgeInsets:UIEdgeInsetsMake(20, 0, 30, -25)];
    }
    return self;
}

@end
