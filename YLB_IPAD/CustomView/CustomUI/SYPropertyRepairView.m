//
//  SYPropertyRepairView.m
//  YLB
//
//  Created by YAYA on 2017/4/2.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYPropertyRepairView.h"
#import "SYPropertyRepairTableViewCell.h"
#import "SYCommunityHttpDAO.h"
#import "SYCustomAlertView.h"
#import "SYRepairOrderCompleteViewController.h"
#import "SYHistoryCommentViewController.h"

@interface SYPropertyRepairView ()<UITableViewDataSource, UITableViewDelegate, SYPropertyRepairTableViewCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) PropertyRepairType status;
@property (nonatomic, assign) RepairListOrderType oderType;
@property (nonatomic, strong) NSMutableArray *sourcesMArr;
@property (nonatomic, assign) int nCurrentPage;
@property (nonatomic, assign) float commentImgHeight;   //工单图片高度
@end

@implementation SYPropertyRepairView

- (instancetype)initWithFrame:(CGRect)frame WithType:(PropertyRepairType)type WithOderType:(RepairListOrderType)oderType{
    if (self = [super initWithFrame:frame]) {
        self.status = type;
        self.oderType = oderType;
        self.nCurrentPage = 1;
        self.commentImgHeight = (kNameWidth - 10.0) / 3.0;
        self.commentImgHeight = self.commentImgHeight > 73 ? 73 : self.commentImgHeight;
        
        self.sourcesMArr = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reflashTableView) name:SYNOTICE_RepairOrderGetBack object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reflashTableView) name:SYNOTICE_RepairOrderComplete object:nil];
        
        [self initUI];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - public
- (void)updataTableView{
    [self getPropertyRepairsListWithMore:NO];
}


#pragma mark - private
- (void)initUI{
    
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = UIColorFromRGB(0xebebeb);
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self addSubview:self.tableView];
    
    WEAK_SELF;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getPropertyRepairsListWithMore:NO];
    }];

    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getPropertyRepairsListWithMore:YES];
    }];
    
    [self.tableView.mj_header beginRefreshing];
}

//物业报修列表    isMore 是否下拉刷新
- (void)getPropertyRepairsListWithMore:(BOOL)isMore{

    //===roomID 拼接====
    NSMutableString *roomID = [[NSMutableString alloc] init];
    for (int i = 0 ; i < [SYLoginInfoModel shareUserInfo].configInfoModel.sipInfoList.count ; i++) {
        SipInfoModel *model = [[SYLoginInfoModel shareUserInfo].configInfoModel.sipInfoList objectAtIndex:i];
        if (model.house_id) {
            if (i == [SYLoginInfoModel shareUserInfo].configInfoModel.sipInfoList.count - 1) {
                [roomID appendString:[NSString stringWithFormat:@"%@", model.house_id]];
            }else{
                [roomID appendString:[NSString stringWithFormat:@"%@,", model.house_id]];
            }
        }
    }

    if (isMore) {
        self.nCurrentPage++;
    }else{
        self.nCurrentPage = 1;
    }
    
    WEAK_SELF;
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    [communityHttpDAO getRepairsListWithCurrentPage:self.nCurrentPage WithOrderType:self.oderType WithPageSize:20 WithStatus:self.status WithRoomIDs:roomID Succeed:^(NSArray *modelArr) {
        
        if (modelArr) {
            @synchronized (weakSelf.sourcesMArr) {
                if (!isMore) {
                    [weakSelf.sourcesMArr removeAllObjects];
                }
                
                weakSelf.tableView.mj_footer.hidden = modelArr.count == 0 ? YES : NO;   //上拉没有更多消息时，隐藏footer
                
                //===============计算高度=============
                //20自己的名字高度、16地址lab高度   16 timelab  30 底部按钮攻读   其余都是magtin (见SYPropertyRepairTableViewCell)
                for (SYPropertyRepairModel *model in modelArr) {
                    float fHeight = 18 + 20 + 16 + 16 + 20 + 70;
                    CGSize size = [model.fservicecontent sizeWithFont:[UIFont systemFontOfSize:16] andSize:CGSizeMake(kNameWidth, MAXFLOAT)];
                    fHeight += size.height;
                    if (model.repairs_imag_list.count > 0) {
                        //工单图片高度
                        fHeight += self.commentImgHeight;
                    }
                    model.propertyRepairCellHeight = fHeight;
                    model.fservicecontentHeight = size.height;
                }
                [weakSelf.sourcesMArr addObjectsFromArray:modelArr];
            }
            [weakSelf.tableView reloadData];
        }
        [weakSelf endRefreshWithMore:isMore];
    } fail:^(NSError *error) {
        [weakSelf endRefreshWithMore:isMore];
    }];
}

- (void)endRefreshWithMore:(BOOL)isMore{
    
    if (!isMore) {
        self.tableView.mj_footer.hidden = NO;
        [self.tableView.mj_header endRefreshing];
    }else{
        [self.tableView.mj_footer endRefreshing];
    }
}


#pragma mark -  noti
- (void)reflashTableView{
    [self.tableView.mj_header beginRefreshing];
}


#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sourcesMArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SYPropertyRepairTableViewCell";
    SYPropertyRepairTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SYPropertyRepairTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    cell.indexPath = indexPath;
    
    if (indexPath.row < self.sourcesMArr.count) {
        SYPropertyRepairModel *model = [self.sourcesMArr objectAtIndex:indexPath.row];
        [cell setDataWithPropertyRepairType:self.status OrderType:self.oderType PropertyRepairModel:model];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.sourcesMArr.count) {
        SYPropertyRepairModel *model = [self.sourcesMArr objectAtIndex:indexPath.row];
        return model.propertyRepairCellHeight + model.repairOrderCommentHeight;
    }
    return 0;
}


#pragma mark - SYPropertyRepairTableViewCellDelegate
- (void)propertyBtnClickType:(PropertyBtnClickType)type IndexPath:(NSIndexPath *)indexPath Button:(UIButton *)btn{

    if (indexPath.row >= self.sourcesMArr.count) {
        return;
    }
    
    WEAK_SELF;
    SYPropertyRepairModel *model = [self.sourcesMArr objectAtIndex:indexPath.row];
    
    if (type == PropertyCancelType) {

        SYCustomAlertView *customAlertView = [[SYCustomAlertView alloc] initWithFrame:self.bounds];
        [customAlertView showCustomAlertViewWithTitle:@"确定取消该报修单?" CompleteBlock:^{
            
            [weakSelf showWithContent:nil];
            SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
            [communityHttpDAO saveRepairsRecordWithUserID:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id WithType:OrderCancel WithRepairsID:model.repair_id WithContent:nil WithOwner:1 WithImageURL:nil Succeed:^{
               
                [weakSelf dismissHud:YES];
                [weakSelf.tableView.mj_header beginRefreshing];
            } fail:^(NSError *error) {
                [weakSelf showErrorWithContent:[error.userInfo objectForKey:@"NSLocalizedDescription"] duration:1];
            }];
        }];
        [[UIApplication sharedApplication].keyWindow addSubview:customAlertView];

    }else if (type == PropertyUrgeType) {

        SYCustomAlertView *customAlertView = [[SYCustomAlertView alloc] initWithFrame:self.bounds];
        [customAlertView showCustomAlertViewWithTitle:@"确定向物业发送催单通知?" CompleteBlock:^{
            
            SYCommunityHttpDAO *communityHttpDAO =[[SYCommunityHttpDAO alloc] init];
            [communityHttpDAO reminderWithRepairsID:model.repair_id WithUserID:[SYLoginInfoModel shareUserInfo].userInfoModel.user_id Succeed:^{
                [weakSelf showSuccessWithContent:@"催单成功" duration:1];
            } fail:^(NSError *error) {
                [weakSelf showErrorWithContent:[error.userInfo objectForKey:@"NSLocalizedDescription"] duration:1];
            }];
        }];
        [[UIApplication sharedApplication].keyWindow addSubview:customAlertView];

    }else if (type == PropertExtensionType) {

        //获取评论
        if ([btn.titleLabel.text isEqualToString:@"合起"]) {
            model.isExtensioned = NO;
            model.repairOrderCommentHeight = 0;
            model.repairOrderCommentModelArr = nil;
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            return;
        }else if ([btn.titleLabel.text isEqualToString:@"展开"]){
            model.isExtensioned = YES;
        }else{
            return;
        }
        SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
        [communityHttpDAO getWorkOrderDetailsWithCurrentPage:1 WithRepairsID:model.repair_id WithPageSize:3 Succeed:^(NSArray *modelArr) {
            
            if (modelArr) {
                
                float commentHeight = 0;
                for (SYRepairOrderCommentModel *orderModel in modelArr) {
                    
                    //拼接名字和评论内容
                    NSMutableString *comment = [[NSMutableString alloc] init];
                    [comment appendString:[NSString stringWithFormat:@"%@: ",orderModel.name]];
                    [comment appendString:orderModel.fcontent];
                    
                    CGSize size = [comment sizeWithFont:[UIFont systemFontOfSize:14] andSize:CGSizeMake(kNameWidth, MAXFLOAT)];
                    commentHeight += size.height;
                    
                    orderModel.repairOrderCommentHeight = size.height;
                    
                    if (orderModel.record_imag_list.count > 0) {
                        //评论图片高度
                        commentHeight += (self.commentImgHeight - 20);
                        orderModel.repairOrderCommentImgHeight = (self.commentImgHeight - 20);
                    }
                }
                model.repairOrderCommentHeight = commentHeight + 40;
                model.repairOrderCommentModelArr = modelArr;
                [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        } fail:^(NSError *error) {
            [weakSelf showErrorWithContent:[error.userInfo objectForKey:@"NSLocalizedDescription"] duration:1];
        }];
    }else if (type == PropertyCommentType) {
       
        if ([self.delegate respondsToSelector:@selector(commentBtnClickWithPropertyRepairType:RepairListOrderType:TableView:IndexPath:PropertyRepairModel:)]) {
            [self.delegate commentBtnClickWithPropertyRepairType:self.status RepairListOrderType:self.oderType TableView:self.tableView IndexPath:indexPath PropertyRepairModel:model];
        }
        
    }else if (type == PropertyBackType) {
        
        //跳去返单页面
        SYRepairOrderCompleteViewController *repairOrderCompleteViewController = [[SYRepairOrderCompleteViewController alloc] initWithRepairID:model.repair_id RepairOrderCompleteType:RepairOrderCompleteBackType];
        [FrameManager pushViewController:repairOrderCompleteViewController animated:YES];

    }else if (type == PropertConfirmType) {
        
        //跳去确认工单页面
        SYRepairOrderCompleteViewController *repairOrderCompleteViewController = [[SYRepairOrderCompleteViewController alloc] initWithRepairID:model.repair_id RepairOrderCompleteType:RepairOrderCompleteYesType];
        [FrameManager pushViewController:repairOrderCompleteViewController animated:YES];
    }else if (type == PropertHistoryCommentType) {
        SYHistoryCommentViewController *vc = [[SYHistoryCommentViewController alloc] initWithPropertyRepairModel:model];
        [FrameManager pushViewController:vc animated:YES];
    }
}

@end
