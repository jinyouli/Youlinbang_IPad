//
//  AppDelegate.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/6/26.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "MainViewController.h"
#import "HomePageViewController.h"
#import "GeTuiSdk.h"
#import <AVFoundation/AVFoundation.h>
#import "SYInComingCallViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"
#import "WeiboSDK.h"

@interface AppDelegate ()<UIApplicationDelegate, GeTuiSdkDelegate,UNUserNotificationCenterDelegate,SYLinphoneDelegate,WXApiDelegate, QQApiInterfaceDelegate,WeiboSDKDelegate>{
    dispatch_source_t _timer;
    dispatch_source_t vcTimer;//当APP进入前台后，是否显示手势解锁页面倒计时
}

@property (nonatomic,assign) SYLinphoneCall *currentCall;
@property (nonatomic,assign) BOOL isShowSYGestureUnlockViewController;  //当APP进入前台后，是否显示手势解锁页面
@property (nonatomic,assign) BOOL isDismissInComingCallVC;  //是否删除呼叫页面  (正在监控视频时，有门口机呼进来，则删除通话中的视频通话，不能删除呼叫页面)
@property (nonatomic,retain) AVAudioPlayer *audioPlayer ; //用于后台常驻 播放无声音频
@property (nonatomic,assign) BOOL isCallComing; //只显示一个门口机呼过来页面
@property (nonatomic,strong) TencentOAuth *tencentOAuth;

@property (nonatomic,assign) BOOL isPresentSecond;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"QRcode"];
    
    self.isPresentSecond = NO;
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"base_url"]){
        [[NSUserDefaults standardUserDefaults] setObject:@"https://api.sayee.cn:28084" forKey:@"base_url"];
        [SYAppConfig shareInstance].base_url = @"https://api.sayee.cn:28084";
    }
    
    MainViewController *firstVC = [[MainViewController alloc] init];

    [self.window setRootViewController:firstVC];
    [self.window makeKeyAndVisible];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"QRcode"];
    
    //注册QQ分享
    self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAppID andDelegate:nil];
    
    //注册微信分享
    [WXApi registerApp:WXAppID];
    
    //注册微博分享
    [WeiboSDK registerApp:SinaAppKey];
    
    // 通过个推平台分配的appId、 appKey 、appSecret 启动SDK，注：该方法需要在主线程中调用
    [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];
    // 注册 APNs
    [self registerRemoteNotification];
    
    [self configLinphone];
    
    NSString *isAllowNoDusturbMode = [[NSUserDefaults standardUserDefaults] objectForKey:@"isAllowNoDusturbMode"];
    NSString *isAllowHardDusturbMode = [[NSUserDefaults standardUserDefaults] objectForKey:@"isAllowHardDusturbMode"];
    
    if ([isAllowNoDusturbMode isEqualToString:@"YES"]) {
        [SYLoginInfoModel shareUserInfo].isAllowNoDusturbMode = YES;
    }else{
        [SYLoginInfoModel shareUserInfo].isAllowNoDusturbMode = NO;
    }
    
    if ([isAllowHardDusturbMode isEqualToString:@"YES"]) {
        [SYLoginInfoModel shareUserInfo].isAllowHardDusturbMode = YES;
    }else{
        [SYLoginInfoModel shareUserInfo].isAllowHardDusturbMode = NO;
    }
    
    [SYLoginInfoModel shareUserInfo].personalSpaceModel.start_time = @"2200";
    [SYLoginInfoModel shareUserInfo].personalSpaceModel.end_time = @"0600";
    
    [self configGeTui];//注册个推
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [self registerUserNotification];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self updateNotificationCenter];
    
//    [[SYLinphoneManager instance] resignActive];
//    [[SYLinphoneManager instance] resumeCall];
//    [[SYLinphoneManager instance] becomeActive];
}

- (void)updateNotificationCenter{
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            [SYAppConfig shareInstance].nMessageNotificationState = settings.notificationCenterSetting;
        }];
    } else if (isAfteriOS8) {
        UIUserNotificationSettings *userNotificationSetting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if( userNotificationSetting.types == UIUserNotificationTypeNone )
        {
            [SYAppConfig shareInstance].nMessageNotificationState = NO;
        }else{
            [SYAppConfig shareInstance].nMessageNotificationState = YES;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_MESSAGE_NOTIFICATION_CHANGE object:nil userInfo:nil];
}

// 注册本地推送
- (void)registerUserNotification {
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (granted) {
                NSLog(@"本地推送注册成功");
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"本地推送 settings = %@", settings);
                }];
            } else {
                NSLog(@"本地推送注册失败");
            }
        }];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else if (isAfteriOS8) {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}


//====分享到其他APP====
//被废弃的方法. 但是在低版本中会用到.建议写上
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if([[url description] hasPrefix:@"tencent"] || [[url description] hasPrefix:@"QQ"]) {
        return [QQApiInterface handleOpenURL:url delegate:self] || [TencentOAuth HandleOpenURL:url];
    }
    else {
        if ([[url description] hasPrefix:@"wx"]) {
            return [WXApi handleOpenURL:url delegate:self];
        }
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
}
//被废弃的方法. 但是在低版本中会用到.建议写上
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if([[url description] hasPrefix:@"tencent"] || [[url description] hasPrefix:@"QQ"]) {
        return [QQApiInterface handleOpenURL:url delegate:self] || [TencentOAuth HandleOpenURL:url];
    }
    else {
        if ([[url description] hasPrefix:@"wx"]) {
            return [WXApi handleOpenURL:url delegate:self];
        }
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    if([[url description] hasPrefix:@"tencent"] || [[url description] hasPrefix:@"QQ"]) {
        return [QQApiInterface handleOpenURL:url delegate:self] || [TencentOAuth HandleOpenURL:url];
    }
    else {
        if ([[url description] hasPrefix:@"wx"]) {
            return [WXApi handleOpenURL:url delegate:self];
        }
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
}


- (void)openGesture
{
    LAContext *context = [[LAContext alloc] init];
    //检查Touch ID是否可用
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"验证touchID" reply:^(BOOL success, NSError *error) {
            
            if (success) {
                NSLog(@"指纹开锁成功");
                dispatch_async(dispatch_get_main_queue(), ^{

                });
            } else {
                if (error.code == -2) {
                    //点击取消
                    return;
                }else if(error.code == -3){
                    //点击输入密码
                    return;
                }else if(error.code == -8){
                    NSLog(@"Touch ID功能被锁定，下一次需要输入系统密码");
                    return;
                }
                NSLog(@"验证错误==%@",[NSString stringWithFormat:@"%@",error]);
                [Common showAlert:@"TouchID验证失败"];
            }
        }];
    } else {
        [Common showAlert:@"指纹开锁设备不支持"];
    }
}

//====个推 初始化=====
- (void)configGeTui{
    
    [GeTuiSdk runBackgroundEnable:[SYLoginInfoModel shareUserInfo].isAllowPushMessage]; // 是否允许APP后台运行
    
    // 使用APPID/APPKEY/APPSECRENT启动个推
    [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];
    [GeTuiSdk resetBadge];
    
    [GeTuiSdk setPushModeForOff:NO];
}

/** 注册 APNs */
- (void)registerRemoteNotification {
    /*
     警告：Xcode8 需要手动开启"TARGETS -> Capabilities -> Push Notifications"
     */
    
    /*
     警告：该方法需要开发者自定义，以下代码根据 APP 支持的 iOS 系统不同，代码可以对应修改。
     以下为演示代码，注意根据实际需要修改，注意测试支持的 iOS 系统都能获取到 DeviceToken
     */
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0 // Xcode 8编译会调用
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
            }
        }];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
#else // Xcode 7编译会调用
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#endif
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert |
                                                                       UIRemoteNotificationTypeSound |
                                                                       UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
}

/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"\n>>>[DeviceToken Success]:%@\n\n", token);
    
    // 向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:token];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    /// Background Fetch 恢复SDK 运行
    [GeTuiSdk resume];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // 将收到的APNs信息传给个推统计
    
    [GeTuiSdk handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

//  iOS 10: App在前台获取到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    NSLog(@"willPresentNotification：%@", notification.request.content.userInfo);
    
    // 根据APP需要，判断是否要提示用户Badge、Sound、Alert
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

//  iOS 10: 点击通知进入App时触发，在该方法内统计有效用户点击数
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSLog(@"didReceiveNotification：%@", response.notification.request.content.userInfo);
    
    // [ GTSdk ]：将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:response.notification.request.content.userInfo];
    
    completionHandler();
}

#endif

/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    //个推SDK已注册，返回clientId
    NSLog(@"\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
    [[NSUserDefaults standardUserDefaults] setObject:clientId forKey:@"clientId"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"successClientID" object:nil];
    
    [SYLoginInfoModel shareUserInfo].geTuiClientID = clientId;
    [self loadConfigInfo];
}

- (void)loadConfigInfo
{
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    // 用户获取配置信息获取房产列表（房产管理）
    [communityHttpDAO getMyConfigInfoWithNeigborID:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username Succeed:^(SYConfigInfoModel *configInfo) {
        
        [SYLoginInfoModel shareUserInfo].configInfoModel = configInfo;
        
        [SYLoginInfoModel shareUserInfo].configInfoModel.tagList = configInfo.tagList;
        [SYLoginInfoModel saveWithSYLoginInfo];

        [self saveClientID];
    } fail:^(NSError *error) {
        //[Common showAlert:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
    }];
}

- (void)saveClientID
{
    if ([SYLoginInfoModel shareUserInfo].geTuiClientID) {
        
        SYLoginHttpDAO *login = [[SYLoginHttpDAO alloc] init];
        [login saveTagCidWithTagJson:[[SYLoginInfoModel shareUserInfo].configInfoModel.tagList mj_JSONString] WithCid:[SYLoginInfoModel shareUserInfo].geTuiClientID cidType:7 Succeed:^{
            
        } fail:^(NSError *error) {
            [Common showAlert:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
        }];
    }
}

/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    //个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    NSLog(@"\n>>>[GexinSdk error]:%@\n\n", [error localizedDescription]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

}

#pragma mark - linphone 初始化
- (void)configLinphone{
    
    [[SYLinphoneManager instance] startSYLinphonephone];
    [SYLinphoneManager instance].nExpires = [SYLoginInfoModel shareUserInfo].userInfoModel.registrationTimeout * 60 > 0 ? [SYLoginInfoModel shareUserInfo].userInfoModel.registrationTimeout * 60 : 120 * 60;
    [SYLinphoneManager instance].ipv6Enabled = NO;
    [SYLinphoneManager instance].videoEnable = YES;
    [[SYLinphoneManager instance] setDelegate:self];
}

#pragma mark - delegate
#pragma mark - linphone delegate
- (void)onRegisterStateChange:(SYLinphoneRegistrationState)state message:(const char *)message{
    
    [SYAppConfig shareInstance].isSipLogined = NO;
    switch (state) {
        case SYLinphoneRegistrationNone:{
            NSLog(@"====LinphoneRegistrationNone===%s",message);
            break;
        }
            
        case SYLinphoneRegistrationProgress: {
            NSLog(@"====LinphoneRegistrationProgress======");
            break;
        }
            
        case SYLinphoneRegistrationOk: {
            NSLog(@"====LinphoneRegistrationOk======");
            [SYAppConfig shareInstance].isSipLogined = YES;
            break;
        }
            
        case SYLinphoneRegistrationCleared:{
            NSLog(@"====LinphoneRegistrationCleared===");
            break;
        }
        case SYLinphoneRegistrationFailed: {
            NSLog(@"====LinphoneRegistrationFailed=====");
            break;
        }
            
        default:
            NSLog(@"====登录状态更新====m=");
            break;
    }
}

//呼叫ing
- (void)onOutgoingCall:(SYLinphoneCall *)call withState:(SYLinphoneCallState)state withMessage:(NSDictionary *)message{
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        
    }
    self.currentCall = nil;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //[audioSession setActive:NO error:nil];
    
    if(self.currentCall){
        SYInComingCallViewController *vc = [[SYInComingCallViewController alloc] initWithDisplayName:[SYAppConfig guardDisplayName] WithCall:self.currentCall];
        vc.sipNumber = [[SYLinphoneManager instance] getSipNumber:self.currentCall];
        [vc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.window.rootViewController presentViewController:vc animated:YES completion:^{
            //[[SYLinphoneManager instance] playRing];
        }];
    }
}

- (void)presentSecondVideo
{
    if (self.isPresentSecond) {
        SYInComingCallViewController *vc = [[SYInComingCallViewController alloc] initWithDisplayName:[SYAppConfig guardDisplayName] WithCall:self.currentCall];
        vc.sipNumber = [[SYLinphoneManager instance] getSipNumber:self.currentCall];
        
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.window.rootViewController presentViewController:vc animated:YES completion:nil];
    }
}

//有来电
- (void)onIncomingCall:(SYLinphoneCall *)call withState:(SYLinphoneCallState)state withMessage:(NSDictionary *)message withIsVideo:(BOOL)isVideo{
    
    if (self.isCallComing) {
        [[SYLinphoneManager instance] hangUpCall:call];
        return;
    }
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if ([[Common topViewController] isKindOfClass:[SYGuardMonitorViewController class]]) {
        //self.isPresentSecond = YES;
        
//        [[SYLinphoneManager instance] hangUpCall:call];
//        return;
        [[Common topViewController] dismissViewControllerAnimated:YES completion:^{
            
//            [[SYLinphoneManager instance] becomeActive];
//            [[SYLinphoneManager instance] resumeCall];
            SYInComingCallViewController *vc = [[SYInComingCallViewController alloc] initWithDisplayName:[SYAppConfig guardDisplayName] WithCall:call];
            vc.sipNumber = [[SYLinphoneManager instance] getSipNumber:call];
            
            [delegate.window.rootViewController presentViewController:vc animated:YES completion:nil];
        }];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_DissMissGuardView object:nil];
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        
        SYInComingCallViewController *vc = [[SYInComingCallViewController alloc] initWithDisplayName:[SYAppConfig guardDisplayName] WithCall:call];
        vc.sipNumber = [[SYLinphoneManager instance] getSipNumber:call];
        
        [delegate.window.rootViewController presentViewController:vc animated:YES completion:nil];
        
//        [[self topViewController] presentViewController:vc animated:YES completion:nil];
    }else {
        self.currentCall = call;
    }
    
    if ([SYAppConfig isPlayingSipVideo]) {
        self.isDismissInComingCallVC = YES;
        //[SYAppConfig shareInstance].isPlayingVideoAndOtherImComing = YES;
        [[SYLinphoneManager instance] hangUpCall];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"openSecondComing" object:nil];
    }
    
    self.isCallComing = YES;
}

//=呼叫失败
- (void)onDialFailed:(SYLinphoneCallState)state withMessage:(NSDictionary *)message{
    
    self.currentCall = nil;
    self.isCallComing = NO;
    [SYAppConfig shareInstance].isPlayingSipVideo = NO;
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        
    }
}

//挂机
- (void)onHangUp:(SYLinphoneCall *)call withState:(SYLinphoneCallState)state withMessage:(NSDictionary *)message{
    
    self.isCallComing = NO;
    [SYAppConfig shareInstance].isPlayingSipVideo = NO;
    BOOL isDissmissAnim = NO;
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        isDissmissAnim = YES;
    }
    else{
        [self openBackgroundTask:[UIApplication sharedApplication]];
    }
    
    //正在监控视频时，有门口机呼进来，则删除通话中的视频通话，不能删除呼叫页面
    if (!self.isDismissInComingCallVC) {
        [[FrameManager rootViewController] dismissViewControllerAnimated:isDissmissAnim completion:^{
            
        }];
        self.currentCall = nil;
    }
    self.isDismissInComingCallVC = NO;
    //    [[SYLinphoneManager instance] resignActive];
}

//通话连接成功
-(void)onAnswer:(SYLinphoneCall *)call withState:(SYLinphoneCallState)state withMessage:(NSDictionary *)message{
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        
    }
    self.currentCall = nil;
}

- (void)onPaused:(SYLinphoneCall *)call withState:(SYLinphoneCallState)state withMessage:(NSDictionary *)message{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self openBackgroundTask:application];
//    [[SYLinphoneManager instance] resignActive];
//    [[SYLinphoneManager instance] enterBackgroundMode];
}

//开启一个后台任务
-(void)openBackgroundTask:(UIApplication *)application{
    
    //[[SYLinphoneManager instance] resignActive];
    
    return;
    //开启一个后台任务 如果执行回调的话，3分钟后程序就会被挂起
    __block UIBackgroundTaskIdentifier background_task;
    
    background_task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^ {
        [[UIApplication sharedApplication] endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    }];
    
    WEAK_SELF;
    //========开启后台任务，这个也可以，上面的那个也可以=================
    [self stopbackgroundTimer];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0), 30.0 * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSTimeInterval remainTime =  [[UIApplication sharedApplication] backgroundTimeRemaining];
            
            //播放无声音频 (不播放也可以因为beginBackgroundTaskWithExpirationHandler:nil];这个可以一直运行下去)
            if (remainTime <= 60) {
                NSError *audioSessionError = nil;
                AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                if ( [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&(audioSessionError)] )
                {
                    NSLog(@"set audio session success!");
                }else{
                    NSLog(@"set audio session fail!");
                }
                NSURL *musicUrl = [[NSURL alloc]initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"keepawake" ofType:@"wav"]];
                //初始化一个音频对象，播放一首就要初始化一次，同时会把之前内容给遗弃。比如正在播放时切换一首歌，就需要重新调用下面代码。
                weakSelf.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:musicUrl error:nil];
                weakSelf.audioPlayer.numberOfLoops = 0; //一首歌播放次数：负数--无限循环，0--播放一次，1--播放2次，2--播放3此，以此类推
                weakSelf.audioPlayer.volume = 0;
                [weakSelf.audioPlayer prepareToPlay];
                [weakSelf.audioPlayer play];
                
                //[[SYLinphoneManager instance] becomeActive];
            }
        });
    });
    dispatch_resume(_timer);
}

- (void)stopbackgroundTimer{
    if (_timer) {
        dispatch_source_cancel(_timer);
    }
}

#pragma mark -- 登录推送
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    NSDictionary *dicLogin = [NSJSONSerialization JSONObjectWithData:payloadData options:NSJSONReadingAllowFragments error:nil];
    
    NSDictionary *resultDict = dicLogin[@"cnt"][@"result"];
    
    //NSLog(@"收到的字段==%@",dicLogin);
    
    if ([dicLogin[@"cmd"] integerValue] == 2103) {
        
        [self loginOut];
    } else if ([dicLogin[@"cmd"] isEqualToString:@"0819"]) {
        //另一台设备登录
        if ([[dicLogin[@"cnt"] allKeys] containsObject:@"client"]) {
            [self loginOut];
            [Common addAlertWithTitle:@"您的账号已在另一台设备上登录"];
        }
    }else if ([dicLogin[@"cmd"] isEqualToString:@"0818"]) {
        //今日头条
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshAdervert" object:nil];
    }else if ([dicLogin[@"cmd"] isEqualToString:@"1010"]) {
        //资讯跟头条
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshAdervert" object:nil];
    }else if ([[resultDict allKeys] containsObject:@"headurl"]) {
        
        if (resultDict[@"headurl"]) {
            NSString *headurl = resultDict[@"headurl"];
            //推送头像
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLoginImage" object:headurl];
        }
    }else if ([[resultDict allKeys] containsObject:@"token"]){
        
        NSString *token = [resultDict objectForKey:@"token"];
        
        SYUserInfoModel *model = [SYUserInfoModel mj_objectWithKeyValues:resultDict];
        
        [SYLoginInfoModel shareUserInfo].userInfoModel = model;
        
        if ([Common decryptWithText:token].length > 0) {
            
            [[NSUserDefaults standardUserDefaults] setObject:[Common decryptWithText:token] forKey:@"token"];
        }
        
        [SYLoginInfoModel shareUserInfo].userInfoModel.token = [Common decryptWithText:token];
        
        [SYLoginInfoModel shareUserInfo].userInfoModel.token_timeout = model.token_timeout;
        [SYLoginInfoModel saveWithSYLoginInfo];
        
        if (model) {
            SYNeiIPListModel *neigborModel = [SYNeiIPListModel mj_objectWithKeyValues:resultDict[@"neibor_ip"]];
            [self bindCommunity:neigborModel model:model];
            [self sipRegister];
        }
    }
}

- (void)loginOut
{
    //[[SYLinphoneManager instance] removeAccount];   //sip登出
    [SYLoginInfoModel loginOut];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"alreadyLogin"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginAgain" object:nil];
}

#pragma mark -- 绑定社区
- (void)bindCommunity:(SYNeiIPListModel *)model model:(SYUserInfoModel*)userModel
{
    if (!model) {
        return;
    }
    
    [SYAppConfig shareInstance].fneibor_flag = model.neibor_flag;
    [[NSUserDefaults standardUserDefaults] setObject:model.neibor_flag forKey:@"fneibor_flag"];
    
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    //绑定社区
    NSString *strURL = [NSString stringWithFormat:@"https://%@:%@",model.fip, model.fport];
    
    [communityHttpDAO getCanBindingWithNeiName:model.fneib_name WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username WithUserID:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id URL:strURL Succeed:^(SYCanBindingModel *canBindingModel) {
        
        if (canBindingModel.can_binding) {
            [SYAppConfig shareInstance].secondPlatformIPStr = strURL;
            [SYAppConfig shareInstance].bindedModel = canBindingModel;
            [SYAppConfig shareInstance].bindedModel.neibor_id.fopen_mode = canBindingModel.neibor_id.fopen_mode;
            [SYAppConfig saveUserLoginInfo];
            [SYAppConfig getUserLoginInfoWithUserID:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id];
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLong:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id] forKey:@"userId"];
            [[NSUserDefaults standardUserDefaults] setObject:model.fneib_name forKey:@"fneib_name"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];
            [self getUserInfoHeader:userModel];
            [Common addAlertWithTitle:@"登录成功"];
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"alreadyLogin"];
        }
        
    } fail:^(NSError *error) {
        [Common showAlert:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
    }];
}

- (void)sipRegister
{
    SYUserInfoModel *model = [SYLoginInfoModel shareUserInfo].userInfoModel;
    
    [[SYLinphoneManager instance] addProxyConfig:model.user_sip password:model.user_password displayName:model.username domain:model.fs_ip port:model.fs_port withTransport:model.transport];
}

- (void)getUserInfoHeader:(SYUserInfoModel *)model
{
    //获取用户个人设置信息
    SYPersonalSpaceHttpDAO *personalSpaceHttpDAO = [[SYPersonalSpaceHttpDAO alloc] init];
    [personalSpaceHttpDAO getUserConfigInfoWithUserName:model.username Succeed:^(SYPersonalSpaceModel *personModel) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateHeader" object:personModel];
        
    } fail:^(NSError *error) {
        [Common addAlertWithTitle:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
    }];
    
    // sip登录
    //    [SYLinphoneManager instance].nExpires = model.registrationTimeout * 60 > 0 ? : 120 * 60;
    //
    //    [[SYLinphoneManager instance] addProxyConfig:model.user_sip password:model.user_password displayName:model.username domain:model.fs_ip port:model.fs_port withTransport:model.transport];
}

@end
