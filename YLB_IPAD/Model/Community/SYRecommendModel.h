//
//  SYRecommendModel.h
//  YLB_IPAD
//
//  Created by jinyou on 2017/8/14.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYRecommendModel : NSObject

@property (nonatomic,copy) NSString *ftitle; //标题
@property (nonatomic,copy) NSString *fpictureurl; //图片地址
@property (nonatomic,copy) NSString *fcreatetime; //时间
@property (nonatomic,copy) NSString *fnewsurl; //外链
@property (nonatomic,copy) NSString *id; //id
@property (nonatomic,copy) NSString *fcontent; //内容
@property (nonatomic,copy) NSString *type; //类型，1为手机端广告资讯，2为社区头条

@end
