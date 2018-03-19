//
//  SYNeiborIDListModel.h
//  YLB
//
//  Created by sayee on 17/3/31.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYLockListModel.h"

@interface SYNeiborIDListModel : NSObject


@property (nonatomic,copy) NSString *neighborhoods_id;
@property (nonatomic,copy) NSString *fremark;    // "碧桂园",
@property (nonatomic,copy) NSString *faddress;    // "广州市",
@property (nonatomic,copy) NSString *fneibname;    // "碧桂园",
@property (nonatomic,copy) NSString *department_id;    // "40288167557b22f301557b27dcac0001",
@property (nonatomic,strong) NSArray *lock_list;
@end
