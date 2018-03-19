//
//  QRCodeViewController.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/7/18.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "QRCodeViewController.h"

@interface QRCodeViewController ()<UIAlertViewDelegate>
@property (nonatomic, copy) NSString *strIP;
@end

@implementation QRCodeViewController

- (instancetype)initWithQRImage:(NSString*)QRCodeNum
{
    self = [super init];
    if (self) {
        _QRCodeNum = QRCodeNum;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.backgroundImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backgroundImage.image = [UIImage imageNamed:@"Background1536x2048.jpg"];
    [self.view addSubview:self.backgroundImage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"successClientID" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"loginSuccess" object:nil];
    
    self.whiteBack = [[UIView alloc] init];
    self.whiteBack.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.whiteBack];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadData)];
    
    self.qrcodeImage = [[UIImageView alloc] init];
    self.qrcodeImage.userInteractionEnabled = YES;
    [self.whiteBack addSubview:self.qrcodeImage];
    [self.qrcodeImage addGestureRecognizer:tapGesture];
    
    self.lblTitle = [[UILabel alloc] init];
    //self.lblTitle.text = @"扫码登陆友邻邦";
    self.lblTitle.text = @"点击重新获取二维码";
    self.lblTitle.textColor = [UIColor colorWithRed:57.0f/255.0f green:150.0f/255.0f blue:216.0f/255.0f alpha:1.0];
    self.lblTitle.font = [UIFont systemFontOfSize:17.0f];
    self.lblTitle.textAlignment = NSTextAlignmentCenter;
    [self.whiteBack addSubview:self.lblTitle];
    
    self.lblContent = [[UILabel alloc] init];
    self.lblContent.text = @"iPad友邻邦需要配合你的手机登陆使用";
    self.lblContent.font = [UIFont systemFontOfSize:14.0f];
    self.lblContent.textAlignment = NSTextAlignmentCenter;
    self.lblContent.textColor = [UIColor lightGrayColor];
    [self.whiteBack addSubview:self.lblContent];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLoginImage:) name:@"updateLoginImage" object:nil];
    
    self.scanSuccessBack = [[UIView alloc] init];
    self.scanSuccessBack.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scanSuccessBack];
    
    self.headImage = [[UIImageView alloc] init];
    [self.scanSuccessBack addSubview:self.headImage];
    
    self.lblTitle_success = [[UILabel alloc] init];
    self.lblTitle_success.text = @"扫描成功";
    self.lblTitle_success.textColor = [UIColor greenColor];
    self.lblTitle_success.font = [UIFont systemFontOfSize:17.0f];
    self.lblTitle_success.textAlignment = NSTextAlignmentCenter;
    [self.scanSuccessBack addSubview:self.lblTitle_success];
    
    self.lblContent_success = [[UILabel alloc] init];
    self.lblContent_success.text = @"请在手机友邻邦中点击登录";
    self.lblContent_success.font = [UIFont systemFontOfSize:14.0f];
    self.lblContent_success.textAlignment = NSTextAlignmentCenter;
    self.lblContent_success.textColor = [UIColor lightGrayColor];
    [self.scanSuccessBack addSubview:self.lblContent_success];
    
    self.btnReturn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnReturn setTitle:@"切换账号" forState:UIControlStateNormal];
    [self.btnReturn setImage:[UIImage imageNamed:@"sy_me_rightArrow@2x"] forState:UIControlStateNormal];
    [self.btnReturn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnReturn addTarget:self action:@selector(changeNum) forControlEvents:UIControlEventTouchUpInside];
    [self.scanSuccessBack addSubview:self.btnReturn];
    self.scanSuccessBack.hidden = YES;
    
    self.lblProjectNum = [[UILabel alloc] init];
    self.lblProjectNum.text = [NSString stringWithFormat:@"当前版本号：%@",[SYAppConfig appVersion]];
    self.lblProjectNum.font = [UIFont systemFontOfSize:14.0f];
    self.lblProjectNum.textAlignment = NSTextAlignmentCenter;
    self.lblProjectNum.textColor = [UIColor whiteColor];
    self.lblProjectNum.userInteractionEnabled = YES;
    [self.view addSubview:self.lblProjectNum];
 
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeIP)];
    [gesture setNumberOfTapsRequired:6];
    [self.lblProjectNum addGestureRecognizer:gesture];
    
    NSString *currentStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"QRcode"];
    if (![currentStatus isEqualToString:@"1"]) {
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"clientId"]) {
            [self loadData];
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"QRcode"];
        }
    }
}

- (void)changeIP{
    self.strIP = [SYAppConfig baseURL];
    if ([[SYAppConfig shareInstance].base_url isEqualToString:@"https://api.sayee.cn:28084"]) {
        self.strIP = @"https://gdsayee.cn:28084";
    }else{
        self.strIP = @"https://api.sayee.cn:28084";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更换IP" message:self.strIP delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
}



#pragma mark - UIAlertView delegete
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        UITextField *txtIP = [alertView textFieldAtIndex:0];
        
        txtIP.text = [txtIP.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if (txtIP.text.length > 0) {
            self.strIP = txtIP.text;
        }
        [[NSUserDefaults standardUserDefaults] setObject:self.strIP forKey:@"base_url"];
        [SYAppConfig shareInstance].base_url = self.strIP;
        [self loadData];
    }
}

- (void)loadData
{
    NSString *clientId = [[NSUserDefaults standardUserDefaults] objectForKey:@"clientId"];
    
    NSString *secret_key = [NSString stringWithFormat:@"%@,%zd",clientId,[Common getNowTimestamp]];
    
    NSString *key = [Common encryptWithText:secret_key];
    
    SYLoginHttpDAO *loginHttpDAO = [[SYLoginHttpDAO alloc] init];
    
    
    [loginHttpDAO getUnionCode:key successBlock:^(NSString *qr_code){
        
        _QRCodeNum = qr_code;
        self.qrcodeImage.image = [Common encodeQRImageWithContent:self.QRCodeNum size:CGSizeMake(100, 100)];
        self.lblTitle.text = @"扫码登陆友邻邦";
        self.lblTitle.textColor = [UIColor blackColor];
        
    } fail:^(NSError *error) {
        self.lblTitle.text = @"点击重新获取二维码";
        self.lblTitle.textColor = [UIColor colorWithRed:57.0f/255.0f green:150.0f/255.0f blue:216.0f/255.0f alpha:1.0];
        //[Common showAlert:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
    }];
}

- (void)changeNum
{
    self.scanSuccessBack.hidden = YES;
    self.whiteBack.hidden = NO;
}

- (void)viewWillLayoutSubviews
{
    self.backgroundImage.frame = self.view.bounds;
    
    self.whiteBack.frame = CGRectMake(screenWidth * 0.5 - self.whiteBack.bounds.size.width * 0.5, screenHeight * 0.5 - self.whiteBack.bounds.size.height * 0.5, 250, 350);
    self.whiteBack.layer.cornerRadius = 8;
    self.whiteBack.layer.masksToBounds = YES;
    
    self.qrcodeImage.frame = CGRectMake(self.whiteBack.bounds.size.width * 0.5 - self.qrcodeImage.bounds.size.width * 0.5, self.whiteBack.bounds.size.height * 0.5 - self.qrcodeImage.bounds.size.height * 0.75, 130, 130);
    
    self.lblTitle.frame = CGRectMake(0, CGRectGetMaxY(self.qrcodeImage.frame) + 10, self.whiteBack.bounds.size.width, 30);
    self.lblContent.frame = CGRectMake(0, CGRectGetMaxY(self.lblTitle.frame), self.whiteBack.bounds.size.width, 30);
    
    self.scanSuccessBack.frame = CGRectMake(screenWidth * 0.5 - self.scanSuccessBack.bounds.size.width * 0.5, screenHeight * 0.5 - self.scanSuccessBack.bounds.size.height * 0.5, 250, 350);
    self.scanSuccessBack.layer.cornerRadius = 8;
    self.scanSuccessBack.layer.masksToBounds = YES;
    
    self.headImage.frame = CGRectMake(self.scanSuccessBack.bounds.size.width * 0.5 - self.headImage.bounds.size.width * 0.5, self.scanSuccessBack.bounds.size.height * 0.5 - self.headImage.bounds.size.height * 0.75, 130, 130);
    self.headImage.layer.cornerRadius = self.headImage.bounds.size.width * 0.5;
    self.headImage.layer.masksToBounds = YES;
    
    self.lblTitle_success.frame = CGRectMake(0, CGRectGetMaxY(self.headImage.frame) + 10, self.scanSuccessBack.bounds.size.width, 30);
    self.lblContent_success.frame = CGRectMake(0, CGRectGetMaxY(self.lblTitle_success.frame), self.scanSuccessBack.bounds.size.width, 30);
    self.btnReturn.frame = CGRectMake(10, CGRectGetMaxY(self.lblContent_success.frame), self.scanSuccessBack.bounds.size.width - 20, 50);
    
    [self.btnReturn setImageEdgeInsets:UIEdgeInsetsMake(0, 50, 0, -100)];
    [self.btnReturn setTitleEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    
    self.lblProjectNum.frame = CGRectMake(0, screenHeight - 50, screenWidth, 30);
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"QRcode"];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
