//
//  SYPhotoContainerView.h
//  YLB
//
//  Created by chenjiangchuan on 16/10/31.
//  Copyright © 2016年 Sayee Intelligent Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseView.h"
@interface SYPhotoContainerView : BaseView

@property (nonatomic, strong) NSArray *picPathStringsArray;

- (CGFloat)itemWidthForPicPathArray:(NSArray *)array;

@end
