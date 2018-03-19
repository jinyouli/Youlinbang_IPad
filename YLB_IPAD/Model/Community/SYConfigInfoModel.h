//
//  SYConfigInfo.h
//  YLB
//
//  Created by sayee on 17/3/27.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SipInfoModel : NSObject
@property (nonatomic,copy) NSString *sip_number;    //sip账号		字符串
@property (nonatomic,copy) NSString *sip_password;    //sip账号密码		字符串
@property (nonatomic,copy) NSString *house_id;  //房屋ID		字符串
@property (nonatomic,copy) NSString *house_number;    //房屋号		字符串
@property (nonatomic,copy) NSString *house_address; //房屋地址		字符串
@property (nonatomic,assign) BOOL is_owner;    //是否业主		布尔类型
@property (nonatomic,assign) BOOL disturbing;   //是否设置免打扰
@end


@interface SYConfigInfoModel : NSObject

//用户获取配置信息
@property (nonatomic,copy) NSString *sip_host_addr; //主机地址		字符串
@property (nonatomic,copy) NSString *sip_host_port; //端口		字符串
@property (nonatomic,strong) NSMutableArray *sipInfoList;  //sip账号集合		集合<SipInfo>
@property (nonatomic,copy) NSArray *tagList;   //个推标签集合		集合<String>
@property (nonatomic,assign) int registrationTimeout;   //时间间隔		int	 	默认返回600
@property (nonatomic,copy) NSString *transport;    //协议		String
@property (nonatomic,copy) NSString *iosIsShow; //是否显示升级模块		String	 	IOS审核专用，0 表示不显示，1表示显示

@end
