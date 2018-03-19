//
//  SYNoticeByPagerModel.h
//  YLB
//
//  Created by sayee on 17/4/7.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNoticeInfoModel : NSObject

@property (nonatomic,copy) NSString *typ;   //类型
@property (nonatomic,copy) NSString *url;   //访问地址
@end

@interface SYNoticeByPagerModel : NSObject

//使用分页获取公告信息(返回结果与时间参数获取公告一样)
@property (nonatomic,copy) NSString *content;   //内容
@property (nonatomic,copy) NSString *type;   //信息类型
@property (nonatomic,copy) NSString *url;   //信息地址
@property (nonatomic,copy) NSString *time;   //发布时间 格式：yyyy-MM-dd HH:mm:ss
@property (nonatomic,copy) NSString *issuer;   //发布人
@property (nonatomic,copy) NSString *expdate;   //截止时间 格式：yyyy-MM-dd
@property (nonatomic,copy) NSString *title;   //标题
@property (nonatomic,copy) NSString *msgID;   //信息ID
@property (nonatomic,retain) NSArray *multimedia;  //多媒体信息列表  SYNoticeInfoModel


//物业动态列表获取
@property (nonatomic,copy) NSString *fname;// "系统",//如果是回复，则显示回复者的昵称，为空表示昵称为空，其它都属于“系统”物业消息
@property (nonatomic,copy) NSString *fcreatetime;     //07-07 16:30",//时间
@property (nonatomic,copy) NSString *frepairs_id; //0000000055a0ec3d0155ba81879d0060",//工单id
@property (nonatomic,copy) NSString *fpush_type;  //0911",//个推消息类型
@property (nonatomic,copy) NSString *fcontent;    //你提交的报修单，工单号：1467712898968，由a月生无界接单处理！"//内容
@end
