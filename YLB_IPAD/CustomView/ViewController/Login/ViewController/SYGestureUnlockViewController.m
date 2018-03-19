//
//  SYGestureUnlockViewController.m
//  YLB
//
//  Created by YAYA on 2017/3/29.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYGestureUnlockViewController.h"
#import "SYLoginViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "SYLoginHttpDAO.h"
#import "PCCircleViewConst.h"
#import "PCLockLabel.h"
#import "PCCircleInfoView.h"
#import "SYPersonalSpaceHttpDAO.h"

typedef enum : NSUInteger {
    PWBtnTag,
    FingerPrintTag
} BtnTag;

@interface SYGestureUnlockViewController ()<CircleViewDelegate>

@property (nonatomic, assign) CircleViewType circleViewType;
@property (nonatomic, retain) PCLockLabel *msgLabel;

@end

@implementation SYGestureUnlockViewController

- (instancetype)initWithCircleViewType:(CircleViewType)type{
    if (self = [super init]) {
        self.circleViewType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    NSLog(@"===SYGestureUnlockViewController delaloc=====");
}

- (BOOL)hiddenNavBar{
    return self.isHideNavigationBar;
}

- (BOOL)panBackGestureEnable{
    return NO;
}


#pragma mark - private
- (void)initUI{
    
    //解锁界面
    PCCircleView *lockView = [[PCCircleView alloc] initWithType:self.circleViewType clip:YES arrow:YES];
    lockView.center = CGPointMake(self.view.width_sd * 0.5, self.view.height_sd * 0.5);
    lockView.delegate = self;
    lockView.isOpenTracks = [SYLoginInfoModel shareUserInfo].isShowGesturePath;
    [self.view addSubview:lockView];
    
    //提示lab
    self.msgLabel = [[PCLockLabel alloc] initWithFrame:CGRectMake(0, lockView.top_sd - 40, kScreenWidth, 20)];
    self.msgLabel.font = [UIFont systemFontOfSize:16];
    if (self.circleViewType == CircleViewTypeSetting) {
        [PCCircleViewConst saveGesture:nil Key:gestureOneSaveKey];
//        [PCCircleViewConst saveGesture:nil Key:gestureFinalSaveKey];
        [self.msgLabel showNormalMsg:gestureTextBeforeSet];
    }else{
        [self.msgLabel showNormalMsg:nil];
    }
    [self.view addSubview:self.msgLabel];
    
    
    //===header===
    UIImage *img = [UIImage imageNamed:@"sy_icon_head"];
    UIImageView *headerImgView = [[UIImageView alloc] initWithImage:img];
    headerImgView.frame = CGRectMake(0, self.msgLabel.top_sd - img.size.height, img.size.width, img.size.height);
    headerImgView.center = CGPointMake(self.view.width_sd * 0.5f, headerImgView.centerY);
    [self.view addSubview:headerImgView];
    
    
    //====密码登录===
    UIButton *pwBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pwBtn.frame = CGRectMake(30, self.view.height_sd - 100, 100, 30);
    [pwBtn setTitle:@"密码登录" forState:UIControlStateNormal];
    [pwBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    pwBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [pwBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    pwBtn.tag = PWBtnTag;
    [self.view addSubview:pwBtn];
    
    //===指纹密码====
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = FingerPrintTag;
    btn.frame = CGRectMake(self.view.width_sd - 130, self.view.height_sd - 100, 100, 30);
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitle:@"指纹密码" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:btn];
    
    if (self.circleViewType == CircleViewTypeSetting) {
        pwBtn.hidden = YES;
        btn.hidden = YES;
        headerImgView.hidden = YES;
    }
}

- (void)popToRootView{
    dispatch_async(dispatch_get_main_queue(), ^{
        [FrameManager popToRootViewControllerAnimated:YES];
    });
}


#pragma mark - event
- (void)btnClick:(UIButton *)btn{

    if (btn.tag == PWBtnTag) {
 
        [[SYLinphoneManager instance] removeAccount];   //sip登出
        [SYLoginInfoModel loginOut];
        
        SYLoginViewController *loginVC = [[SYLoginViewController alloc] initWithShowLaunchViewAnim:NO];
        [FrameManager pushViewController:loginVC animated:NO];

    }else if (btn.tag == FingerPrintTag) {
        
        WEAK_SELF;
        LAContext *context = [[LAContext alloc] init];
        //检查Touch ID是否可用
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"验证touchID" reply:^(BOOL success, NSError *error) {
                                  if (error) {

//                                      [weakSelf showErrorWithContent:[NSString stringWithFormat:@"指纹开锁失败 %@", [error.userInfo objectForKey:@"NSLocalizedDescription"]] duration:1];
                                      
                                      [weakSelf showErrorWithContent:@"亲，指纹解锁超过有限次数，请稍后再试！" duration:1];
                                      return;
                                  }
                                  if (success) {
                                      NSLog(@"指纹开锁成功");
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [FrameManager popToRootViewControllerAnimated:YES];
                                      });
                                  } else {
//                                      [weakSelf showErrorWithContent:@"验证失败" duration:1];
                                  }
                              }];
        } else {
            
            [self showErrorWithContent:@"指纹开锁设备不支持" duration:1];
        }
    }
}


#pragma mark - CircleViewDelegate
//============CircleViewType == CircleViewTypeSetting时调用==============
// 连线个数少于4个时，通知代理
- (void)circleView:(PCCircleView *)view type:(CircleViewType)type connectCirclesLessThanNeedWithGesture:(NSString *)gesture{
    NSLog(@"连线个数少于4个时，通知代理=====%@",gesture);
    
    [self.msgLabel showWarnMsgAndShake:gestureTextConnectLess];
}

//连线个数多于或等于4个，获取到第一个手势密码时通知代理
- (void)circleView:(PCCircleView *)view type:(CircleViewType)type didCompleteSetFirstGesture:(NSString *)gesture{
    NSLog(@"连线个数多于或等于4个，获取到第一个手势密码时通知代理=====%@",gesture);
    
    [self.msgLabel showNormalMsg:gestureTextDrawAgain];
}

// 获取到第二个手势密码时通知代理
- (void)circleView:(PCCircleView *)view type:(CircleViewType)type didCompleteSetSecondGesture:(NSString *)gesture result:(BOOL)equal{
    NSLog(@"获取到第二个手势密码时通知代理==%@  ==%i",gesture, equal);
    
    if (equal) {
        [FrameManager popViewControllerAnimated:YES];
    }
    else{
        [self.msgLabel showWarnMsgAndShake:gestureTextDrawAgainError];
    }
}
//==============================================================================

//============CircleViewType == CircleViewTypeLogin  or CircleViewTypeVerify 时调用==============    ,
// 登陆或者验证手势密码输入完成时的代理方法
- (void)circleView:(PCCircleView *)view type:(CircleViewType)type didCompleteLoginGesture:(NSString *)gesture result:(BOOL)equal{
    NSLog(@" 登陆或者验证手势密码输入完成时的代理方法=====%@  ==%i",gesture, equal);

    if (equal) {
        if(self.circleViewType == CircleViewTypeLogin){
       
            WEAK_SELF;
            [self showWithContent:@"登录中"];
            SYLoginHttpDAO *loginHttpDAO = [[SYLoginHttpDAO alloc] init];
            [loginHttpDAO loiginWithPassword:[SYAppConfig shareInstance].password WithUsername:[SYLoginInfoModel shareUserInfo].userInfoModel.username Succeed:^(SYUserInfoModel *model) {
                [weakSelf showSuccessWithContent:@"登录成功" duration:1];
                
                //获取用户个人设置信息
                SYPersonalSpaceHttpDAO *personalSpaceHttpDAO = [[SYPersonalSpaceHttpDAO alloc] init];
                [personalSpaceHttpDAO getUserConfigInfoWithUserName:model.username Succeed:^(SYPersonalSpaceModel *model) {

                } fail:^(NSError *error) {
                    
                }];

                [weakSelf performSelector:@selector(popToRootView) withObject:nil afterDelay:1];
            } fail:^(NSError *error) {
//                if (error.code == -1009) {
//                    [weakSelf showErrorWithContent:@"登录失败,请检查网络" duration:1];
//                }else{
//                    [weakSelf showErrorWithContent:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:@"NSLocalizedDescription"]] duration:1];
//                }
                [weakSelf performSelector:@selector(popToRootView) withObject:nil afterDelay:1];
            }];
        }  
    }
    else{
        [self.msgLabel showWarnMsgAndShake:gestureTextGestureVerifyError];
    }
}

@end
