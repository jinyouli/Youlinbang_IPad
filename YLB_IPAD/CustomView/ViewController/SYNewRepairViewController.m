//
//  SYNewRepairViewController.m
//  YLB
//
//  Created by sayee on 17/4/6.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYNewRepairViewController.h"
#import "SYNewRepairAddImgViewCollectionViewCell.h"
#import <Photos/Photos.h>
#import "CorePhotoPickerVCManager.h"
#import "SYCommunityHttpDAO.h"
#import "SYPersonalSpaceHttpDAO.h"

@interface SYNewRepairViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, SYNewRepairAddImgViewCollectionViewCellDelegate, UIActionSheetDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *submitBtn;
@property (nonatomic, strong) UITextView *contentTxtView;
@property (nonatomic, strong) UILabel *leftLetters; //还剩多少个字
@property (nonatomic, retain) UICollectionView *imgViewCollectionView;
@property (nonatomic, strong) UITextField *contactTxtField;
@property (nonatomic, strong) UITextField *numberTxtField;
@property (nonatomic, strong) UITextField *addressTxtField;
@property (nonatomic, strong) UIView *addressView;
@property (nonatomic, strong) UIView *addressMoreView;  //显示更多地址的下拉view
@property (nonatomic, assign) int addressIndex; //选择哪个地址    addressTxtField.text
@property (nonatomic, strong) NSMutableArray *addImgViewMArr;
@property (nonatomic, assign) RepairListOrderType oderType;
@property (nonatomic, copy) NSString *titleStr;
@end

@implementation SYNewRepairViewController

- (instancetype)initWithRepairListOrderType:(RepairListOrderType)type WithTitle:(NSString *)title{
    if (self = [super init]) {
        self.oderType = type;
        self.titleStr = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.addressIndex = 0;
    self.addImgViewMArr = [[NSMutableArray alloc] init];
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - overwrite
- (NSString *)backBtnTitle{
    return self.titleStr;
}


#pragma mark - private
- (void)initUI{

    //上面的内容
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, self.view.width_sd - 20, 200)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    self.contentTxtView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, contentView.width_sd - 20, 90)];
    self.contentTxtView.font = [UIFont systemFontOfSize:14];
    self.contentTxtView.delegate = self;
    [contentView addSubview:self.contentTxtView];
    
    self.leftLetters = [[UILabel alloc] initWithFrame:CGRectMake(contentView.width_sd - 100, self.contentTxtView.bottom_sd, 90, 20)];
    self.leftLetters.font = [UIFont systemFontOfSize:12];
    self.leftLetters.textAlignment = NSTextAlignmentRight;
    
    NSString *leftNumber = [NSString stringWithFormat:@"%i",100 - self.contentTxtView.text.length];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"还剩%@个字", leftNumber]];
    [attStr setAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xd23023)} range:NSMakeRange(2, leftNumber.length)];
    self.leftLetters.attributedText = attStr;
    [contentView addSubview:self.leftLetters];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(70, 70);
    self.imgViewCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.contentTxtView.left_sd, self.leftLetters.bottom_sd, 230, 70) collectionViewLayout:layout];
    self.imgViewCollectionView.scrollEnabled = NO;
    self.imgViewCollectionView.delegate = self;
    self.imgViewCollectionView.dataSource = self;
    self.imgViewCollectionView.backgroundColor = [UIColor clearColor];
    [contentView addSubview:self.imgViewCollectionView];
    [self.imgViewCollectionView registerClass:[SYNewRepairAddImgViewCollectionViewCell class] forCellWithReuseIdentifier:@"SYNewRepairAddImgViewCollectionViewCell"];

    
    //联系人、电话
    UIView *contactView = [[UIView alloc] initWithFrame:CGRectMake(10, contentView.bottom_sd + 10, contentView.width_sd, 50)];
    contactView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contactView];
    

    self.contactTxtField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, contactView.width_sd  * 0.5 - 10, contactView.height_sd)];
    self.contactTxtField.font = [UIFont systemFontOfSize:14];
    self.contactTxtField.leftView = [self txtFieldLeftView:@"联系人: "];
    self.contactTxtField.text = [SYLoginInfoModel shareUserInfo].personalSpaceModel.alias.length > 0 ? [SYLoginInfoModel shareUserInfo].personalSpaceModel.alias : [SYLoginInfoModel shareUserInfo].userInfoModel.username;
    self.contactTxtField.textColor = UIColorFromRGB(0x999999);
    self.contactTxtField.leftViewMode = UITextFieldViewModeAlways;
    [contactView addSubview:self.contactTxtField];

    self.numberTxtField = [[UITextField alloc] initWithFrame:CGRectMake(self.contactTxtField.right_sd, self.contactTxtField.top_sd, self.contactTxtField.width_sd, contactView.height_sd)];
    self.numberTxtField.leftView = [self txtFieldLeftView:@"电话: "];
    self.numberTxtField.textColor = UIColorFromRGB(0x999999);
    self.numberTxtField.leftViewMode = UITextFieldViewModeAlways;
    self.numberTxtField.font = [UIFont systemFontOfSize:14];
    self.numberTxtField.text = [SYLoginInfoModel shareUserInfo].userInfoModel.username;
    [contactView addSubview:self.numberTxtField];
    
    //========address=======
    self.addressView = [[UIView alloc] initWithFrame:CGRectMake(10, contactView.bottom_sd + 10, contentView.width_sd, 50)];
    self.addressView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.addressView];
    
    self.addressTxtField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, self.addressView.width_sd - 60, contactView.height_sd)];
    self.addressTxtField.font = [UIFont systemFontOfSize:14];
    self.addressTxtField.leftView = [self txtFieldLeftView:@"地址: "];
    self.addressTxtField.textColor = UIColorFromRGB(0x999999);
    self.addressTxtField.leftViewMode = UITextFieldViewModeAlways;
    self.addressTxtField.enabled = NO;
    if ([SYLoginInfoModel shareUserInfo].configInfoModel.sipInfoList.count > 0) {
        SipInfoModel *model = [SYLoginInfoModel shareUserInfo].configInfoModel.sipInfoList.firstObject;
        self.addressTxtField.text = model.house_address;
    }
    [self.addressView addSubview:self.addressTxtField];
    
    UIButton *moreAddressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreAddressBtn.frame = CGRectMake(self.addressTxtField.right_sd, 0, contentView.width_sd - self.addressTxtField.right_sd, self.addressView.height_sd);
    [moreAddressBtn  addTarget:self action:@selector(moreAddressClick:) forControlEvents:UIControlEventTouchUpInside];
    [moreAddressBtn setImage:[UIImage imageNamed:@"sy_login_icon_userhistory_hidden"] forState:UIControlStateNormal];
    [self.addressView addSubview:moreAddressBtn];

    float fAddressMoreViewHeight = ([SYLoginInfoModel shareUserInfo].configInfoModel.sipInfoList.count <= 3 ? [SYLoginInfoModel shareUserInfo].configInfoModel.sipInfoList.count : 3) * 30;
    self.addressMoreView = [[UIView alloc] initWithFrame:CGRectMake(self.addressView.left, self.addressView.bottom_sd + 3, self.addressView.width_sd, fAddressMoreViewHeight)];
    self.addressMoreView.backgroundColor = [UIColor whiteColor];
    self.addressMoreView.layer.borderColor = UIColorFromRGB(0x999999).CGColor;
    self.addressMoreView.layer.borderWidth = 1;
    self.addressMoreView.hidden = YES;
    [self.view addSubview:self.addressMoreView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,self.addressMoreView.width_sd, fAddressMoreViewHeight) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.addressMoreView addSubview:tableView];
    
    
    //===提交按钮==
    self.submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.submitBtn.frame = CGRectMake(0, 0, 44, 44);
    self.submitBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [self.submitBtn addTarget:self action:@selector(submitClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:self.submitBtn];
    UIBarButtonItem *flexSpacerl = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    self.navigationItem.rightBarButtonItems = @[flexSpacerl, backItem];
}

- (UIView *)txtFieldLeftView:(NSString *)str{
    
    UIFont *font = [UIFont systemFontOfSize:12];
    CGSize size = [str sizeWithFont:font andSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, 50)];
    
    UILabel *leftViewLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, leftView.width_sd, leftView.height_sd)];
    leftViewLab.font = font;
    leftViewLab.text = str;
    [leftView addSubview:leftViewLab];
    
    return leftView;
}

//提交新工单
- (void)submitNewRepairImageURL:(NSString *)imageURL{
    
    NSString *roomID;
    if ([SYLoginInfoModel shareUserInfo].configInfoModel.sipInfoList.count > self.addressIndex) {
        SipInfoModel *model = [[SYLoginInfoModel shareUserInfo].configInfoModel.sipInfoList objectAtIndex:self.addressIndex];
        roomID = model.house_id;
    }

    WEAK_SELF;
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    [communityHttpDAO submitNewRepairWithUserID:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id WithOrderNature:self.oderType WithImageURL:imageURL WithLinkMan:self.contactTxtField.text WithPhone:self.numberTxtField.text WithRoomID:roomID WithServiceContent:self.contentTxtView.text Succeed:^{
        
        [weakSelf showSuccessWithContent:@"提交成功" duration:1];
        [FrameManager popViewControllerAnimated:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_RepairOrderComplete object:nil];
        });
        
    } fail:^(NSError *error) {
        [weakSelf showErrorWithContent:[NSString stringWithFormat:@"%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]] duration:1];
    }];
}

- (void)viewResignFirstResponder{
    self.addressMoreView.hidden = YES;
    [self.contentTxtView resignFirstResponder];
    [self.contactTxtField resignFirstResponder];
    [self.numberTxtField resignFirstResponder];
}


#pragma mark - event
- (void)submitClick:(UIButton *)btn{

    [self.view endEditing:YES];
    
    NSString *content = nil;
    if ([SYAppConfig contactIsEmpty:self.contentTxtView.text]){
        content = @"请输入工单内容";
    }
    else if ([SYAppConfig contactIsEmpty:self.contactTxtField.text]){
        content = @"请输入联系人";
    }
    else if ([SYAppConfig contactIsEmpty:self.numberTxtField.text]){
        content = @"请输入联系人电话";
    }
    
    if (content) {
        [self showMessageWithContent:content duration:1];
        return;
    }

    
    WEAK_SELF;
    [self showWithContent:@"提交中"];
    SYPersonalSpaceHttpDAO *personalSpaceHttpDAO = [[SYPersonalSpaceHttpDAO alloc] init];
    NSMutableString *str = [[NSMutableString alloc] init];
    __block int nCount = self.addImgViewMArr.count;
    [personalSpaceHttpDAO uploadImgToQiniuWithImgArr:self.addImgViewMArr Succeed:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {

        [str appendString:[NSString stringWithFormat:@"%@,", key]];
        nCount--;
        if (nCount <= 0) {
            [weakSelf submitNewRepairImageURL:str.length > 0 ? str : nil];
        }
    } fail:^(NSError *error) {
        nCount--;
        if (nCount <= 0) {
             [weakSelf submitNewRepairImageURL:nil];
        }
    }];
}

- (void)moreAddressClick:(UIButton *)btn{
    self.addressMoreView.hidden = !self.addressMoreView.hidden;
}


#pragma mark - SYNewRepairAddImgViewCollectionViewCellDelegate
- (void)delImgView:(NSIndexPath *)indexPath{
    
    if (self.addImgViewMArr.count > indexPath.row) {
        [self.addImgViewMArr removeObjectAtIndex:indexPath.row];
        [self.imgViewCollectionView reloadData];
    }
}


#pragma mark - collection deleagte
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.addImgViewMArr.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identify = @"SYNewRepairAddImgViewCollectionViewCell";
    SYNewRepairAddImgViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.backgroundColor = UIColorFromRGB(0xffffff);

    UIImage *img = nil;
    if (self.addImgViewMArr.count > indexPath.row) {
        img = [self.addImgViewMArr objectAtIndex:indexPath.row];
    }
    [cell updateImg:img];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self viewResignFirstResponder];
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        if (status != PHAuthorizationStatusAuthorized) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:@"请选取" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍摄" otherButtonTitles:@"照片库",@"照片多选", nil];
            
            [sheet showInView:self.view];
        });
    }];
}


#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    CorePhotoPickerVCMangerType type = CorePhotoPickerVCMangerTypeCamera;

    if (buttonIndex == 0) type=CorePhotoPickerVCMangerTypeCamera;
    
    if (buttonIndex == 1) type=CorePhotoPickerVCMangerTypeSinglePhoto;
    
    if (buttonIndex == 2) type=CorePhotoPickerVCMangerTypeMultiPhoto;
    
    if (buttonIndex == 3) return;
    
    CorePhotoPickerVCManager *manager=[CorePhotoPickerVCManager sharedCorePhotoPickerVCManager];
    
    //设置类型
    manager.pickerVCManagerType = type;
    
    //最多可选3张
    manager.maxSelectedPhotoNumber = 3;
    
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
         
            [weakSelf.addImgViewMArr addObject:photo.editedImage];
            if (weakSelf.addImgViewMArr.count > 3) {
                @synchronized (weakSelf.addImgViewMArr) {
                    [weakSelf.addImgViewMArr removeObjectsInRange:NSMakeRange(weakSelf.addImgViewMArr.count - 4, weakSelf.addImgViewMArr.count - 3)];
                }
            }
            if (medias.count - 1 == idx) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.imgViewCollectionView reloadData];
                });
            }
        }];
    };
    
    [self presentViewController:pickerVC animated:YES completion:nil];
}


#pragma mark - textView delegate
- (void)textViewDidChange:(UITextView *)textView{
    
    NSString *strMessage = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (strMessage.length >= 100) {
        textView.text = [textView.text substringToIndex:100];
    }
    
    NSString *leftNumber = [NSString stringWithFormat:@"%u",100 - textView.text.length];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"还剩%@个字", leftNumber]];
    [attStr setAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xd23023)} range:NSMakeRange(2, leftNumber.length)];
    self.leftLetters.attributedText = attStr;
}


#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [SYLoginInfoModel shareUserInfo].configInfoModel.sipInfoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identify = @"UITableViewCell";
    UITableViewCell *settingableViewCell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!settingableViewCell) {
        settingableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        settingableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        settingableViewCell.textLabel.textColor = UIColorFromRGB(0x999999);
    }
    
    if ([SYLoginInfoModel shareUserInfo].configInfoModel.sipInfoList.count > indexPath.row) {
        SipInfoModel *model = [[SYLoginInfoModel shareUserInfo].configInfoModel.sipInfoList objectAtIndex:indexPath.row];
        settingableViewCell.textLabel.text = model.house_address;
    }

    return settingableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([SYLoginInfoModel shareUserInfo].configInfoModel.sipInfoList.count > indexPath.row) {
        SipInfoModel *model = [[SYLoginInfoModel shareUserInfo].configInfoModel.sipInfoList objectAtIndex:indexPath.row];
        self.addressTxtField.text = model.house_address;
        self.addressIndex = indexPath.row;
    }
    self.addressMoreView.hidden = YES;
}


#pragma mark - touchesBegan delegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self viewResignFirstResponder];
}
@end
