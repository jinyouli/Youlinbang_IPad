//
//  SYAppConfig.m
//  YLB
//
//  Created by YAYA on 2017/3/13.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYAppConfig.h"
#import <Security/Security.h>
#import <AVFoundation/AVFoundation.h>
#import "MJExtension.h"
#import "SYCanBindingModel.h"

#define KEY_UUID  @"com.gdsayee.ylb.release.app.uuid"

#define UserDefaultPortTypeKey  @"ylb_UserDefaultPortTypeKey"
//#define UserDefaultMyNeighborLockListKey  @"ylb_myNeighborLockList" //所有门禁    用于被呼叫时的开锁
#define UserDefaultMyHistoryNeighborLockList @"ylb_HistoryNeighborLockList" //本机选择过的全部门禁列表，切换社区后，保留前一个社区的已选择的门禁列表

//dic: key:userid value: 数组{  key:社区ID value:选择门禁的列表}
#define UserDefaultMyiHistoreNeighborLockListKey  @"ylb_myHistoryNeighborLockList" //所有选择的门禁    记录不同账号选择了哪些门禁（在本机切换过的所有社区的以选择的门禁）
static SYAppConfig *appConfig = nil;

@interface SYAppConfig()
@property (nonatomic, strong) NSMutableArray *userLoginInfoArray;   //账号，密码，绑定社区和选择的门禁

@end

@implementation SYAppConfig

+ (SYAppConfig *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appConfig = [[SYAppConfig alloc] init];
        NSString *strIP = [[NSUserDefaults standardUserDefaults] objectForKey:@"base_url"];
        if (!strIP) {
            appConfig.base_url = @"https://api.sayee.cn:28084";
        }else{
            appConfig.base_url = strIP;
        }
    });
    return appConfig;
}

- (instancetype)init{
    if (self = [super init]) {

        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        //=====历史账号和密码====
        _userLoginInfoArray = [[NSMutableArray alloc] init];
        
        NSArray *array = [userDefault objectForKey:UserDefaultUserNameKey];
        if ([array isKindOfClass:[NSArray class]] && array.count > 0) {
            [_userLoginInfoArray addObjectsFromArray:array];
        }
        self.selectedGuardMArr = [[NSMutableArray alloc] init];
        
        //====扬声器或者听筒===
        NSNumber *portType = [userDefault objectForKey:UserDefaultPortTypeKey];
        //默认扬声器
        if (!portType) {
            self.isSpeaker = YES;
        }
        else if([portType isKindOfClass:[NSNumber class]]){
            self.isSpeaker = [portType boolValue];
        }
    
        
        //======全部门禁列表======
        self.myNeighborLockList = [[NSMutableArray alloc] init];
//        id personalSpaceModelData = [userDefault objectForKey:UserDefaultMyNeighborLockListKey];
//        if (personalSpaceModelData) {
//            self.myNeighborLockList = [NSKeyedUnarchiver unarchiveObjectWithData:personalSpaceModelData];
//        }

    }
    return self;
}

- (void)setIsSpeaker:(BOOL)isSpeaker{
    _isSpeaker = isSpeaker;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:_isSpeaker forKey:UserDefaultPortTypeKey];
    [userDefault synchronize];
}


#pragma mark - public
+ (NSString *)syUUID{
    
    NSString *uuidString = [[self class] loadKeyChainUUID:KEY_UUID];
    
    if (![uuidString isKindOfClass:[NSString class]]) {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        CFStringRef strUUID =  CFUUIDCreateString(NULL, uuid);
        uuidString = [(__bridge NSString*)strUUID stringByReplacingOccurrencesOfString:@"-" withString:@""];
        CFRelease(uuid);
        CFRelease(strUUID);
        
        if (uuidString) {
            [[self class] saveKeyChainUUID:KEY_UUID data:uuidString];
        }
    }
    return uuidString;
}

+ (NSString *)baseURL{
    
    //return @"https://gdsayee.cn:28084";
    //@"https://api.sayee.cn:28084";
    //@"https://gdsayee.cn:28884";
    
    
    return [[self class] shareInstance].base_url;
}

//所有门禁
//+ (void)saveMyNeighborList{
//    
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    NSData *personalSpaceModelData = [NSKeyedArchiver archivedDataWithRootObject:appConfig.myNeighborLockList];
//    [userDefault setObject:personalSpaceModelData forKey:UserDefaultMyNeighborLockListKey];
//    [userDefault synchronize];
//}


//======登录过的历史账号信息===========
+ (NSArray *)getUserLoginInfoAccountAndPassword{

    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *array = [userDefault objectForKey:UserDefaultUserNameKey];
    
    NSMutableArray *arrTmp = [[NSMutableArray alloc] init];
    
    if ([array isKindOfClass:[NSArray class]] && array.count > 0) {
        
        [array enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSMutableDictionary *infoDic = dic.allValues.firstObject;
            NSString *password = [infoDic objectForKey:@"password"];
            NSString *account = [infoDic objectForKey:@"account"];
            NSDictionary *dicTmp = [NSDictionary dictionaryWithObjectsAndKeys:(password ? : @""), (account ? : @""),  nil];
            [arrTmp addObject:dicTmp];
        }];
    }
    return arrTmp;
}

+ (BOOL)getUserLoginInfoWithUserID:(unsigned long)userID{

//    if (![SYLoginInfoModel isLogin]) {
//        return NO;
//    }
    
    __block BOOL isHasLocalAccount;
    
    if (userID <= 0) {
        return isHasLocalAccount;
    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *array = [userDefault objectForKey:UserDefaultUserNameKey];
    if ([array isKindOfClass:[NSArray class]] && array.count > 0) {
    
        [array enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSArray *arr = dic.allKeys;
            NSString *userIDTmp;
            if (arr.count > 0) {
                userIDTmp = arr.firstObject;
            }
            if ([userIDTmp isEqualToString:[NSString stringWithFormat:@"%li",userID]]) {
            
                NSMutableDictionary *infoDic = dic.allValues.firstObject;
                SYCanBindingModel *bindedModel = [SYCanBindingModel mj_objectWithKeyValues:[infoDic objectForKey:@"canBindingModel"]];
                
                [SYAppConfig shareInstance].bindedModel = bindedModel;
                [SYAppConfig shareInstance].password = [infoDic objectForKey:@"password"];
                [SYAppConfig shareInstance].account = [infoDic objectForKey:@"account"];
                [SYAppConfig shareInstance].secondPlatformIPStr = [infoDic objectForKey:@"secondPlatformIPStr"];
                
                
                if (![SYAppConfig shareInstance].selectedGuardMArr) {
                    [SYAppConfig shareInstance].selectedGuardMArr = [[NSMutableArray alloc] init];
                }
                                
                //选择的门禁
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                NSDictionary *dicMain = [userDefault objectForKey:UserDefaultMyiHistoreNeighborLockListKey];
                if ([dicMain isKindOfClass:[NSDictionary class]]) {
                    NSMutableArray *neithborArr = [dicMain objectForKey:[NSString stringWithFormat:@"%li",[SYLoginInfoModel shareUserInfo].userInfoModel.user_id]];
                    BOOL isFind = NO;
                    for (NSDictionary *dic in neithborArr) {
                        
                        for (NSString *neighborID in dic.allKeys) {
                            if ([neighborID isEqualToString:bindedModel.neibor_id.neighborhoods_id]) {
                                NSData *selectedGuardData = [dic objectForKey:neighborID];
                                NSMutableArray *arrGuard = nil;
                                if (selectedGuardData) {
                                    arrGuard = [NSKeyedUnarchiver unarchiveObjectWithData:selectedGuardData];
                                    [[SYAppConfig shareInstance].selectedGuardMArr removeAllObjects];
                                    [[SYAppConfig shareInstance].selectedGuardMArr addObjectsFromArray:arrGuard];
                                }
                                isFind = YES;
                                break;
                            }
                        }
                        if (isFind) {
                            break;
                        }
                    }
                }
                else{
                    //兼容旧的
                    id data = [infoDic objectForKey:@"selectedGuardArr"];
                    NSMutableArray *arr = nil;
                    if (data) {
                        arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    }
                    if (arr) {
                        [[SYAppConfig shareInstance].selectedGuardMArr removeAllObjects];
                        [[SYAppConfig shareInstance].selectedGuardMArr addObjectsFromArray:arr];
                    }
                    [SYAppConfig saveMyHistoryNeighborLockList];
                }
                isHasLocalAccount = YES;
                *stop = YES;
            }
        }];
    }
    return isHasLocalAccount;
}

+ (void)saveUserLoginInfo{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    @synchronized (appConfig.userLoginInfoArray) {

        NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
        if (appConfig.account != nil) {
            [tmpDic setValue:appConfig.account forKey:@"account"];
        }
        if (appConfig.password != nil) {
            [tmpDic setValue:appConfig.password forKey:@"password"];
        }

        NSDictionary *configInfoModelDic = appConfig.bindedModel.mj_keyValues;
        if (configInfoModelDic != nil) {
            [tmpDic setValue:configInfoModelDic forKey:@"canBindingModel"];
        }
        if (appConfig.secondPlatformIPStr != nil) {
            [tmpDic setValue:appConfig.secondPlatformIPStr forKey:@"secondPlatformIPStr"];
        }
        
        NSMutableDictionary *userDic = [[NSMutableDictionary alloc] init];
        [userDic setObject:tmpDic forKey:[NSString stringWithFormat:@"%li",[SYLoginInfoModel shareUserInfo].userInfoModel.user_id]];
        
        __block int nHasOldIndex = -1;
        //替换原先旧的
        NSArray *arr = [NSArray arrayWithArray:appConfig.userLoginInfoArray];
        [arr enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {

            NSArray *arr = dic.allKeys;
            NSString *userID;
            if (arr.count > 0) {
                userID = arr.firstObject;
            }
            if ([userID isEqualToString:[NSString stringWithFormat:@"%li",[SYLoginInfoModel shareUserInfo].userInfoModel.user_id]]) {
                nHasOldIndex = idx;
                *stop = YES;
            }
        }];
        
        if (nHasOldIndex >= 0) {
            [appConfig.userLoginInfoArray removeObjectAtIndex:nHasOldIndex];
            [appConfig.userLoginInfoArray insertObject:userDic atIndex:0];
        }
        else{
            [appConfig.userLoginInfoArray addObject:userDic];
        }
    }

    [userDefault setObject:appConfig.userLoginInfoArray forKey:UserDefaultUserNameKey];
    [userDefault synchronize];
}

//在本机切换过的所有社区的以选择的门禁
+ (void)saveMyHistoryNeighborLockList{

    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *dicTmp = [userDefault objectForKey:UserDefaultMyiHistoreNeighborLockListKey];
    NSMutableDictionary *dicMain = [[NSMutableDictionary alloc] initWithDictionary:dicTmp];

    NSArray *arr = [dicMain objectForKey:[NSString stringWithFormat:@"%li",[SYLoginInfoModel shareUserInfo].userInfoModel.user_id]];
    if (arr.count == 0) {
        
        NSMutableArray *neithborArr = [[NSMutableArray alloc] init];
        NSMutableDictionary *dicHistorySelectedGuardInfo = [[NSMutableDictionary alloc] init];
        //本机选择过的门禁 dic: key:社区ID value:选择门禁的列表
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:appConfig.selectedGuardMArr];
        if (data != nil) {
            if ([SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id) {
                [dicHistorySelectedGuardInfo setValue:data forKey:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id];
            }
        }
        [neithborArr addObject:dicHistorySelectedGuardInfo];
        [dicMain setObject:neithborArr forKey:[NSString stringWithFormat:@"%li",[SYLoginInfoModel shareUserInfo].userInfoModel.user_id]];
    }
    else{
        
        NSMutableArray *neithborArr = [[NSMutableArray alloc] initWithArray:arr];
        BOOL isFind = NO;
        
        for (int i = 0; i < neithborArr.count ; i++) {
            NSDictionary *dic = [neithborArr objectAtIndex:i];
            
            for (NSString *neighborID in dic.allKeys) {
                if ([neighborID isEqualToString:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id]) {
                    
                    NSMutableDictionary *dicHistorySelectedGuardInfo = [[NSMutableDictionary alloc] init];
                    //本机选择过的门禁 dic: key:社区ID value:选择门禁的列表
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:appConfig.selectedGuardMArr];
                    if (data != nil) {
                        if ([SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id) {
                            [dicHistorySelectedGuardInfo setValue:data forKey:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id];
                        }
                    }
                    [neithborArr removeObjectAtIndex:i];
                    [neithborArr addObject:dicHistorySelectedGuardInfo];
                    
                    [dicMain setObject:neithborArr forKey:[NSString stringWithFormat:@"%li",[SYLoginInfoModel shareUserInfo].userInfoModel.user_id]];
                    
                    isFind = YES;
                    break;
                }
            }
            if (isFind) {
                break;
            }
        }
        
        if (!isFind) {

            NSMutableDictionary *dicHistorySelectedGuardInfo = [[NSMutableDictionary alloc] init];
            //本机选择过的门禁 dic: key:社区ID value:选择门禁的列表
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:appConfig.selectedGuardMArr];
            if (data != nil) {
                if ([SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id) {
                    [dicHistorySelectedGuardInfo setValue:data forKey:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id];
                }
            }
            [neithborArr addObject:dicHistorySelectedGuardInfo];
            [dicMain setObject:neithborArr forKey:[NSString stringWithFormat:@"%li",[SYLoginInfoModel shareUserInfo].userInfoModel.user_id]];
        }
    }

    [userDefault setObject:dicMain forKey:UserDefaultMyiHistoreNeighborLockListKey];
    [userDefault synchronize];
}

//扬声器
+ (BOOL)isSpeaker{
    return [[self class] shareInstance].isSpeaker;
}

//sip是否登录
+ (BOOL)isSipLogined{
    return [[self class] shareInstance].isSipLogined;
}

+ (NSString *)appVersion{
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* versionStr = [infoDict objectForKey:@"CFBundleShortVersionString"];
    return versionStr;
}

//app name
+ (NSString *)appDisplayName{
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* displayName = [infoDict objectForKey:@"CFBundleDisplayName"];
    return displayName;
}

+ (BOOL)isShowNewFeature{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastVersion = [defaults objectForKey:NewFeatureVersionKey];
    if (!lastVersion){
        [defaults setObject:[SYAppConfig appVersion] forKey:NewFeatureVersionKey];
        [defaults synchronize];
        return YES;
    }
    return NO;
//    if (lastVersion && [lastVersion isEqualToString:[SYAppConfig appVersion]]) {
//        return NO;
//    }
//    [defaults setObject:[SYAppConfig appVersion] forKey:NewFeatureVersionKey];
//    [defaults synchronize];
//    return YES;
}

//是否全部都是空格
+ (BOOL)contactIsEmpty:(NSString *) str {
    
    if (!str) {
        return true;
    } else {
        //A character set containing only the whitespace characters space (U+0020) and tab (U+0009) and the newline and nextline characters (U+000A–U+000D, U+0085).
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        //Returns a new string made by removing from both ends of the receiver characters contained in a given character set.
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0) {
            return YES;
        } else {
            return NO;
        }
    }
}

//网络状态
+ (SYConnectivityState)networkState{
    return [SYAppConfig shareInstance].networkState;
}

+ (BOOL)isPlayingSipVideo{
    return [SYAppConfig shareInstance].isPlayingSipVideo;
}

+ (NSString *)guardDisplayName{
    return [SYAppConfig shareInstance].guardDisplayName;
}


#pragma mark - private

#pragma mark - keychain
+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}

+ (void)saveKeyChainUUID:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

+ (id)loadKeyChainUUID:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

+ (void)deleteKeyChainUUID:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

@end
