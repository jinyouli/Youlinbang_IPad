//
//  SYTextDescriptionViewController.h
//  YLB
//
//  Created by YAYA on 2017/3/19.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseViewController.h"

typedef enum {
    functionType = 0,
    itemType
}DescriptionType;

@interface SYTextDescriptionViewController : BaseViewController

- (instancetype)initWithType:(DescriptionType)type;
@end
