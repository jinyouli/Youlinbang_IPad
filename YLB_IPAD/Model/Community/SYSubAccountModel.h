//
//  SYSubAccount.h
//  YLB
//
//  Created by sayee on 17/3/27.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYSubAccountModel : NSObject

//获取房屋子账号
@property (nonatomic,copy) NSString *username;  //用户名
@property (nonatomic,copy) NSString *mobile_phone;  //手机号
@property (nonatomic,copy) NSString *alias; //别名
@property (nonatomic,assign) BOOL is_called_number; //是否被叫号码


//设备获取属下房屋信息
@property (nonatomic,copy) NSString *house_id;  //房屋ID
@property (nonatomic,copy) NSString *house_number;  //房屋号   0是管理机
@property (nonatomic,copy) NSString *house_password; //开门密码
@property (nonatomic,copy) NSString *sip_number; //SIP账号
@end
