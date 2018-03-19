//
//  SYCanBindingModel.h
//  YLB
//
//  Created by sayee on 17/3/27.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SYNeiborIDModel

@end

@interface SYNeiborIDModel : NSObject
//判断用户是否可以绑定该小区
@property (nonatomic,copy) NSString *neighborhoods_id;
@property (nonatomic,copy) NSString *fremark; //碧桂园
@property (nonatomic,copy) NSString *faddress;  //广州市
@property (nonatomic,copy) NSString *fneibname;  //碧桂园
@property (nonatomic,copy) NSString *department_id;
@property (nonatomic,copy) NSString *fencode_key;   //卡密钥/蓝牙密钥-070310
@property (nonatomic,assign) int fopen_mode;//值为0表示密码直接开门模式，1为密码呼叫开门模式
@end

@interface SYCanBindingModel : NSObject

//判断用户是否可以绑定该小区
@property (nonatomic,strong) SYNeiborIDModel *neibor_id;  //该社区的基本信息，原来登陆接口（/users/login.json）返回的neibor_id_list不再返回，该处返回其中一个社区的信息（只有在can_bindding为true才不为空，否则为空）
@property (nonatomic,assign) BOOL can_binding;  //判断用户是否可以绑定该社区，true为可以，false为不可以
@end
