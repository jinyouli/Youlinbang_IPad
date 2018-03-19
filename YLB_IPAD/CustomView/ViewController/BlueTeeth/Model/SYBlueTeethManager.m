//
//  SYBlueTeethManager.m
//  YLB
//
//  Created by sayee on 17/5/25.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYBlueTeethManager.h"
#import "SYBlueTeethPeripheralModel.h"
#import "SYCommunityHttpDAO.h"

NSString * const dfuServiceUUIDString  = @"00001530-1212-EFDE-1523-785FEABCD123";
NSString * const ANCSServiceUUIDString = @"7905F431-B5CE-4E99-A40F-4B1E122D00D0";
static NSString * const uartServiceUUIDString = @"00005359-0000-1000-8000-00805F9B34FB";//新
static NSString * const uartTXCharacteristicUUIDString = @"0000FFF6-0000-1000-8000-00805F9B34FB";//新
static NSString * const uartRXCharacteristicUUIDString = @"c7ad0002-67cb-41ca-8564-18a41668b9ef";

static SYBlueTeethManager *blueTeethManager = nil;


@interface SYBlueTeethManager() <CBCentralManagerDelegate, CBPeripheralDelegate>{
    CBUUID *UART_Service_UUID;
    CBUUID *UART_RX_Characteristic_UUID;
    CBUUID *UART_TX_Characteristic_UUID;
}

@property (nonatomic, strong) CBCentralManager *blueToothCentralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;  //用于设置连接成功的设备的委托
@property (nonatomic, strong) CBCharacteristic *txCharacteristic;

@property (nonatomic, copy) NSString *blurtoothConnectSipNumber;    //蓝牙连接的门口机的SIP账号
@property (nonatomic, copy) NSString *blurtoothConnectBluetoothKey;    //蓝牙连接的门口机的蓝牙密钥
@property (nonatomic, copy) NSString *blueTeethOrder;

@property (nonatomic, strong) NSMutableArray *peripheralArr;    //CBPeripheral
@property (nonatomic, strong) NSMutableArray *peripheralModelArr;    //存放所有搜索到的门禁   存放SYBlueTeethPeripheralModel
@property (nonatomic, assign) BOOL isStopScan;
@property (nonatomic, strong) NSMutableArray *myNeighborLockList;   //全部门禁
@property (nonatomic, assign) long long nowTime;    //用于SIP通道和接口和蓝牙开门
@end

@implementation SYBlueTeethManager

+ (SYBlueTeethManager *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blueTeethManager = [[SYBlueTeethManager alloc] init];
    });
    return blueTeethManager;
}

- (instancetype)init{
    if (self = [super init]) {
        
        self.blueToothCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.peripheralModelArr = [[NSMutableArray alloc] init];
        self.peripheralArr = [[NSMutableArray alloc] init];
        self.myNeighborLockList = [[NSMutableArray alloc] init];
        
        UART_Service_UUID = [CBUUID UUIDWithString:uartServiceUUIDString];
        UART_TX_Characteristic_UUID = [CBUUID UUIDWithString:uartTXCharacteristicUUIDString];
        UART_RX_Characteristic_UUID = [CBUUID UUIDWithString:uartRXCharacteristicUUIDString];
    }
    return self;
}


#pragma mark - private
//sip通道和接口开门
- (void)sipAndInterfaceOpenGuardDoorDomainSN:(NSString *)domain_sn SipNumber:(NSString *)sip_number{
    
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
    self.nowTime = [[NSNumber numberWithDouble:time] longLongValue]; // 将double转为long long型
    if (domain_sn) {
        [communityHttpDAO remoteUnlockWithUserName:[SYLoginInfoModel shareUserInfo].userInfoModel.username DomainSN:domain_sn WithType:@"1" WithTime:self.nowTime Succeed:^{
            
        } fail:^(NSError *error) {
            
        }];
    }
    
    //发送sip消息开锁
    NSString *username = [SYLoginInfoModel shareUserInfo].userInfoModel.username;
    NSString *domainSN = domain_sn ? domain_sn : @"000";
    NSString *message = [NSString stringWithFormat:@"{\"ver\":\"1.0\",\"typ\":\"req\",\"cmd\":\"0610\",\"tgt\":\"%@\",\"cnt\":{\"username\":\"%@\",\"type\":\"%@\",\"time\":\"%@\"}}", domainSN, username,  @"1", @(self.nowTime)];
    
    if ([[SYLinphoneManager instance] sendMessage:message withExterlBodyUrl:nil withInternalURL:nil Address:sip_number]) {

    }
}


#pragma mark - public
- (void)starScanGuard{
    [self.myNeighborLockList removeAllObjects];
    [self.myNeighborLockList addObjectsFromArray:[SYAppConfig shareInstance].myNeighborLockList];
    [self.blueToothCentralManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)stopScanGuard{
    [self.blueToothCentralManager stopScan];
    self.isStopScan = NO;
    [self.peripheralModelArr removeAllObjects];
    [self.peripheralArr removeAllObjects];
}

+ (BOOL)isBlueTeethOpen{
   return [SYBlueTeethManager shareInstance].isBlueTeethOpen;
}

- (void)connectPeripheral:(CBPeripheral *)peripheral BlueTeethPeripheralModel:(SYBlueTeethPeripheralModel *)model{
    if (!peripheral) {
        return;
    }
    [self sipAndInterfaceOpenGuardDoorDomainSN:model.domain_sn SipNumber:model.sip_number];
    self.peripheral = peripheral;
    self.blurtoothConnectSipNumber = model.sip_number;
    [self.blueToothCentralManager connectPeripheral:peripheral options:nil];
}


#pragma mark - CBCentralManagerDelegate
#pragma mark 手机蓝牙状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{

    NSLog(@"=====蓝牙状态=========%i", central.state);
    switch(central.state){
        case CBManagerStatePoweredOn:{
            self.isBlueTeethOpen = YES;
        }
            break;

        case CBManagerStatePoweredOff:{
            self.isBlueTeethOpen = NO;
            NSLog(@"=====蓝牙关闭了=========");
        }
            break;

        default:
            break;
    }
}

#pragma mark 发现周边设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{

    //过滤只留下赛翼的门口机
    if ([peripheral.name hasPrefix:@"SY"]){// && [RSSI integerValue] >= -90

        /*
         * central              中心设备
         * peripheral           外围设备
         * advertisementData    特征数据
         * RSSI                 信号强度
         */

        NSMutableString *string = [NSMutableString stringWithString:@""];
        [string appendFormat:@"NAME: %@\n"            , peripheral.name];
        [string appendFormat:@"UUID(identifier): %@\n", peripheral.identifier];
        [string appendFormat:@"RSSI: %@\n"            , RSSI];
        [string appendFormat:@"adverisement:%@\n"     , advertisementData];

        NSString *peripheralName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
        
        NSLog(@"发现外设 Peripheral Info:\n %@", string);

        for (int i = 0; i < self.myNeighborLockList.count ; i++) {

            SYLockListModel *model = [self.myNeighborLockList objectAtIndex:i];
        
            NSRange range = [peripheralName rangeOfString:@"SY_"];
            NSString *tmpSipNumber;
            if (range.location != NSNotFound) {
                tmpSipNumber = [peripheralName substringFromIndex:range.length];
            }else{
                range = [peripheralName rangeOfString:@"SY"];
                if (range.location != NSNotFound) {
                    tmpSipNumber = [peripheralName substringFromIndex:range.length];
                }
            }

            //只连接有开门权限的门禁
            if ([model.sip_number isEqualToString:tmpSipNumber]) {

                SYBlueTeethPeripheralModel *peripheralModel = [[SYBlueTeethPeripheralModel alloc] init];
                peripheralModel.guardName = model.lock_name;
                peripheralModel.RSSI = [NSString stringWithFormat:@"%@",RSSI];
                peripheralModel.UUID = [NSString stringWithFormat:@"%@",peripheral.identifier];
                peripheralModel.sip_number = model.sip_number;
                peripheralModel.domain_sn = model.domain_sn;
                
                [self.peripheralArr addObject:peripheral];
                [self.peripheralModelArr addObject:peripheralModel];
                [self.myNeighborLockList removeObjectAtIndex:i];

                break;
            }
        }
    }
    
    if (!self.isStopScan) {
        self.isStopScan = YES;
        WEAK_SELF;
        [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {

            //显示多个门禁让用户选择开哪个
            if (weakSelf.peripheralArr.count > 1) {
                if ([weakSelf.delegate respondsToSelector:@selector(blueTeethScanFinish:PeripheralModel:)]) {
                    NSArray *peripheralArrTmp = [NSArray arrayWithArray:weakSelf.peripheralArr];
                    NSArray *peripheralModelArrTmp = [NSArray arrayWithArray:weakSelf.peripheralModelArr];
                    [weakSelf.delegate blueTeethScanFinish:peripheralArrTmp PeripheralModel:peripheralModelArrTmp];
                }
            }
            else if (weakSelf.peripheralArr.count == 1) {

                weakSelf.peripheral = weakSelf.peripheralArr.firstObject;   // 对要连接的设备进行强引用，否则会报错
                SYBlueTeethPeripheralModel *peripheralModel = weakSelf.peripheralModelArr.firstObject;
                weakSelf.blurtoothConnectSipNumber = peripheralModel.sip_number;
                
                // 连接设备
                [weakSelf.blueToothCentralManager connectPeripheral:weakSelf.peripheral options:nil];
            
                [weakSelf sipAndInterfaceOpenGuardDoorDomainSN:peripheralModel.domain_sn SipNumber:peripheralModel.sip_number];
            }
            [weakSelf stopScanGuard];
        }];
    }
}

#pragma mark 连接周边设备
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"=======外设链接成功======");
    self.peripheral = peripheral;
    self.peripheral.delegate = self;
    
    /*
     * 发送蓝牙开门指令
     * 控制指令采用json字符串格式： {"t":1345730846,"d":"100000668","m":"13391072762","s":"abcdef0123456789abcdef0123456789"}  先发送!!!!!!!，门口机通过这个去断开之前的链接
     * t：时间戳
     * d：门口机sip账号
     * m：用户名
     * s：签名，签名计算方法为：md5(t+d+m+md5(key))，key为蓝牙密钥明文
     */
//    NSTimeInterval time = [[NSDate date] timeIntervalSince1970] * 1000;
//    self.nowTime = [[NSNumber numberWithDouble:time] longLongValue];
    NSString *sign = [NSString stringWithFormat:@"%lld%@%@%@",self.nowTime, self.blurtoothConnectSipNumber, [SYLoginInfoModel shareUserInfo].userInfoModel.username, [[SYAppConfig shareInstance].bindedModel.neibor_id.fencode_key md5]];
    self.blueTeethOrder = [NSString stringWithFormat:@"{\"t\":%@,\"d\":\"%@\",\"m\":\"%@\",\"s\":\"%@\"}",@(self.nowTime), self.blurtoothConnectSipNumber, [SYLoginInfoModel shareUserInfo].userInfoModel.username, [sign md5]];

    [peripheral discoverServices:@[UART_Service_UUID]];     // 开始扫描外设服务

//    for (CBService *service in peripheral.services) {
//
//        NSLog(@"Discovered service %@", service);
//    }


}

#pragma mark 连接外设断开
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"连接外设断开 %@", peripheral.name);
}


#pragma mark - CBPeripheralDelegate
#pragma mark 连接成功后，扫描到外设服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error{
    if (error) {
        NSLog(@"扫描到外设服务失败 %@ with error: %@", peripheral.name, error.localizedDescription);
        return;
    }

    for (CBService *service in peripheral.services) {

        NSLog(@"扫描到外设服务：%@", service);

        // 扫描服务的特征
        if ([service.UUID isEqual:UART_Service_UUID]){
            [peripheral discoverCharacteristics:nil forService:service];
            break;
        }
    }
}

#pragma mark 连接成功后，扫描到外设特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        NSLog(@"扫描到外设特征失败 %@ with error: %@", service.UUID, error.localizedDescription);
        return;
    }
    
    if ([service.UUID isEqual:UART_Service_UUID]) {
        
        BOOL isStar = YES;
        BOOL isStop = NO;
        int nIndex = 0;
        int nLength = 20;
        for (CBCharacteristic *characteristic in service.characteristics) {
            
            NSLog(@"扫描到服务：%@ 的特征：%@", service.UUID, characteristic.UUID);
            if ([characteristic.UUID isEqual:UART_TX_Characteristic_UUID] || [characteristic.UUID isEqual:UART_RX_Characteristic_UUID])
            {
                NSLog(@"完整指令：%@",self.blueTeethOrder);
                while (!isStop) {
                    NSString *command = nil;
                    if (isStar) {
                        command = @"!!!!!!!";
                    }
                    else{
                        if (nLength + nIndex > self.blueTeethOrder.length) {
                            nLength = self.blueTeethOrder.length - nIndex;
                        }
                        command = [self.blueTeethOrder substringWithRange:NSMakeRange(nIndex, nLength)];
                        nIndex += 20;
                    }

                    //向设备发送开锁指令
                    [self.peripheral writeValue:[command dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
                    
                    
                    if (nIndex >= self.blueTeethOrder.length) {
                        nIndex = self.blueTeethOrder.length;
                        isStop = YES;
                    }
                    isStar = NO;
                    NSLog(@"发送的指令: %@",command);
                }
                break;
            }
       
            
            
            // 获取特征的值
//            [peripheral readValueForCharacteristic:characteristic];
            
            // 搜索特征的 Descriptors
//            [peripheral discoverDescriptorsForCharacteristic:characteristic];
            
            // 连接成功，开始配对，发送第一次校验的数据，自定义方法
            // [self writeCharacteristic:peripheral characteristic:characteristic value:self.pairAuthDatas[0]];
        }
    }
}

#pragma mark 连接成功后，获取到特征的值
//- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
//    if (error) {
//        NSLog(@"获取到特征的值失败 with error: %@", error.localizedDescription);
//        return;
//    }
//
//    // value 的类型是 NSData，具体开发时，会根据外设协议制定的方式去解析数据
//    NSLog(@"获取到特征：%@ 的值：%@", characteristic.UUID, [[NSString alloc] initWithData:characteristic.value
//                                                                        encoding:NSUTF8StringEncoding]);
//}

#pragma mark 连接成功后，搜索到特征的Descriptors
//- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
//    for (CBDescriptor *descriptor in characteristic.descriptors) {
//
//        NSLog(@"搜索到特征：%@ 的 Descriptors：%@", characteristic.UUID, descriptor.UUID);
//
//        // 获取到 Descriptors 的值
//        [peripheral readValueForDescriptor:descriptor];
//    }
//}

#pragma mark 获取到 Descriptors 的值
//- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
//    // 这个 descriptor 都是对于特征的描述，一般都是字符串
//
//    NSLog(@"获取到 Descriptors：%@ 的值：%@", descriptor.UUID, descriptor.value);
//}
@end
