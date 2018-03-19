//
//  SYUserExistModel.h
//  YLB
//
//  Created by YAYA on 2017/4/19.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYUserExistModel : NSObject

@property (nonatomic,assign) BOOL isusername_existed;    // 用户名是否存在
@property (nonatomic,assign) BOOL isphone_existed;    // 手机号是否存在
@property (nonatomic,assign) BOOL isemail_existed;    // email是否存在
@end
