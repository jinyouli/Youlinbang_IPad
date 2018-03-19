//
//  SYRepairOrderCompleteViewController.m
//  YLB
//
//  Created by sayee on 17/4/13.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYRepairOrderCompleteViewController.h"
#import <Photos/Photos.h>
#import "CorePhotoPickerVCManager.h"
#import "SYNewRepairAddImgViewCollectionViewCell.h"
#import "SYCommunityHttpDAO.h"
#import "SYPersonalSpaceHttpDAO.h"

typedef enum : NSUInteger {
    StarOneBtnTag,
    StarTwoBtnTag,
    StarThreeBtnTag,
    StarFourBtnTag,
    StarFiveBtnTag,
    SubmitBtnTag
} BtnTag;

@interface SYRepairOrderCompleteViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate, SYNewRepairAddImgViewCollectionViewCellDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UITextView *contentTxtView;
@property (nonatomic, strong) UILabel *leftLetters; //还剩多少个字
@property (nonatomic, retain) UICollectionView *imgViewCollectionView;

@property (nonatomic, strong) NSMutableArray *addImgViewMArr;
@property (nonatomic, assign) RepairOrderCompleteType type;
@property (nonatomic, copy) NSString *repairID;
@property (nonatomic, strong) NSMutableArray *scoreBtnMArr;
@property (nonatomic, assign) int nScore;
@end

@implementation SYRepairOrderCompleteViewController

- (instancetype)initWithRepairID:(NSString *)repairID RepairOrderCompleteType:(RepairOrderCompleteType)type{
    
    if (self = [super init]) {
        self.repairID = repairID;
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.addImgViewMArr = [[NSMutableArray alloc] init];
    self.scoreBtnMArr = [[NSMutableArray alloc] init];
    [self initUI];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - overwrite
- (NSString *)backBtnTitle{
    if (self.type == RepairOrderCompleteYesType) {
        return @"确认完成";
    }
    return @"返单";
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
    
    NSString *leftNumber = [NSString stringWithFormat:@"%u",100 - self.contentTxtView.text.length];
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
    
    
    //分数
    if (self.type == RepairOrderCompleteYesType) {
        UIView *scoreView = [[UIView alloc] initWithFrame:CGRectMake(contentView.left_sd, contentView.bottom_sd + 10, contentView.width_sd, 100)];
        scoreView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:scoreView];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, scoreView.width_sd, 20)];
        lab.text = @"请选择满意度星级";
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = UIColorFromRGB(0x999999);
        [scoreView addSubview:lab];

        float fMargin = (scoreView.width_sd - 30 * 5) / 6.0;
        for (int i = 0; i < 5; i++) {
            
            UIButton *scoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            scoreBtn.frame = CGRectMake((i * 30) + (i * fMargin) + fMargin, lab.bottom_sd + 20, 30, 30);
            scoreBtn.tag = i;
            [scoreBtn setImage:[UIImage imageNamed:@"sy_comment_normal"] forState:UIControlStateNormal];
            [scoreBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [scoreView addSubview:scoreBtn];
            
            [self.scoreBtnMArr addObject:scoreBtn];
        }
    }
    
    //===提交按钮==
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(0, 0, 44, 44);
    submitBtn.tag = SubmitBtnTag;
    submitBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:submitBtn];
    UIBarButtonItem *flexSpacerl = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    self.navigationItem.rightBarButtonItems = @[flexSpacerl, backItem];
}

//提交
- (void)submitNewRepairImageURL:(NSString *)imageURL{

    WEAK_SELF;
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];

    //返单
    if (self.type == RepairOrderCompleteBackType) {
        [communityHttpDAO saveRepairsRecordWithUserID:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id WithType:OrderGetBack WithRepairsID:self.repairID WithContent:self.contentTxtView.text WithOwner:1 WithImageURL:imageURL Succeed:^{
            
            [weakSelf showSuccessWithContent:@"返单成功" duration:1];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_RepairOrderGetBack object:nil];
                [weakSelf performSelector:@selector(popViewController) withObject:nil afterDelay:1];
            });
        } fail:^(NSError *error) {
            [weakSelf showErrorWithContent:[error.userInfo objectForKey:@"NSLocalizedDescription"] duration:1];
        }];
    }
    else if (self.type == RepairOrderCompleteYesType){

        [communityHttpDAO updateRepairsToFinishWithUserID:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id WithRepairsID:self.repairID WithScore:self.nScore Succeed:^{
            
            [weakSelf showSuccessWithContent:@"确认成功" duration:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_RepairOrderComplete object:nil];
                [weakSelf performSelector:@selector(popViewController) withObject:nil afterDelay:1];
            });
        } fail:^(NSError *error) {
            [weakSelf showErrorWithContent:[error.userInfo objectForKey:@"NSLocalizedDescription"] duration:1];
        }];
    }
}

- (void)popViewController{
     [FrameManager popViewControllerAnimated:YES];
}


#pragma mark - event
- (void)btnClick:(UIButton *)btn{
    
    [self.view endEditing:YES];
    
    if (btn.tag == SubmitBtnTag) {
        
        WEAK_SELF;
        [self showWithContent:@"提交中"];
        //上传图片到7牛
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
    else{
        self.nScore = btn.tag + 1;
        [self.scoreBtnMArr enumerateObjectsUsingBlock:^(UIButton *scoreBtn, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (idx <= btn.tag) {
                [scoreBtn setImage:[UIImage imageNamed:@"sy_comment_select"] forState:UIControlStateNormal];
            }
            else{
                [scoreBtn setImage:[UIImage imageNamed:@"sy_comment_normal"] forState:UIControlStateNormal];
            }
        }];
    }
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
    
    [self.contentTxtView resignFirstResponder];
    
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


#pragma mark - touchesBegan delegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.contentTxtView resignFirstResponder];
}
@end
