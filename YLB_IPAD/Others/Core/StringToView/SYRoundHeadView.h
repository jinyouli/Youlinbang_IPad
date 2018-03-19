//
//  SYRoundHeadView.h
//  YLB
//
//  Created by chenjiangchuan on 16/11/16.
//  Copyright © 2016年 Sayee Intelligent Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYRoundHeadView : UIView

@property (nonatomic, copy) NSString *title;//需要绘制的标题
@property (nonatomic, assign) CGFloat colorPoint;//用户后面计算颜色的随机值
//设置文字  showWordLength 截取几个字
- (void)setTitle:(NSString *)title withshowWordLength:(int)showWordLength;

@end
