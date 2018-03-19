//
//  SYBlueTeethPeripheralModel.h
//  YLB
//
//  Created by sayee on 17/6/1.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYBlueTeethPeripheralModel : NSObject
@property (nonatomic, copy) NSString *guardName; //门禁naem
@property (nonatomic, copy) NSString *RSSI; //蓝牙信号强度
@property (nonatomic, copy) NSString *UUID;
@property (nonatomic, copy) NSString *sip_number;
@property (nonatomic, copy) NSString *domain_sn;    // "10000025",
@end
