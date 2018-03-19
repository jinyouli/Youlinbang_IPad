//
//  SYPropertyRepairViewController.m
//  YLB
//
//  Created by YAYA on 2017/4/2.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYPropertyRepairViewController.h"
#import "SYCustomScrollView.h"
#import "SYNewRepairViewController.h"
#import <Photos/Photos.h>
#import "CorePhotoPickerVCManager.h"
#import "SYCommunityHttpDAO.h"
#import "SYPersonalSpaceHttpDAO.h"
#import "SYGeTuiModel.h"

typedef enum : NSUInteger {
    NewRepairBtnTag,
    sendCommentBtnTag,
    AddImgBtnTag,
    HideCommentMaskBtnTag
} BtnTag;

@interface SYPropertyRepairViewController ()<UIScrollViewDelegate, UIActionSheetDelegate, SYPropertyRepairViewDelegate>
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIView *segmentBottomLine;
@property (nonatomic, strong) SYCustomScrollView *customScrollView;
@property (nonatomic, assign) RepairListOrderType oderType;

@property (nonatomic, strong) SYPropertyRepairView *propertyNoFixView;
@property (nonatomic, strong) SYPropertyRepairView *propertyFixingiew;
@property (nonatomic, strong) SYPropertyRepairView *propertyNoComfirmView;
@property (nonatomic, strong) SYPropertyRepairView *propertyFinishView;

@property (nonatomic, strong) UIView *commentBottomView;    //评论区域
@property (nonatomic, strong) UITextField *commentTxtField; //评论
@property (nonatomic, strong) UIButton *hideCommentMaskBtn; //用于取消评论的第一响应者
@property (nonatomic, strong) UIButton *sendCommentBtn;
@property (nonatomic, strong) NSMutableArray *addImgViewMArr;   //评论添加图片
@property (nonatomic, strong) NSMutableArray *addImgMArr;   //从相册选择的图片

@property (nonatomic, assign) float commentViewHeight;    //评论区域高度（添加图片后高度会增高）
@property (nonatomic, assign) float keyBoardDuration;   //键盘弹起速度
@property (nonatomic, assign) float keyBoardHeight;   //键盘高度

@property (nonatomic, strong) NSIndexPath *indexInpath;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) SYPropertyRepairModel *propertyRepairModel;
@property (nonatomic, copy) NSString *titleStr;
@end

@implementation SYPropertyRepairViewController

- (instancetype)initWithRepairListOrderType:(RepairListOrderType)type WithTitle:(NSString *)title{
    if (self = [super init]) {
        self.oderType = type;
        self.titleStr = title;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.commentTxtField resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //====物业报修====
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repairsNotic:) name:SYNOTICE_RepairsGetNotification object:nil]; // 接单
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repairsNotic:) name:SYNOTICE_RepairsReplyNotification object:nil];// 回复
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repairsNotic:) name:SYNOTICE_RepairsCompleteNotification object:nil]; // 完成工单

    self.addImgViewMArr = [[NSMutableArray alloc] init];
    self.addImgMArr = [[NSMutableArray alloc] init];
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
    
    //=====顶部  @"未处理", @"处理中", @"待确认", @"已完结"=========
    float fSegmentedControlHeight = 40;
    NSArray *itemArr = [[NSArray alloc] initWithObjects:@"未处理", @"处理中", @"待确认", @"已完结", nil];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArr];
    self.segmentedControl.frame = CGRectMake(0, 0, self.view.width_sd, fSegmentedControlHeight);
    self.segmentedControl.backgroundColor = [UIColor whiteColor];
    self.segmentedControl.tintColor = [UIColor clearColor];
    [self.segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x999999), NSFontAttributeName : [UIFont systemFontOfSize:14.0]} forState:UIControlStateNormal];
    [self.segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName :  UIColorFromRGB(0xf23023), NSFontAttributeName : [UIFont systemFontOfSize:14.0]} forState:UIControlStateSelected];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlSelect:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.view addSubview:self.segmentedControl];
    
    self.segmentBottomLine = [[UIView alloc] initWithFrame:CGRectMake(self.segmentedControl.selectedSegmentIndex * (self.segmentedControl.width / itemArr.count), fSegmentedControlHeight - 4, (self.segmentedControl.width + 0) / itemArr.count, 4)];
    self.segmentBottomLine.backgroundColor = UIColorFromRGB(0xf23023);
    [self.segmentedControl addSubview:self.segmentBottomLine];
    

    //======中间各种报修单========
    self.customScrollView = [[SYCustomScrollView alloc] initWithFrame:CGRectMake(0, self.segmentedControl.bottom_sd, self.view.width_sd, self.view.height_sd - self.segmentedControl.bottom_sd - 64)];
    self.customScrollView.contentSize = CGSizeMake(self.view.width * itemArr.count, self.customScrollView.height_sd);
    self.customScrollView.delegate = self;
    self.customScrollView.pagingEnabled = YES;
    self.customScrollView.bounces = NO;
    self.customScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.customScrollView];
    
    //添加报修单view
    self.propertyNoFixView = [[SYPropertyRepairView alloc] initWithFrame:[self getPropertyViewRect:0] WithType:propertyNoFixViewType WithOderType:self.oderType];
    self.propertyFixingiew = [[SYPropertyRepairView alloc] initWithFrame:[self getPropertyViewRect:1] WithType:propertyFixingiewType WithOderType:self.oderType];
    self.propertyNoComfirmView = [[SYPropertyRepairView alloc] initWithFrame:[self getPropertyViewRect:2] WithType:propertyNoComfirmViewType WithOderType:self.oderType];
    self.propertyFinishView = [[SYPropertyRepairView alloc] initWithFrame:[self getPropertyViewRect:3] WithType:propertyFinishViewType WithOderType:self.oderType];
    [self.customScrollView addSubview:self.propertyNoFixView];
    [self.customScrollView addSubview:self.propertyFixingiew];
    [self.customScrollView addSubview:self.propertyNoComfirmView];
    [self.customScrollView addSubview:self.propertyFinishView];
    self.propertyNoFixView.delegate = self;
    self.propertyFixingiew.delegate = self;
    self.propertyNoComfirmView.delegate = self;
    self.propertyFinishView.delegate = self;

    //==========新建按钮=======
    UIButton *newRepairBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    newRepairBtn.frame = CGRectMake(0, 0, 60, 44);
    newRepairBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [newRepairBtn setTitle:@"新建" forState:UIControlStateNormal];
    newRepairBtn.tag = NewRepairBtnTag;
    [newRepairBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:newRepairBtn];
    UIBarButtonItem *flexSpacerl = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    flexSpacerl.width = -15;
    self.navigationItem.rightBarButtonItems = @[flexSpacerl, backItem];
    
    
    //=======底部评论区域====
    //用于取消评论的第一响应者
    self.hideCommentMaskBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.hideCommentMaskBtn.frame = self.view.bounds;
    self.hideCommentMaskBtn.hidden = YES;
    self.hideCommentMaskBtn.tag = HideCommentMaskBtnTag;
    self.hideCommentMaskBtn.backgroundColor = [UIColor clearColor];
    [self.hideCommentMaskBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.hideCommentMaskBtn];
    
    self.commentBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height_sd, self.view.width_sd, 110)];
    self.commentBottomView.backgroundColor = UIColorFromRGB(0xebebeb);
    [self.view addSubview:self.commentBottomView];

    self.sendCommentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendCommentBtn.frame = CGRectMake(self.view.width_sd - 10 - 60, 5, 60, 30);
    self.sendCommentBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.sendCommentBtn setTitle:@"发送" forState:UIControlStateNormal];
    self.sendCommentBtn.tag = sendCommentBtnTag;
    [self.sendCommentBtn setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
    [self.sendCommentBtn setTitleColor:UIColorFromRGB(0xEC5F05) forState:UIControlStateHighlighted];
    [self.sendCommentBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentBottomView addSubview:self.sendCommentBtn];
    
    UIButton *addImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addImgBtn.frame = CGRectMake(self.sendCommentBtn.left_sd - 30 - 10, 0, 30, 30);
    [addImgBtn setImage:[UIImage imageNamed:@"sy_camera_normal"] forState:UIControlStateNormal];
    [addImgBtn setImage:[UIImage imageNamed:@"sy_camera_select"] forState:UIControlStateHighlighted];
    [addImgBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    addImgBtn.tag = AddImgBtnTag;
    addImgBtn.center = CGPointMake(addImgBtn.centerX, self.sendCommentBtn.centerY);
    [self.commentBottomView addSubview:addImgBtn];
    
    self.commentTxtField = [[UITextField alloc] initWithFrame:CGRectMake(15, 5, addImgBtn.left_sd - 25, 30)];
    self.commentTxtField.font = [UIFont systemFontOfSize:14];
    self.commentTxtField.placeholder = @"来评论一番吧!";
    self.commentTxtField.center = CGPointMake(self.commentTxtField.centerX, self.sendCommentBtn.centerY);
    [self.commentBottomView addSubview:self.commentTxtField];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(self.commentTxtField.left_sd, self.commentTxtField.bottom_sd, self.commentTxtField.width_sd, 1)];
    line.backgroundColor = UIColorFromRGB(0x999999);
    [self.commentBottomView addSubview:line];
    
    for (int i = 0; i < 3; i++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(i * 50 + ((i + 1) * 15), line.bottom_sd + 10, 55, 55)];
        [self.commentBottomView addSubview:imgView];
        [self.addImgViewMArr addObject:imgView];
    }
    
    self.commentViewHeight = 40;
}

//@"未处理", @"处理中", @"待确认", @"已完结" 的frame
- (CGRect)getPropertyViewRect:(NSInteger)index {
    CGRect rect = self.view.bounds;
    rect.size.height = self.customScrollView.height_sd;
    rect.origin.y = 0;
    rect.origin.x = self.view.width * index;
    return rect;
}

- (void)tableViewSetNil{
    self.tableView.mj_footer.hidden = NO;
    self.indexInpath = nil;
    self.tableView = nil;
}

//提交评论
- (void)submitCommentWithImageURL:(NSString *)imageURL{
    
    WEAK_SELF;
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    [communityHttpDAO saveRepairsRecordWithUserID:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id WithType:OrderComment WithRepairsID:self.propertyRepairModel.repair_id WithContent:self.commentTxtField.text WithOwner:1 WithImageURL:imageURL Succeed:^{
        
        [weakSelf dismissHud:YES];
        [weakSelf.tableView.mj_header beginRefreshing];
    } fail:^(NSError *error) {
        [weakSelf showErrorWithContent:[error.userInfo objectForKey:@"NSLocalizedDescription"] duration:1];
    }];
}

- (void)changeScrollViewContentOffsetWithIndex:(int)index{
    [self.customScrollView setContentOffset:CGPointMake(self.view.width * index, 0) animated:YES];
    
    WEAK_SELF;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.segmentBottomLine.frame = CGRectMake(index * weakSelf.segmentBottomLine.frame.size.width, weakSelf.segmentBottomLine.frame.origin.y, weakSelf.segmentBottomLine.frame.size.width, weakSelf.segmentBottomLine.frame.size.height);
    }];
}


#pragma mark - event
- (void)btnClick:(UIButton *)btn{

    if (btn.tag == NewRepairBtnTag) {
        SYNewRepairViewController *vc = [[SYNewRepairViewController alloc] initWithRepairListOrderType:self.oderType WithTitle:[NSString stringWithFormat:@"新建%@",self.titleStr]];
        [FrameManager pushViewController:vc animated:YES];
        [self.commentTxtField resignFirstResponder];
    }else if (btn.tag == sendCommentBtnTag) {

        NSString *temp = [self.commentTxtField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (self.addImgMArr.count == 0 && [temp length] == 0) {
            [self.commentTxtField resignFirstResponder];
            self.commentTxtField.text = nil;
            return;
        }
        
        WEAK_SELF;
        //上传图片到7牛
        SYPersonalSpaceHttpDAO *personalSpaceHttpDAO = [[SYPersonalSpaceHttpDAO alloc] init];
        NSMutableString *str = [[NSMutableString alloc] init];
        __block int nCount = self.addImgMArr.count;
        [personalSpaceHttpDAO uploadImgToQiniuWithImgArr:self.addImgMArr Succeed:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            
            [str appendString:[NSString stringWithFormat:@"%@,", key]];
            nCount--;
            if (nCount <= 0) {
                [weakSelf submitCommentWithImageURL:str.length > 0 ? str : nil];
            }
        } fail:^(NSError *error) {
            nCount--;
            if (nCount <= 0) {
                [weakSelf submitCommentWithImageURL:nil];
            }
        }];
        [self.commentTxtField resignFirstResponder];
        self.commentTxtField.text = nil;
    }else if (btn.tag == AddImgBtnTag) {
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
            if (status != PHAuthorizationStatusAuthorized) return;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选取" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍摄" otherButtonTitles:@"照片库",@"照片多选", nil];
                [sheet showInView:self.view];
            });
        }];
    }else if (btn.tag == HideCommentMaskBtnTag){
        [self.commentTxtField resignFirstResponder];
    }
}

- (void)segmentedControlSelect:(UISegmentedControl *)segmentedCtl{
 
    [self changeScrollViewContentOffsetWithIndex:segmentedCtl.selectedSegmentIndex];
}


#pragma mark - noti
-(void)keyboardWillShow:(NSNotification*)notification{
    
    NSDictionary *info = [notification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.keyBoardDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.keyBoardHeight = kbSize.height;
    
    WEAK_SELF;
    [UIView animateWithDuration:self.keyBoardDuration animations:^{
        weakSelf.commentBottomView.frame = (CGRect){{weakSelf.commentBottomView.left_sd, weakSelf.view.height_sd - kbSize.height - weakSelf.commentViewHeight}, weakSelf.commentBottomView.size};
    }];
    
    self.hideCommentMaskBtn.hidden = NO;
}

-(void)keyboardWillHide:(NSNotification*)notification{
    
    NSDictionary *info = [notification userInfo];
    double keyBoardDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    WEAK_SELF;
    [UIView animateWithDuration:keyBoardDuration animations:^{
        weakSelf.commentBottomView.frame = (CGRect){{weakSelf.commentBottomView.left_sd, weakSelf.view.height_sd}, weakSelf.commentBottomView.size};
    } completion:^(BOOL finished) {
        [weakSelf.addImgMArr removeAllObjects];
    }];
    self.hideCommentMaskBtn.hidden = YES;
    self.commentViewHeight = 40;
    
    [self.tableView scrollToRowAtIndexPath:self.indexInpath atScrollPosition:UITableViewScrollPositionNone animated:YES];

    [self performSelector:@selector(tableViewSetNil) withObject:nil afterDelay:0.25];
}

- (void)repairsNotic:(NSNotification *)noti{

    [self.propertyNoFixView updataTableView];
    [self.propertyFixingiew updataTableView];
    [self.propertyNoComfirmView updataTableView];
    [self.propertyFinishView updataTableView];
    
    NSDictionary *dic = [noti userInfo];
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    SYGeTuiModel *getuiModel = [SYGeTuiModel mj_objectWithKeyValues:dic];
    //接单
    if ([getuiModel.cmd isEqualToString:SYREPAIRS_GET]) {
        [self changeScrollViewContentOffsetWithIndex:1];
        [self.segmentedControl setSelectedSegmentIndex:1];
    }
    else if ([getuiModel.cmd isEqualToString:SYREPAIRS_COMPLETE]) { // 完成工单
        [self changeScrollViewContentOffsetWithIndex:2];
        [self.segmentedControl setSelectedSegmentIndex:2];
    }
    [self.commentTxtField resignFirstResponder];
}


#pragma mark - scrollview delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    double page = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
    
    if (self.segmentedControl.selectedSegmentIndex == page) {
        return;
    }
    
    WEAK_SELF;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.segmentBottomLine.frame = CGRectMake(page * weakSelf.segmentBottomLine.frame.size.width, weakSelf.segmentBottomLine.frame.origin.y, weakSelf.segmentBottomLine.frame.size.width, weakSelf.segmentBottomLine.frame.size.height);
    }];
    self.segmentedControl.selectedSegmentIndex = page;
}


#pragma mark -  SYPropertyRepairViewDelegate
- (void)commentBtnClickWithPropertyRepairType:(PropertyRepairType)propertyRepairType RepairListOrderType:(RepairListOrderType)orderType TableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath PropertyRepairModel:(SYPropertyRepairModel *)model{

    [self.commentTxtField becomeFirstResponder];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    CGRect rect = [cell.superview convertRect:cell.frame toView:window];
    
    CGFloat delta = CGRectGetMaxY(rect) - (window.bounds.size.height - self.keyBoardHeight - self.commentViewHeight);
    
    CGPoint offset = tableView.contentOffset;
    offset.y += delta;
    if (offset.y < 0) {
        offset.y = 0;
    }
    [tableView setContentOffset:offset animated:YES];
    
    self.indexInpath = indexPath;
    self.tableView = tableView;
    tableView.mj_footer.hidden = YES;
    self.propertyRepairModel = model;
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
    
    WEAK_SELF;
    //选取结束
    manager.finishPickingMedia = ^(NSArray *medias){
        
        [medias enumerateObjectsUsingBlock:^(CorePhoto *photo, NSUInteger idx, BOOL *stop) {
            
            [weakSelf.addImgMArr addObject:photo.editedImage];
            if (weakSelf.addImgMArr.count > 3) {
                [weakSelf.addImgMArr removeObjectsInRange:NSMakeRange(weakSelf.addImgMArr.count - 4, weakSelf.addImgMArr.count - 3)];
            }
        }];
        
        if (medias.count > 0) {
            weakSelf.commentViewHeight = weakSelf.commentBottomView.height_sd;
            
            dispatch_async(dispatch_get_main_queue(), ^{
       
                for (int i = 0; i < weakSelf.addImgMArr.count; i++) {
                    
                    if (weakSelf.addImgViewMArr.count > i) {
                        UIImageView *imgView = [weakSelf.addImgViewMArr objectAtIndex:i];
                        imgView.image = [weakSelf.addImgMArr objectAtIndex:i];
                    }
                }
                [weakSelf.commentTxtField becomeFirstResponder];
            });
        }
    };
    
    [self presentViewController:pickerVC animated:YES completion:nil];
}

@end
