//
//  PersonalSettingCell.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/7/3.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "PersonalSettingCell.h"

@interface PersonalSettingCell ()
@property (nonatomic,strong) UIImageView *headImageView;
@property (nonatomic,strong) UILabel *lblNickName;
@property (nonatomic,strong) UILabel *lblSign;
@property (nonatomic,strong) UIImageView *callOKImage;
@end

@implementation PersonalSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    NSString *headurl = [[NSUserDefaults standardUserDefaults] objectForKey:@"headurl"];
    NSString *nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"nickName"];
    NSString *motto = [[NSUserDefaults standardUserDefaults] objectForKey:@"motto"];
    
    UIImageView *headImageView = [[UIImageView alloc] init];
    headImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:headImageView];
    self.headImageView = headImageView;
    
    [headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",headurl]]  placeholderImage:[UIImage imageNamed:@"sy_navigation_normal_header"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            headImageView.image = image;
        }
    }];
    
    UILabel *lblNickName = [[UILabel alloc] init];
    
    if (nickName.length == 0) {
        
        NSString *userName = [SYLoginInfoModel shareUserInfo].userInfoModel.username;
    NSString *firstName = [userName substringToIndex:3];
        NSString *endName = [userName substringFromIndex:userName.length - 3];
        NSString *newName = [NSString stringWithFormat:@"%@*****%@",firstName,endName];
        lblNickName.text = newName;
    }else{
        lblNickName.text = nickName;
    }
    
    [self addSubview:lblNickName];
    self.lblNickName = lblNickName;
    
    UILabel *lblSign = [[UILabel alloc] init];
    
    if (motto.length == 0) {
        lblSign.text = @"这个家伙很懒，什么也没有留下";
    }else{
        lblSign.text = motto;
    }
    
    lblSign.font = [UIFont systemFontOfSize:14.0f];
    [self addSubview:lblSign];
    self.lblSign = lblSign;
    
    UIButton *btnCallManager = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCallManager setTitle:@"呼叫管理处" forState:UIControlStateNormal];
    self.btnCallManager = btnCallManager;
    self.btnCallManager.font = [UIFont systemFontOfSize:14.0f];
    self.btnCallManager.layer.borderWidth = 0.5f;
    self.btnCallManager.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self.btnCallManager setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self addSubview:btnCallManager];
    
    UIImageView *callOKImage = [[UIImageView alloc] init];
    callOKImage.image = [UIImage imageNamed:@"Oval 3"];
    callOKImage.contentMode = UIViewContentModeScaleAspectFit;
     [self addSubview:callOKImage];
    self.callOKImage = callOKImage;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.headImageView.frame = CGRectMake(20, 30, 70, 70);
    self.headImageView.layer.cornerRadius = self.headImageView.frame.size.width * 0.5;
    self.headImageView.layer.masksToBounds = YES;
    
    self.btnCallManager.frame = CGRectMake(screenWidth - dockWidth - 175, 45, 110, 30);
    self.lblNickName.frame = CGRectMake(self.headImageView.frame.size.width + 50, 35, screenHeight - dockWidth - 200, 30);
    self.lblSign.frame = CGRectMake(self.headImageView.frame.size.width + 50, CGRectGetMaxY(self.lblNickName.frame), screenWidth - dockWidth - 200, 30);
    
    
    self.btnCallManager.layer.cornerRadius = self.btnCallManager.frame.size.height * 0.5;
    self.btnCallManager.layer.masksToBounds = YES;
    self.callOKImage.frame = CGRectMake(screenWidth - dockWidth - 40, 50, 20, 20);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
