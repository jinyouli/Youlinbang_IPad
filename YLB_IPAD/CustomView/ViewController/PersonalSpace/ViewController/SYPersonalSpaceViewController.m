//
//  SYPersonalSpaceViewController.m
//  YLB
//
//  Created by YAYA on 2017/3/12.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYPersonalSpaceViewController.h"
#import "SYPersonalSpaceTableViewCell.h"
#import "SYPersonalSpaceModel.h"
#import "SYSettingViewController.h"
#import "SYHelpViewController.h"
#import "SYAbountViewController.h"
#import "SYShareViewController.h"
#import "SYHouseManageViewController.h"
#import "SYSetMyConfigInfoViewController.h"
#import "UIImageView+WebCache.h"
#import "SYDiscoverHttpDAO.h"
@interface SYPersonalSpaceViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIImageView *headerImgView;
@property (nonatomic, retain) UIImageView *headerBGImgView;
@property (nonatomic, retain) UIView *headerMaskView;
@property (nonatomic, retain) UILabel *headerNameLab;
@property (nonatomic, retain) UILabel *headerSignLab;
@property (nonatomic, retain) UIView *headerInfoView;
@property (nonatomic, retain) UIImageView *headerIconBGImgView;
@property (nonatomic, retain) UIImageView *sipResignImgView;
@property (nonatomic, assign) float fHeaderInfoViewY;
@property (nonatomic, retain) NSMutableArray *sourceArr;
@end

@implementation SYPersonalSpaceViewController

- (void)dealloc{
    NSLog(@"SYPersonalSpaceViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(linphoneRegistrationUpdate:) name:kSYLinphoneRegistrationUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reflashPersonalInfo) name:SYNOTICE_REFLASH_PERSONAL_INFO object:nil];
    [self initData];
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - overwrite
- (BOOL) showBackButton{
    return NO;
}

- (BOOL)hiddenNavBar{
    return YES;
}


#pragma mark - private
- (void)initUI{
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = UIColorFromRGB(0xebebeb);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];

    self.tableView.tableHeaderView = [self tableviewHeader];
}

- (void)initData{
    SYPersonalSpaceModel *model = [[SYPersonalSpaceModel alloc] init];
    model.iconImg = [UIImage imageNamed:@"sy_me_setting"];
    model.nameStr = @"个人设置";
    NSArray *settingArr = [NSArray arrayWithObjects:model, nil];
    
    model = [[SYPersonalSpaceModel alloc] init];
    model.iconImg = [UIImage imageNamed:@"sy_me_help"];
    model.nameStr = @"帮助与反馈";
    NSArray *helpArr = [NSArray arrayWithObjects:model, nil];
    
    _sourceArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < 3; i++) {
        
        if (i == 0) {
            [self.sourceArr addObject:settingArr];
        }else if (i == 2) {
            [self.sourceArr addObject:helpArr];
        }else{
            NSMutableArray *arrm = [[NSMutableArray alloc] init];
            for (int y = 0; y < 3; y++) {
                SYPersonalSpaceModel *model = [[SYPersonalSpaceModel alloc] init];
                if (y == 0) {
                    model.iconImg = [UIImage imageNamed:@"sy_me_propertyManager"];
                    model.nameStr = @"房产管理";
                }else if (y == 1) {
                    model.iconImg = [UIImage imageNamed:@"sy_me_shareApp"];
                    model.nameStr = @"分享应用";
                }
//                else if (y == 2) {
//                    model.iconImg = [UIImage imageNamed:@"sy_me_check_update"];
//                    model.nameStr = @"检查更新";
//                }
                else {
                    model.iconImg = [UIImage imageNamed:@"sy_me_about"];
                    model.nameStr = @"关于";
                }
                [arrm addObject:model];
            }
            [self.sourceArr addObject:arrm];
        }
    }
}

- (UIView *)tableviewHeader{

    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width - 50)];
    self.headerBGImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, headerView.width, headerView.height)];
    self.headerBGImgView.image = [UIImage imageNamed:@"sy_navigation_normal_header"];
    [headerView addSubview:self.headerBGImgView];
    
    
    _headerMaskView = [[UIView alloc] initWithFrame:self.headerBGImgView.bounds];
    self.headerMaskView.backgroundColor = UIColorFromRGB(0xd23023);
    self.headerMaskView.alpha = 0.85;
    [headerView addSubview:self.headerMaskView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerImgClick)];
    [self.headerMaskView addGestureRecognizer:tap];
    
    
    UIImage *headerBGImg = [UIImage imageNamed:@"sy_me_header_bg"];
    _headerIconBGImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, headerBGImg.size.width, headerBGImg.size.height)];
    self.headerIconBGImgView.image = headerBGImg;
    self.headerIconBGImgView.center = CGPointMake(headerView.width * 0.5, headerView.height * 0.5);
    [headerView addSubview:self.headerIconBGImgView];
    
    WEAK_SELF;
    _headerImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.headerIconBGImgView.width - 8, self.headerIconBGImgView.height - 8)];
    if ([SYLoginInfoModel shareUserInfo].personalSpaceModel.headerImg) {
        self.headerImgView.image = [SYLoginInfoModel shareUserInfo].personalSpaceModel.headerImg;
        self.headerBGImgView.image = [SYLoginInfoModel shareUserInfo].personalSpaceModel.headerImg;
    }else{
        [self.headerImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[SYLoginInfoModel shareUserInfo].personalSpaceModel.head_url]]  placeholderImage:[UIImage imageNamed:@"sy_navigation_normal_header"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (image) {
                weakSelf.headerBGImgView.image = image;
                [SYLoginInfoModel shareUserInfo].personalSpaceModel.headerImg = image;
                [SYLoginInfoModel saveWithSYLoginInfo];
            }
        }];
    }
    self.headerImgView.center = CGPointMake(self.headerIconBGImgView.width * 0.5, self.headerIconBGImgView.height * 0.5);
    self.headerImgView.layer.cornerRadius = self.headerImgView.width * 0.5;
    self.headerImgView.layer.masksToBounds = YES;
    [self.headerIconBGImgView addSubview:self.headerImgView];
    
    _headerInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.height - 70, headerView.width, 50)];
    self.headerInfoView.backgroundColor = [UIColor clearColor];
    [headerView addSubview:self.headerInfoView];
    self.fHeaderInfoViewY = self.headerInfoView.top;

    NSString *str = nil;
    if ([SYLoginInfoModel shareUserInfo].personalSpaceModel.alias.length > 0) {
        str = [SYLoginInfoModel shareUserInfo].personalSpaceModel.alias;
    }else{
        str = @"友邻邦";
    }
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:16.0] andSize:CGSizeMake(self.headerInfoView.width - 20, 20)];
    _headerSignLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.headerInfoView.width - 20, size.height)];
    self.headerSignLab.font = [UIFont systemFontOfSize:16.0];
    self.headerSignLab.text = str;
    self.headerSignLab.textColor = [UIColor whiteColor];
    self.headerSignLab.textAlignment = NSTextAlignmentCenter;
    self.headerSignLab.center = CGPointMake(self.headerInfoView.width * 0.5, self.headerSignLab.centerY);
    [self.headerInfoView addSubview:self.headerSignLab];
    
    if ([SYLoginInfoModel shareUserInfo].personalSpaceModel.motto.length > 0) {
        str = [SYLoginInfoModel shareUserInfo].personalSpaceModel.motto;
    }else{
        str = @"这家伙很懒，什么都没留下";
    }
    size = [str sizeWithFont:[UIFont systemFontOfSize:12.0] andSize:CGSizeMake(self.headerInfoView.width - 20, 20)];
    _headerNameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.headerSignLab.bottom + 5, self.headerInfoView.width - 20, size.height)];
    self.headerNameLab.font = [UIFont systemFontOfSize:12.0];
    self.headerNameLab.text = str;
    self.headerNameLab.textColor = [UIColor whiteColor];
    self.headerNameLab.textAlignment = NSTextAlignmentCenter;
    self.headerNameLab.center = CGPointMake(self.headerInfoView.width * 0.5, self.headerNameLab.centerY);
    [self.headerInfoView addSubview:self.headerNameLab];
    
    UIImage *img = [UIImage imageNamed:@"sy_me_sipUnregister"];
    self.sipResignImgView = [[UIImageView alloc] initWithFrame:CGRectMake(headerView.width_sd - (img.size.width * 2), img.size.height, img.size.width, img.size.height)];
    if ([SYAppConfig isSipLogined]) {
        self.sipResignImgView.image = [UIImage imageNamed:@"sy_me_sipRegister"];
    }
    else {
        self.sipResignImgView.image = img;
    }
    [headerView addSubview:self.sipResignImgView];
    
    return headerView;
}


#pragma mark - event
- (void)headerImgClick{
    SYSetMyConfigInfoViewController *vc = [[SYSetMyConfigInfoViewController alloc] init];
    [FrameManager pushViewController:vc animated:YES];
}


#pragma mark - noti
- (void)linphoneRegistrationUpdate:(NSNotification *)notif{

    SYLinphoneRegistrationState state = [[notif.userInfo objectForKey:@"state"] intValue];
   
    if (state == SYLinphoneRegistrationOk) {
        self.sipResignImgView.image = [UIImage imageNamed:@"sy_me_sipRegister"];
    }
    else {
        self.sipResignImgView.image = [UIImage imageNamed:@"sy_me_sipUnregister"];
    }
}

- (void)reflashPersonalInfo{
    
    //===headerImg===
    if ([SYLoginInfoModel shareUserInfo].personalSpaceModel.headerImg) {
        self.headerBGImgView.image = [SYLoginInfoModel shareUserInfo].personalSpaceModel.headerImg;
        self.headerImgView.image = [SYLoginInfoModel shareUserInfo].personalSpaceModel.headerImg;
    }else{
        WEAK_SELF;
        [self.headerImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[SYLoginInfoModel shareUserInfo].personalSpaceModel.head_url]]  placeholderImage:[UIImage imageNamed:@"sy_navigation_normal_header"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (image) {
                weakSelf.headerBGImgView.image = image;
                [SYLoginInfoModel shareUserInfo].personalSpaceModel.headerImg = image;
                [SYLoginInfoModel saveWithSYLoginInfo];
            }else{
                weakSelf.headerBGImgView.image = [UIImage imageNamed:@"sy_navigation_normal_header"];
            }
        }];
    }
    
    //===昵称===
    NSString *str = nil;
    if ([SYLoginInfoModel shareUserInfo].personalSpaceModel.alias.length > 0) {
        str = [SYLoginInfoModel shareUserInfo].personalSpaceModel.alias;
    }else{
        str = @"友邻邦";
    }
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:16.0] andSize:CGSizeMake(self.headerInfoView.width - 20, 30)];
    self.headerSignLab.frame = (CGRect){self.headerSignLab.origin, { self.headerSignLab.width, size.height}};
    self.headerSignLab.text = str;
    
    //===格言===
    if ([SYLoginInfoModel shareUserInfo].personalSpaceModel.motto.length > 0) {
        str = [SYLoginInfoModel shareUserInfo].personalSpaceModel.motto;
    }else{
        str = @"这家伙很懒，什么都没留下";
    }
    size = [str sizeWithFont:[UIFont systemFontOfSize:12.0] andSize:CGSizeMake(self.headerInfoView.width - 20, 20)];
    self.headerNameLab.frame = (CGRect){self.headerNameLab.origin, { self.headerNameLab.width, size.height}};
    self.headerNameLab.text = str;
}


#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SYPersonalSpaceTableViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == self.sourceArr.count - 1) {
        return 8;
    }
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (section < self.sourceArr.count) {
        return ((NSArray *)[self.sourceArr objectAtIndex:section]).count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *identify = @"SYPersonalSpaceTableViewCellIdentify";
    SYPersonalSpaceTableViewCell *personalSpaceTableViewCell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!personalSpaceTableViewCell) {
        personalSpaceTableViewCell = [[SYPersonalSpaceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        personalSpaceTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    //最后一行隐藏line
    if (indexPath.section == 0 || indexPath.section == 2 || indexPath.row == 3) {
        [personalSpaceTableViewCell setLineHidden:YES];
    }
    else{
        [personalSpaceTableViewCell setLineHidden:NO];
    }
    
    //update data
    if (indexPath.section < self.sourceArr.count) {
        NSArray *arr = [self.sourceArr objectAtIndex:indexPath.section];
        if (indexPath.row < arr.count) {
            SYPersonalSpaceModel *model = [arr objectAtIndex:indexPath.row];
            [personalSpaceTableViewCell updateData:model];
        }
    }
    
    return personalSpaceTableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    switch (indexPath.section) {
        case 0:{
            SYSettingViewController *settingViewController = [[SYSettingViewController alloc] init];
            [FrameManager pushViewController:settingViewController animated:YES];
        }
            break;
        case 1:{
            if (indexPath.row == 0) {
                SYHouseManageViewController *houseManageViewController = [[SYHouseManageViewController alloc] init];
                [FrameManager pushViewController:houseManageViewController animated:YES];
            }else if (indexPath.row == 1) {
                SYShareViewController *shareViewController = [[SYShareViewController alloc] init];
                [FrameManager pushViewController:shareViewController animated:YES];
            }
//            else if (indexPath.row == 2) {
//                WEAK_SELF;
//                [self showWithContent:@"检查中"];
//                //检查更新
//                SYDiscoverHttpDAO *discoverHttpDAO = [[SYDiscoverHttpDAO alloc] init];
//                [discoverHttpDAO checkUpdateWithAppID:APPID Succeed:^{
//                    
//                    [weakSelf dismissHud:YES];
//                    //有新版本，提示！
//                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发现新版本" message:@"赶快体验最新版本吧！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"更新", nil];
//                    [alertView show];
//                } fail:^(NSError *error) {
//                    [weakSelf showMessageWithContent:@"已经是最新版本" duration:1];
//                }];
//            }
            else{
                SYAbountViewController *abountViewController = [[SYAbountViewController alloc] init];
                [FrameManager pushViewController:abountViewController animated:YES];
            }
        }
            break;
        case 2:{
            SYHelpViewController *helpViewController = [[SYHelpViewController alloc] init];
            [FrameManager pushViewController:helpViewController animated:YES];
        }
            break;
        default:
            break;
    }
}


#pragma mark - scrollView delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //=====tableview header 下拉方大====
    //获取偏移量
    CGPoint offset = scrollView.contentOffset;
    if (offset.y < 0) {
        CGRect rect = self.tableView.tableHeaderView.frame;
        rect.origin.y = offset.y;
        rect.origin.x = rect.origin.x + offset.y * 0.5f;
        rect.size.height = self.tableView.tableHeaderView.height - offset.y;
        rect.size.width = self.tableView.tableHeaderView.width - offset.y;
        self.headerBGImgView.frame = rect;
        self.headerMaskView.frame = rect;
    }
    
    //=====headerInfoView 跟着tableview上下移动而移动====
    float fHeaderInfoViewY = self.fHeaderInfoViewY - offset.y;
    if (fHeaderInfoViewY > (self.tableView.tableHeaderView.height - self.headerInfoView.height)) {
        fHeaderInfoViewY = self.tableView.tableHeaderView.height - self.headerInfoView.height;
    }
    if (fHeaderInfoViewY < self.headerIconBGImgView.bottom){
        fHeaderInfoViewY = self.headerIconBGImgView.bottom;
    }
    self.headerInfoView.frame = (CGRect){self.headerInfoView.left, fHeaderInfoViewY, self.headerInfoView.size};
}
@end
