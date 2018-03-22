//
//  SYAdpublishModel.m
//  YLB
//
//  Created by sayee on 17/8/18.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYAdpublishModel.h"
#import "MJExtension.h"
@implementation SYAdpublishModel

-(NSString *)ftitle{
    if (_ftitle == nil) {
        _ftitle = @"";
    }
    return _ftitle;
}

-(NSString *)fpictureurl{
    if (_fpictureurl == nil) {
        _fpictureurl = @"";
    }
    return _fpictureurl;
}

-(NSString *)fcreatetime{
    if (_fcreatetime == nil) {
        _fcreatetime = @"";
    }
    return _fcreatetime;
}

-(NSString *)fnewsurl{
    if (_fnewsurl == nil) {
        _fnewsurl = @"";
    }
    return _fnewsurl;
}

-(NSString *)adID{
    if (_adID == nil) {
        _adID = @"";
    }
    return _adID;
}
-(NSString *)fcontent{
    if (_fcontent == nil) {
        _fcontent = @"";
    }
    return _fcontent;
}

-(int)type{
    return _type;
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"adID":@"id"};
}

- (NSString *)description {
    return [NSString stringWithFormat:@"ftitle =%@,fpictureurl =%@,fcreatetime = %@,fnewsurl =%@,fcontent =%@", _ftitle,_fpictureurl,_fcreatetime,_fnewsurl,_fcontent];
}
@end
