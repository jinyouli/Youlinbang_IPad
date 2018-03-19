//
//  SYSetMyConfigInfoViewController.m
//  YLB
//
//  Created by YAYA on 2017/4/8.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYSetMyConfigInfoViewController.h"
#import "SYSetMyConfigInfoTableViewCell.h"
#import "SYPersonalSpaceHttpDAO.h"
#import <Photos/Photos.h>
#import "CorePhotoPickerVCManager.h"

@interface SYSetMyConfigInfoViewController ()<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, SYSetMyConfigInfoTableViewCellDelegate>

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIImage *headerImg;
@property (nonatomic, copy) NSString *headerURL;
@property (nonatomic, copy) NSString *motto;
@property (nonatomic, copy) NSString *alias;

@property (nonatomic, assign) BOOL canCommit;

@end

@implementation SYSetMyConfigInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.motto = [SYLoginInfoModel shareUserInfo].personalSpaceModel.motto;
    self.alias = [SYLoginInfoModel shareUserInfo].personalSpaceModel.alias;
    self.headerImg = [SYLoginInfoModel shareUserInfo].personalSpaceModel.headerImg;
    [self initUI];
    
    self.canCommit = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - overwrite
- (NSString *)backBtnTitle{
    return @"我的资料";
}


#pragma mark - private
- (void)initUI{
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = UIColorFromRGB(0xebebeb);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
    [self.view addSubview:self.tableView];

    //==========提交按钮=======
    UIButton *newRepairBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    newRepairBtn.frame = CGRectMake(0, 0, 60, 44);
    newRepairBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [newRepairBtn setTitle:@"提交" forState:UIControlStateNormal];
    [newRepairBtn addTarget:self action:@selector(submitBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:newRepairBtn];
    UIBarButtonItem *flexSpacerl = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    flexSpacerl.width = -15;
    self.navigationItem.rightBarButtonItems = @[flexSpacerl, backItem];
}

- (void)sumitInfo:(SYPersonalSpaceHttpDAO *)personalSpaceHttpDAO{
    WEAK_SELF;
    [personalSpaceHttpDAO setUserConfigInfoWithUserName:[SYLoginInfoModel shareUserInfo].userInfoModel.username WithAlias:self.alias WithMotto:self.motto WithHeadUrl:self.headerURL WithEmail:nil WithGesturePwd:nil Succeed:^{
        
        [SYLoginInfoModel shareUserInfo].personalSpaceModel.motto = weakSelf.motto;
        [SYLoginInfoModel shareUserInfo].personalSpaceModel.alias = weakSelf.alias;
        [SYLoginInfoModel shareUserInfo].personalSpaceModel.head_url = weakSelf.headerURL;
        [SYLoginInfoModel shareUserInfo].personalSpaceModel.headerImg = weakSelf.headerImg;
        [SYLoginInfoModel saveWithSYLoginInfo];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_REFLASH_PERSONAL_INFO object:nil];
        
        [weakSelf showSuccessWithContent:@"提交成功" duration:1];
        
        [weakSelf performSelector:@selector(backLastVC) withObject:nil afterDelay:1];
    } fail:^(NSError *error) {
        [weakSelf showErrorWithContent:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]] duration:1];
    }];
}

- (void)backLastVC{
    [FrameManager popViewControllerAnimated:YES];
}


#pragma mark - event
- (void)submitBtnClick:(UIButton *)btn{
    [self.view endEditing:YES];
    
    if (!self.headerImg && self.alias.length == 0 && self.motto.length == 0) {
        return;
    }
    
    if (!self.canCommit) {
        [Common showAlert:self.view alertText:@"昵称和签名相同，无须修改" afterDelay:1.0];
        return;
    }

    if ([self.alias isEqualToString:@""]) {
        [Common showAlert:self.view alertText:@"请输入昵称" afterDelay:1.0];
        return;
    }
    
    if ([self.motto isEqualToString:@""]) {
        [Common showAlert:self.view alertText:@"请输入签名" afterDelay:1.0];
        return;
    }
    
    WEAK_SELF;
    [self showWithContent:@"提交中"];
    SYPersonalSpaceHttpDAO *personalSpaceHttpDAO = [[SYPersonalSpaceHttpDAO alloc] init];
    
    NSArray *arr;
    if (self.headerImg) {
        arr = [NSArray arrayWithObject:self.headerImg];
    }
    [personalSpaceHttpDAO uploadImgToQiniuWithImgArr:arr Succeed:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        weakSelf.headerURL = key;
        [weakSelf sumitInfo:personalSpaceHttpDAO];
        
    } fail:^(NSError *error) {
        [weakSelf sumitInfo:personalSpaceHttpDAO];
    }];
}

#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SYSetMyConfigInfoTableViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identify = @"SYSetMyConfigInfoTableViewCell";
    SYSetMyConfigInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[SYSetMyConfigInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    cell.indexPath = indexPath;
    
    //update data
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [cell updateLeftTitle:@"头像" Alias:NO Motto:NO HeaderImg:self.headerImg ? : [SYLoginInfoModel shareUserInfo].personalSpaceModel.headerImg HeaderHidden:YES];
        }else if (indexPath.row == 1){
            [cell updateLeftTitle:@"昵称" Alias:YES Motto:NO HeaderImg:nil HeaderHidden:NO];
        }
    }
    else if (indexPath.section == 1 && indexPath.row == 0){
        [cell updateLeftTitle:@"签名" Alias:NO Motto:YES HeaderImg:nil HeaderHidden:NO];
    }
    
    return cell;
}


#pragma mark - SYSetMyConfigInfoTableViewCell delegate
- (void)headerClick:(NSIndexPath *)indexPath{

    [self.view endEditing:YES];
    if (!indexPath) {
        return;
    }
    
    WEAK_SELF;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        if (status != PHAuthorizationStatusAuthorized) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选取" delegate:weakSelf cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍摄" otherButtonTitles:@"照片库", nil];
            
            [sheet showInView:weakSelf.view];
        });
    }];
}

- (void)txtFieldMotto:(NSString *)motto Alias:(NSString *)alias{
    
    if ([self.alias isEqualToString:alias] && [self.motto isEqualToString:motto]) {
        self.canCommit = NO;
        return;
    }
    
    self.canCommit = YES;
    self.alias = alias;
    self.motto = motto;
}


#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    CorePhotoPickerVCMangerType type = CorePhotoPickerVCMangerTypeCamera;

    if (buttonIndex == 0) type=CorePhotoPickerVCMangerTypeCamera;
    
    if (buttonIndex == 1) type=CorePhotoPickerVCMangerTypeSinglePhoto;
    
    if (buttonIndex == 2) return;
    
    CorePhotoPickerVCManager *manager = [CorePhotoPickerVCManager sharedCorePhotoPickerVCManager];
    
    //设置类型
    manager.pickerVCManagerType = type;
    
    //最多可选3张
    manager.maxSelectedPhotoNumber = 1;
    
    //错误处理
    if(manager.unavailableType != CorePhotoPickerUnavailableTypeNone){
        NSLog(@"设备不可用");
        return;
    }
    
    UIViewController *pickerVC = manager.imagePickerController;

    //选取结束
    WEAK_SELF;
    manager.finishPickingMedia = ^(NSArray *medias){

        [medias enumerateObjectsUsingBlock:^(CorePhoto *photo, NSUInteger idx, BOOL *stop) {

            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.headerImg = photo.editedImage;
                [weakSelf.tableView reloadData];
            });
        }];
    };
    
    [self presentViewController:pickerVC animated:YES completion:nil];
}

@end
