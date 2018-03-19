//
//  SYAdvertInfoListModel.h
//  YLB
//
//  Created by sayee on 17/4/1.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYAdvertInfoModel : NSObject

@property (nonatomic,copy) NSString *fredirecturl;
@property (nonatomic,copy) NSString *img_path;

@end

@interface SYAdvertInfoListModel : NSObject

@property (nonatomic,copy) NSString *fcontent;
@property (nonatomic,copy) NSString *fend_time;
@property (nonatomic,copy) NSString *fposition;
@property (nonatomic,copy) NSString *ftitle;
@property (nonatomic,copy) NSString *id;
@property (nonatomic,copy) NSArray *pic_list;

- (NSString *)description;

@end
