//
//  SYTodayNewsModel.h
//  YLB
//
//  Created by YAYA on 2017/3/31.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYTodayNewsModel : NSObject

//社区头条
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *picture_url; //图标地址
@property (nonatomic,copy) NSString *news_url;  //显示内容的html地址
@property (nonatomic,copy) NSString *create_time;  //生成时间   格式yyyy-MM-dd HH:mm:ss

@end
