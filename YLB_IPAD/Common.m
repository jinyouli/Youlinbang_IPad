//
//  Common.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/6/27.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "Common.h"
#import "MBProgressHUD.h"
#import "iToast.h"
#import "QRCodeGenerator.h"

@interface Common ()
@end

@implementation Common

+ (BOOL)isLandScap
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    return bounds.size.width > bounds.size.height;
}

+ (void)addAlertWithTitle:(NSString*)string
{
    //[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]]
    
    if (string.length > 0) {
        iToastSettings *theSettings = [iToastSettings getSharedSettings];
        [theSettings setDuration:iToastDurationNormal];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[iToast makeText:string] show];
        });
    }
}

+ (NSDate *)getPriousorLaterDateFromDate:(NSDate *)date withMonth:(int)month
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:month];
    
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *mDate = [calender dateByAddingComponents:comps toDate:date options:0];
    [comps release];
    [calender release];
    
    return mDate;
}

//保存用户绑定小区信息
+ (void)saveNeiBindingUser{
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    //WEAK_SELF;
    [communityHttpDAO saveNeiBindingUserWithNeighborHoodsID:[SYAppConfig shareInstance].bindedModel.neibor_id.neighborhoods_id WithUserID:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id Succeed:^(NSString *resultID) {
        
    } fail:^(NSError *error) {
        //[Common addAlertWithTitle:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
    }];
}

+ (BOOL)playRing{
    //勿扰模式打开
    if ([SYLoginInfoModel shareUserInfo].isAllowNoDusturbMode) {
        
        if ([SYLoginInfoModel shareUserInfo].isAllowHardDusturbMode) {
            NSDate *today = [NSDate date];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            // 时间格式,此处遇到过坑,建议时间HH大写,手机24小时进制和12小时禁止都可以完美格式化
            [dateFormat setDateFormat:@"HHmm"];
            
            NSInteger currentTimeString = [[dateFormat stringFromDate:today] integerValue];
            NSInteger nStarTIme = [[SYLoginInfoModel shareUserInfo].personalSpaceModel.start_time integerValue];
            NSInteger nEndTIme = [[SYLoginInfoModel shareUserInfo].personalSpaceModel.end_time integerValue];
            
            if (currentTimeString >= nStarTIme && currentTimeString <= 2400) {
                return NO;
            }else if (currentTimeString >= 0 && currentTimeString <= nEndTIme){
                return NO;
            }
        }else{
            return NO;
        }
    }
    return YES;
}

+ (void)showMessageWithContent:(NSString *)msg duration:(NSTimeInterval)duration view:(UIView*)addView{
    
    for (UIView *subview in addView.subviews) {
        if ([subview isKindOfClass:[MBProgressHUD class]]) {
            [subview removeFromSuperview];
        }
    }
    
    MBProgressHUD *progressHud = [[MBProgressHUD alloc] initWithView:addView];
    [addView addSubview:progressHud];
    progressHud.label.text = msg;
    
    [progressHud showAnimated:YES];
}

+ (void)showAlert:(UIView*)hubview alertText:(NSString*)text afterDelay:(NSTimeInterval)delay
{
    MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:hubview animated:YES];
    hub.mode = MBProgressHUDModeText;
    hub.label.text = text;
    [hub hideAnimated:YES afterDelay:delay];
}

+ (BOOL)isIncludeSpecialCharact: (NSString *)str {
    
    NSCharacterSet *nameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"@／：；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+"];
    
    NSRange userNameRange = [str rangeOfCharacterFromSet:nameCharacters];
    
    if (userNameRange.location != NSNotFound) {
        return YES;
    }
    return NO;
}

#pragma mark -- DES加密
+ (NSString *)encryptWithText:(NSString *)sText
{
    //kCCEncrypt 加密
    return [self encrypt:sText encryptOrDecrypt:kCCEncrypt key:commonCryptKey];
}

+ (NSString *)decryptWithText:(NSString *)sText
{
    //kCCDecrypt 解密
    return [self encrypt:sText encryptOrDecrypt:kCCDecrypt key:commonCryptKey];
}

#pragma mark - kCCDecrypt 解密   加密==============
+ (NSString *)encrypt:(NSString *)sText encryptOrDecrypt:(CCOperation)encryptOperation key:(NSString *)key
{
    const void *dataIn;
    size_t dataInLength = 0;
    
    if (!sText || [sText isEqualToString:@""] || sText.length == 0) {
        return @"";
    }
    
    if (encryptOperation == kCCDecrypt)//传递过来的是decrypt 解码
    {
        NSString *str = sText;
        NSData *decryptData = [self convertHexStrToData:str];
        
        //解码 base64
        //NSData *decryptData = [GTMBase64 decodeData:[sText dataUsingEncoding:NSUTF8StringEncoding]];//转成utf-8并decode
        
        dataInLength = [decryptData length];
        dataIn = [decryptData bytes];
    }
    else  //encrypt
    {
        NSData* encryptData = [sText dataUsingEncoding:NSUTF8StringEncoding];
        dataInLength = [encryptData length];
        [encryptData bytes];
        dataIn = [sText UTF8String];
        //dataIn = (const void *)[encryptData bytes];
    }
    
    /*
     DES加密 ：用CCCrypt函数加密一下，然后用base64编码下，传过去
     DES解密 ：把收到的数据根据base64，decode一下，然后再用CCCrypt函数解密，得到原本的数据
     */
    CCCryptorStatus ccStatus;
    size_t dataOutAvailable = 0; //size_t  是操作符sizeof返回的结果类型
    size_t dataOutMoved = 0;
    
    dataOutAvailable = (dataInLength + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    unsigned char dataOut[1024];
    memset(dataOut, 0, sizeof(char));
    const void *vkey = (const void *) [key UTF8String];
    
    //CCCrypt函数 加密/解密
    ccStatus = CCCrypt(encryptOperation,//  加密/解密
                       kCCAlgorithm3DES,//  加密根据哪个标准（des，3des，aes。。。。）
                       kCCOptionPKCS7Padding | kCCOptionECBMode ,//  选项分组密码算法(des:对每块分组加一次密  3DES：对每块分组加三个不同的密)
                       vkey,  //密钥    加密和解密的密钥必须一致
                       kCCKeySize3DES,//   DES 密钥的大小（kCCKeySizeDES=8）
                       NULL, //  可选的初始矢量
                       dataIn, // 数据的存储单元
                       dataInLength,// 数据的大小
                       (void *)dataOut,// 用于返回数据
                       dataOutAvailable,
                       &dataOutMoved);
    NSString *result = nil;
    
    if (encryptOperation == kCCDecrypt)//encryptOperation==1  解码
    {
        result = [NSString stringWithFormat:@"%s",dataOut];
        result = [result substringToIndex:32];//截取token的长度
        
        //得到解密出来的data数据，改变为utf-8的字符串
        //result = [NSString stringWithCString:(char*)dataOut encoding:NSUTF8StringEncoding];
    }
    else //encryptOperation==0  （加密过程中，把加好密的数据转成base64的）
    {
        result = [self parseByteArray2HexString:dataOut length:(NSUInteger)dataOutMoved];
    }
    return result;
}

+ (NSString *) parseByteArray2HexString:(Byte[]) bytes length:(NSUInteger)length
{
    NSMutableString *hexStr = [[NSMutableString alloc]init];
    
    int i = 0;
    if(bytes)
    {
        while (i<length)
        {
            NSString *hexByte = [NSString stringWithFormat:@"%x",bytes[i] & 0xff];///16进制数
            
            if([hexByte length]==1)
                [hexStr appendFormat:@"0%@", hexByte];
            else
                [hexStr appendFormat:@"%@", hexByte];
            i++;
        }
    }
    
    return hexStr;
}

//将16进制的字符串转换成NSData
+ (NSMutableData *)convertHexStrToData:(NSString *)str {
    
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    
    if ([str length] %2 == 0) {
        range = NSMakeRange(0,2);
        
    } else {
        range = NSMakeRange(0,1);
    }
    
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

+ (NSInteger)getNowTimestamp{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间
    NSInteger timeSp = [[NSNumber numberWithDouble:[datenow timeIntervalSince1970]] integerValue];
    return timeSp;
}

//生成二维码
+ (UIImage *)encodeQRImageWithContent:(NSString *)content size:(CGSize)size {
    UIImage *codeImage = nil;
    if (ABOVE_IOS8) {
        NSData *stringData = [content dataUsingEncoding: NSUTF8StringEncoding];
        
        //生成
        CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [qrFilter setValue:stringData forKey:@"inputMessage"];
        [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
        
        UIColor *onColor = [UIColor blackColor];
        UIColor *offColor = [UIColor whiteColor];
        
        //上色
        CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                           keysAndValues:
                                 @"inputImage",qrFilter.outputImage,
                                 @"inputColor0",[CIColor colorWithCGColor:onColor.CGColor],
                                 @"inputColor1",[CIColor colorWithCGColor:offColor.CGColor],
                                 nil];
        
        CIImage *qrImage = colorFilter.outputImage;
        CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
        UIGraphicsBeginImageContext(size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
        codeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGImageRelease(cgImage);
    } else {
        codeImage = [QRCodeGenerator qrImageForString:content imageSize:size.width];
    }
    return codeImage;
}

+ (void)showAlert:(NSString*)msg
{
    if (msg.length > 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

+ (UIViewController*)topViewController
{
    return[self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController

{
    if([rootViewController isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController*tabBarController = (UITabBarController*)rootViewController;
        
        return[self topViewControllerWithRootViewController:tabBarController.selectedViewController];
        
    }else if([rootViewController isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        
        return[self topViewControllerWithRootViewController:navigationController.visibleViewController];
        
    }else if(rootViewController.presentedViewController) {
        
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        
        return[self topViewControllerWithRootViewController:presentedViewController];
        
    }else{
        
        return rootViewController;
        
    }
}

@end
