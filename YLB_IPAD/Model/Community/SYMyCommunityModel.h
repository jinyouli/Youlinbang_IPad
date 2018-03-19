//
//  SYMyCommunityModel.h
//  YLB
//
//  Created by sayee on 17/4/1.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYMyCommunityHTMLModel : NSObject
@property (nonatomic,copy) NSString *fheadline;   //标题名
@property (nonatomic,copy) NSString *ficon;   //图标
@property (nonatomic,copy) NSString *fhtml_url; //网页链接
@end

@interface SYNeighborMsgModel : NSObject
@property (nonatomic,copy) NSString *faddress;   //地址
@property (nonatomic,copy) NSString *fneibname;   //小区名
@property (nonatomic,copy) NSString *ftel; //小区电话
@end

@interface SYImagpathModel : NSObject
@property (nonatomic,copy) NSString *imagpath;
@end


@interface SYMyCommunityModel : NSObject

@property (nonatomic,strong) NSArray *html_list;
@property (nonatomic,strong) NSArray *neighbor_msg_list;    //目前据说只有一个小区，所以客户端解析列表第一个数据就行了
@property (nonatomic,strong) NSArray *imag_list;   //小区信息头部图片轮播列表
@end
