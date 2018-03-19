//
//  YLBDock.h
//  YLB_IPAD
//
//  Created by jinyou on 2017/6/26.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DockDelegate
- (void)touchButton:(NSInteger)tagNum;
@end

@interface YLBDock : UIView
{
    id<DockDelegate> delegate;
}

@property (nonatomic,strong) UIButton *buttn;
@property (nonatomic,strong) UIImageView *headImage;
@property (nonatomic,strong) UILabel *nickName;
@property (nonatomic,strong) NSMutableArray *arrayButtons;

@property (nonatomic, weak) id<DockDelegate> delgeate;
@end
