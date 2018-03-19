//
//  SYAppManageListModel.h
//  YLB
//
//  Created by sayee on 17/4/7.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYAppManageListModel : NSObject

//获取APP应用列表
@property (nonatomic,copy) NSString *ficon_url;   //图标
@property (nonatomic,copy) NSString *app_url;   //下载路径
@property (nonatomic,copy) NSString *fversiondes;   //版本描述
@property (nonatomic,copy) NSString *fapp_name;   //app名称
@property (nonatomic,copy) NSString *fversioncode;   //版本号
@property (nonatomic,assign) long long fappsize;   //大小
@property (nonatomic,copy) NSString *fversionname;   //版本名称
@property (nonatomic,copy) NSString *fpackagename;   //包名

@end
