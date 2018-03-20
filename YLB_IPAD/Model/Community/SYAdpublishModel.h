//
//  SYAdpublishModel.h
//  YLB
//
//  Created by sayee on 17/8/18.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>
//推荐
@interface SYAdpublishModel : NSObject

@property (nonatomic,copy) NSString *ftitle;      //  //标题
@property (nonatomic,copy) NSString *fpictureurl;      // //图片地址
@property (nonatomic,copy) NSString *fcreatetime;      // //时间
@property (nonatomic,copy) NSString *fnewsurl;      ////外链
@property (nonatomic,copy) NSString *adID;       //id
@property (nonatomic,copy) NSString *fcontent;      //内容
@property (nonatomic,assign) int type;      //类型，1为手机端广告资讯，2为社区头条
@end
