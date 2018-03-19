//
//  SYRandomPWModel.h
//  YLB
//
//  Created by YAYA on 2017/4/9.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYRandomPWModel : NSObject

//随机密码获取
@property (nonatomic,copy) NSString *random_pw;   //随机密码
@property (nonatomic,copy) NSString *randomkey_dead_time;   ///随机密码过期时间戳（秒）

//祈福密码获取
@property (nonatomic,copy) NSString *tpassword;   //随机密码
@property (nonatomic,copy) NSString *tdead_time;   ///随机密码过期时间戳（秒）
@end
