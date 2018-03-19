//
//  DoorListViewController.h
//  YLB_IPAD
//
//  Created by jinyou on 2017/8/5.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    addTag = 0,
    changeTag,
    deleteTag,
    otherTag
} LockSelectTag;

@interface DoorListViewController : UIViewController

@property (nonatomic, assign) NSInteger clickIndex; //点了4个常用门禁的哪个门禁进来，用于刷新对应门禁
@property (nonatomic, assign) NSUInteger LockSelectTag;
@end
