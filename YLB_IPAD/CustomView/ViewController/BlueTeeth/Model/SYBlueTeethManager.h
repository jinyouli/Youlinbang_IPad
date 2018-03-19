//
//  SYBlueTeethManager.h
//  YLB
//
//  Created by sayee on 17/5/25.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class SYBlueTeethPeripheralModel;

@protocol SYBlueTeethManagerDelegate <NSObject>

- (void)blueTeethScanFinish:(NSArray *)peripheralArr PeripheralModel:(NSArray *)peripheralModelArr;   //扫描完毕，返回符合规定的外围设备（也就是门禁列表）

@end

@interface SYBlueTeethManager : NSObject

@property (nonatomic, assign) BOOL isBlueTeethOpen;
@property (nonatomic, assign) id<SYBlueTeethManagerDelegate> delegate;

+ (SYBlueTeethManager *)shareInstance;
- (void)starScanGuard;
- (void)stopScanGuard;
- (void)connectPeripheral:(CBPeripheral *)peripheral BlueTeethPeripheralModel:(SYBlueTeethPeripheralModel *)model;
+ (BOOL)isBlueTeethOpen;
@end
