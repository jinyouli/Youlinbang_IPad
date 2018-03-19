//
//  SYNeiIPListModel.h
//  YLB
//
//  Created by sayee on 17/3/27.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNeiIPListModel : NSObject

//登陆后获取社区列表以及ip
@property (nonatomic,copy) NSString *fport;  //端口
@property (nonatomic,copy) NSString *fuser_id;  //用户id，如果不为空表示已经绑定该社区，如果为空，表示未绑定
@property (nonatomic,copy) NSString *fip; //ip
@property (nonatomic,copy) NSString *fneib_name; //社区名称
@property (nonatomic,copy) NSString *fid;  //用户绑定社区的时候使用
@property (nonatomic,copy) NSString *ffs_ip;  //房屋号   0是管理机
@property (nonatomic,copy) NSString *ffs_port; //fs端口
@property (nonatomic,copy) NSString *neibor_flag; //社区编号
@property (nonatomic,copy) NSString *fcity; //城市

@end
