//
//  SYGeTuiModel.h
//  YLB
//
//  Created by YAYA on 2017/4/12.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@interface SYGeTuiCntModel : NSObject
@property (nonatomic,copy) NSString *client;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *neibor_id;
@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *repairs_id;
@end


@interface SYGeTuiModel : NSObject

@property (nonatomic,copy) NSString *ver;
@property (nonatomic,copy) NSString *typ;
@property (nonatomic,copy) NSString *cmd;
@property (nonatomic,copy) NSString *tgt;
@property (nonatomic,retain) SYGeTuiCntModel *cnt;

@end
