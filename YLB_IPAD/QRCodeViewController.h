//
//  QRCodeViewController.h
//  YLB_IPAD
//
//  Created by jinyou on 2017/7/18.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCodeViewController : UIViewController
@property (nonatomic,copy) NSString *QRCodeNum;
@property (nonatomic,strong) UIImageView *backgroundImage;
@property (nonatomic,strong) UIImageView *qrcodeImage;

@property (nonatomic,strong) UIView *whiteBack;
@property (nonatomic,strong) UILabel *lblTitle;
@property (nonatomic,strong) UILabel *lblContent;

@property (nonatomic,strong) UIView *scanSuccessBack;
@property (nonatomic,strong) UIImageView *headImage;
@property (nonatomic,strong) UILabel *lblTitle_success;
@property (nonatomic,strong) UILabel *lblContent_success;
@property (nonatomic,strong) UIButton *btnReturn;

@property (nonatomic,strong) UILabel *lblProjectNum;


- (instancetype)initWithQRImage:(NSString*)QRCodeNum;
@end
