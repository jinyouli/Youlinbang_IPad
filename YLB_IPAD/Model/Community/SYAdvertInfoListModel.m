//
//  SYAdvertInfoListModel.m
//  YLB
//
//  Created by sayee on 17/4/1.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYAdvertInfoListModel.h"
#import "MJExtension.h"

@implementation SYAdvertInfoListModel

+(NSDictionary *)mj_objectClassInArray{
    return @{
             @"pic_list" : @"SYAdvertInfoModel"
             };
}

- (NSString *)description
{
    SYAdvertInfoModel *model = self.pic_list[0];
    return [NSString stringWithFormat:@"%@,%@,%@,%@", self.ftitle,self.fcontent,model.img_path,self.fposition];
}
@end

@implementation SYAdvertInfoModel

@end
