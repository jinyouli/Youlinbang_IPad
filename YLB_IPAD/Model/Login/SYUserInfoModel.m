//
//  SYUserInfoModel.m
//  YLB
//
//  Created by YAYA on 2017/4/10.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYUserInfoModel.h"
#import "MJExtension.h"

@implementation SYUserInfoModel

//MJExtension
+(NSDictionary *)mj_objectClassInArray{
    return @{
             @"neibor_id_list" : @"SYNeiborIDListModel"
             };
}

- (NSString *)description{
    //当然，如果你有兴趣知道出类名字和对象的内存地址，也可以像下面这样调用super的description方法
    //    NSString * desc = [super description];
    NSString * desc = @"\n";
    
    unsigned int outCount;
    //获取obj的属性数目
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    
    for (int i = 0; i < outCount; i ++) {
        objc_property_t property = properties[i];
        //获取property的C字符串
        const char * propName = property_getName(property);
        if (propName) {
            //获取NSString类型的property名字
            NSString    * prop = [NSString stringWithCString:propName encoding:[NSString defaultCStringEncoding]];
            //获取property对应的值
            id obj = [self valueForKey:prop];
            //将属性名和属性值拼接起来
            desc = [desc stringByAppendingFormat:@"%@ : %@;\n",prop,obj];
        }
    }
    
    free(properties);
    return desc;
}

@end
