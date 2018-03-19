//
//  SYGuardMontorView.h
//  YLB
//
//  Created by sayee on 17/4/5.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseView.h"

typedef enum : NSUInteger {
    backTag = 0,
    openLockTag,
    monitorTag
} BtnTag;

@interface SYGuardMontorView : BaseView

- (instancetype)initWithFrame:(CGRect)frame WithLockListModel:(SYLockListModel *)mode;
@end
