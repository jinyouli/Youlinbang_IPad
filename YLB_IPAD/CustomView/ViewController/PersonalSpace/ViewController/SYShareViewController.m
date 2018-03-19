//
//  SYShareViewController.m
//  YLB
//
//  Created by YAYA on 2017/3/18.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYShareViewController.h"
#import "SYFileManager.h"
#import "SYQRCodeManager.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"
#import "WeiboSDK.h"

typedef enum : NSUInteger {
    SharingAppTag,
    CLoseShareViewTag,
    ShareQQTag,
    ShareWeChatTag,
    ShareWeiBoTag,
    ShareWeChatTimelineTag
} BtnTag;

/** 保存分享应用二维码缓存 */
NSString * const SYCacheQRImage = @"SYCacheQR/qr.png";

@interface SYShareViewController ()

@property (retain, nonatomic) UIImageView *QRCodeImageView;
@property (retain, nonatomic) UILabel *descriptionLabel;
@property (retain, nonatomic) UIButton *sharingAppButton;
@property (retain, nonatomic) UIButton *shareBGBtn;
@property (retain, nonatomic) UIView *shareView;
@property (retain, nonatomic) UIView *underLineView;
@property (strong, nonatomic) UILabel *lblTitle;
@end

@implementation SYShareViewController

- (void)dealloc{
    NSLog(@"===SYShareViewController delaloc=====");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOut:) name:SYNOTICE_OTHERUSERLOGIN object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeShare) name:@"closeShare" object:nil];
    
    
    [self initUI];
    [self initQRCode];
}

- (void)viewWillLayoutSubviews
{
    self.view.frame = CGRectMake(screenWidth * 0.3, 0, screenWidth * 0.7, screenHeight);
    
    _QRCodeImageView.frame = CGRectMake(0, 0, 200, 200);
    self.QRCodeImageView.center = CGPointMake(self.view.width * 0.5, self.view.height * 0.4);
    _descriptionLabel.frame = CGRectMake(0, self.QRCodeImageView.bottom + 10, self.view.width, 30);
    
    _sharingAppButton.frame = CGRectMake(50, CGRectGetMaxY(self.descriptionLabel.frame) + 70, self.view.width - 100, 40);
    self.sharingAppButton.center = CGPointMake(self.view.width * 0.5, self.sharingAppButton.centerY);
    self.lblTitle.frame = CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50);
    
    _underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth - dockWidth - 0, 1)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)backBtnTitle{
    return @"分享应用";
}

- (void)ExitSubView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeDrawer"
                                                        object:nil];
}

#pragma mark - Private Methods
- (void)initUI{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:bgView];
    
    _QRCodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    self.QRCodeImageView.center = CGPointMake(bgView.width * 0.5, bgView.height * 0.4);
    self.QRCodeImageView.layer.borderWidth = 1.0f;
    self.QRCodeImageView.layer.borderColor = UIColorFromRGB(0xd1d1d1).CGColor;
    [bgView addSubview:self.QRCodeImageView];
    
    _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.QRCodeImageView.bottom + 10, bgView.width, 30)];
    self.descriptionLabel.font = [UIFont systemFontOfSize:15.0];
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.textColor = UIColorFromRGB(0x555555);
    self.descriptionLabel.text = @"邀请好友扫描二维码下载友邻邦";
    [bgView addSubview:self.descriptionLabel];
    
    _sharingAppButton = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(self.descriptionLabel.frame) + 70, bgView.width - 100, 40)];
    self.sharingAppButton.backgroundColor = UIColorFromRGB(0xEC5F05);
    self.sharingAppButton.tag = SharingAppTag;
    self.sharingAppButton.layer.cornerRadius = 20;
    self.sharingAppButton.layer.masksToBounds = YES;
    [self.sharingAppButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.sharingAppButton setTitle:@"分享到其他应用" forState:UIControlStateNormal];
    self.sharingAppButton.center = CGPointMake(bgView.width * 0.5, self.sharingAppButton.centerY);
    self.sharingAppButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [bgView addSubview:self.sharingAppButton];
    
    
    self.shareBGBtn = [[UIButton alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    self.shareBGBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.shareBGBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.shareBGBtn.tag = CLoseShareViewTag;
    self.shareBGBtn.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:self.shareBGBtn];

    self.shareView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].keyWindow.height_sd, self.view.width, 120)];
    self.shareView.backgroundColor = UIColorFromRGB(0xebebeb);
    self.shareView.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:self.shareView];
    
    UILabel *shareTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.shareView.width, 20)];
    shareTitleLabel.font = [UIFont systemFontOfSize:15.0];
    shareTitleLabel.textAlignment = NSTextAlignmentCenter;
    shareTitleLabel.textColor = UIColorFromRGB(0x999999);
    shareTitleLabel.text = @"请选择分享平台";
    [self.shareView addSubview:shareTitleLabel];
    
    float btnHeight = 50;
    float fMargin = (self.shareView.width_sd - (btnHeight * 4)) / 5;
    for (int i = 0; i < 4; i++) {
        
        UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shareBtn.backgroundColor = [UIColor whiteColor];
        shareBtn.frame = CGRectMake((i * fMargin) + (i * btnHeight) + fMargin, shareTitleLabel.bottom_sd + 10, btnHeight, btnHeight);
        [shareBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        shareBtn.layer.cornerRadius = shareBtn.width_sd * 0.5;
        shareBtn.layer.masksToBounds = YES;
        [self.shareView addSubview:shareBtn];

        UILabel *shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, shareBtn.bottom_sd + 5, shareBtn.width + 20, 15)];
        shareLabel.font = [UIFont systemFontOfSize:12.0];
        shareLabel.textAlignment = NSTextAlignmentCenter;
        shareLabel.textColor = UIColorFromRGB(0x55555);
        shareLabel.center = CGPointMake(shareBtn.centerX, shareLabel.centerY);
        [self.shareView addSubview:shareLabel];

        if (i == 0) {
            shareBtn.tag = ShareWeiBoTag;
            [shareBtn setImage:[UIImage imageNamed:@"sy_share_sina"] forState:UIControlStateNormal];
            shareLabel.text = @"新浪微博";
        }else if (i == 1) {
            shareBtn.tag = ShareWeChatTag;
            [shareBtn setImage:[UIImage imageNamed:@"sy_share_wechat"] forState:UIControlStateNormal];
            shareLabel.text = @"微信";
        }else if (i == 2) {
            shareBtn.tag = ShareWeChatTimelineTag;
            [shareBtn setImage:[UIImage imageNamed:@"sy_share_wechat_timeline"] forState:UIControlStateNormal];
            shareLabel.text = @"微信朋友圈";
        }else if (i == 3) {
            shareBtn.tag = ShareQQTag;
            [shareBtn setImage:[UIImage imageNamed:@"sy_share_qq"] forState:UIControlStateNormal];
            shareLabel.text = @"QQ";
        }
    }
    
    
    UIButton *btnReturn = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReturn.frame = CGRectMake(0, 10, 70, 50);
    [btnReturn setImage:[UIImage imageNamed:@"last.png"] forState:UIControlStateNormal];
    [btnReturn addTarget:self action:@selector(ExitSubView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnReturn];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * 0.5 - 75, 10, 150, 50)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = @"分享应用";
    self.lblTitle = lblTitle;
    [self.view addSubview:lblTitle];
    
    _underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth - dockWidth - 0, 1)];
    _underLineView.backgroundColor = underLineColor;
    [self.view addSubview:_underLineView];
}

- (void)initQRCode {

    //先判断cache中有没有缓存
    NSString *imagePath = [SYFileManager fileManagerSearchFileWithPath:SYCacheQRImage];
    if (imagePath) {
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
        self.QRCodeImageView.image = image;
    } else {
        SYQRCodeManager *qrCodeMrg = [[SYQRCodeManager alloc] init];
        NSString *str = [NSString stringWithFormat:@"http://a.app.qq.com/o/simple.jsp?pkgname=unionbon.ylb.imsdroid"];//[NSString stringWithFormat:@"https://itunes.apple.com/cn/app/you-lin-bang/id1127316147?mt=8"];
        UIImage *image = [qrCodeMrg generateQRCodeWithMsg:str fgImage:[UIImage imageNamed:@"sy_iconImage"]];
        self.QRCodeImageView.image = image;
        
        // 缓存
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [documentPath stringByAppendingPathComponent:SYCacheQRImage];
        NSString *plistDir = [documentPath stringByAppendingPathComponent:@"SYCacheQR"];
        if(![[NSFileManager defaultManager] fileExistsAtPath:plistDir]){
            [[NSFileManager defaultManager] createDirectoryAtPath:plistDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        BOOL status = [data writeToFile:path atomically:YES];
        if (status) {
            NSLog(@"保存二维码缓存图片成功");
        } else {
            NSLog(@"保存二维码缓存图片失败");
        }
    }
}

//分享微信 isSession 是否好友还是朋友圈
- (void)shareWeChatScene:(BOOL)isSession{
    
    if ([WXApi isWXAppInstalled]){
        
        WXMediaMessage *message = [WXMediaMessage message];
    
        UIImage *theImage = [self imageByScalingAndCroppingForSize:CGSizeMake(100, 100) forImage:self.QRCodeImageView.image];
        [message setThumbImage:theImage];
        
        WXImageObject *ext = [WXImageObject object];
        ext.imageData =  UIImagePNGRepresentation(self.QRCodeImageView.image);
        message.mediaObject = ext;
        
        SendMessageToWXReq * req = [[SendMessageToWXReq alloc] init];
        req.message = message;
        req.bText = NO;
        if (isSession) {
            req.scene = WXSceneSession;
        }
        else{
            req.scene = WXSceneTimeline;
        }
        [WXApi sendReq:req];
    }
    else{
        [self showMessageWithContent:@"请先安装微信" duration:1];
    }
}

//压缩图片
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize forImage:(UIImage *)originImage
{
    UIImage *sourceImage = originImage;// 原图
    UIImage *newImage = nil;// 新图
    // 原图尺寸
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;// 目标宽度
    CGFloat targetHeight = targetSize.height;// 目标高度
    // 伸缩参数初始化
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {// 如果原尺寸与目标尺寸不同才执行
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // 根据宽度伸缩
        else
            scaleFactor = heightFactor; // 根据高度伸缩
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // 定位图片的中心点
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    // 创建基于位图的上下文
    UIGraphicsBeginImageContext(targetSize);
    
    // 目标尺寸
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    // 新图片
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    // 退出位图上下文
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark - event
- (void)btnClick:(UIButton *)btn{
    
    if (btn.tag == SharingAppTag) {
        self.shareBGBtn.hidden = NO;
        self.shareView.hidden = NO;
        WEAK_SELF;
        [UIView animateWithDuration:0.15 animations:^{
            if (!weakSelf.shareBGBtn.hidden) {
                weakSelf.shareView.top = [UIApplication sharedApplication].keyWindow.height_sd - weakSelf.shareView.height_sd;
            }
            else{
                weakSelf.shareView.top = [UIApplication sharedApplication].keyWindow.height_sd;
            }
        }];
    }
    else if (btn.tag == CLoseShareViewTag) {
        [self closeShare];
    }
    else if (btn.tag == ShareQQTag) {
        
        if ([QQApiInterface isQQInstalled]) {
            QQApiImageObject *imgObj = [QQApiImageObject objectWithData:UIImagePNGRepresentation(self.QRCodeImageView.image) previewImageData:UIImagePNGRepresentation(self.QRCodeImageView.image) title:nil description:nil];

            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
            [QQApiInterface sendReq:req];
        }
        else{
            [self showMessageWithContent:@"请先安装QQ" duration:1];
        }
    }
    else if (btn.tag == ShareWeChatTag) {
        
        [self shareWeChatScene:YES];
    }
    else if (btn.tag == ShareWeiBoTag) {
        
        if (![WeiboSDK isWeiboAppInstalled]) {
            [self showMessageWithContent:@"请先安装新浪微博" duration:1];
        }else {
            WBMessageObject *message = [WBMessageObject message];

            // 消息的图片内容中，图片数据不能为空并且大小不能超过10M
            WBImageObject *imageObject = [WBImageObject object];
            imageObject.imageData = UIImageJPEGRepresentation(self.QRCodeImageView.image, 0.5);
            message.imageObject = imageObject;
            
            WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
            [WeiboSDK sendRequest:request];
        }
    }
    else if (btn.tag == ShareWeChatTimelineTag) {
        
        [self shareWeChatScene:NO];
    }
}

- (void)closeShare
{
    self.shareBGBtn.hidden = YES;
    
    WEAK_SELF;
    [UIView animateWithDuration:0.15 animations:^{
        weakSelf.shareView.top = [UIApplication sharedApplication].keyWindow.height_sd;
    } completion:^(BOOL finished) {
        weakSelf.shareView.hidden = YES;
    }];
}

#pragma mark - noti
- (void)loginOut:(NSNotification *)noti{
    self.shareBGBtn.hidden = YES;
    self.shareView.hidden = YES;
}

@end
