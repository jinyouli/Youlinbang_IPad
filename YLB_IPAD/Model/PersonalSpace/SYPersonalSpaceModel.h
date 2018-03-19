//
//  SYPersonalSpaceModel.h
//  YLB
//
//  Created by YAYA on 2017/4/4.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYPersonalSpaceModel : NSObject

@property (nonatomic,copy) NSString *alias; //昵称
@property (nonatomic,copy) NSString *email;
@property (nonatomic,assign) BOOL email_status; //yes 已经认证    NO没认证
@property (nonatomic,copy) NSString *end_time;  //免打扰结束时间  格式HHmm（24小时）
@property (nonatomic,copy) NSString *gesture_pwd;   //手势密码
@property (nonatomic,copy) NSString *head_url;
@property (nonatomic,copy) NSString *mobile_phone;
@property (nonatomic,copy) NSString *motto; //格言
@property (nonatomic,copy) NSString *start_time;    //免打扰开始时间  格式HHmm（24小时）

@property (nonatomic,copy) NSString *upload_token;  //七牛token

//自己加的
@property (nonatomic,retain) UIImage *headerImg;

//不需要存本地
@property (nonatomic,retain) UIImage *iconImg;
@property (nonatomic,copy) NSString *nameStr;
@end
