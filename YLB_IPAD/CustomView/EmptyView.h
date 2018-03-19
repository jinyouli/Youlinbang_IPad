//
//  EmptyView.h
//  YLB_IPAD
//
//  Created by jinyou on 2017/8/25.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmptyView : UIView

@property (nonatomic, strong) UIImageView *emptyIcon;
@property (nonatomic, strong) UILabel *lblEmpty;

- (instancetype)initWithFrame:(CGRect)frame;
@end
