//
//  SYMyCommunityViewController.m
//  YLB
//
//  Created by sayee on 17/4/1.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYMyCommunityViewController.h"
#import "SYMyCommunityTableViewCell.h"
#import "SYCommunityHttpDAO.h"
#import "SYWKWebViewController.h"
#import "UIImageView+WebCache.h"
#import "CycleScrollView.h"
#import "SYRoundHeadView.h"

@interface SYMyCommunityViewController ()<UITableViewDataSource, UITableViewDelegate, SYMyCommunityTableViewCellDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) SYMyCommunityModel *myCommunityModel;
@property (nonatomic, retain) SYRoundHeadView *tableViewHeaderImgView;

@property (nonatomic,strong) CycleScrollView *bannerView;
@property (nonatomic,strong) UIPageControl *pageControl;

@property (nonatomic, retain) UILabel *tableViewNeighborNameLab;
@end

@implementation SYMyCommunityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initUI];
    [self getCommunityInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - overwrite
- (NSString *)backBtnTitle{
    return @"我的社区";
}


#pragma mark - private
- (void)initUI{
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = UIColorFromRGB(0xebebeb);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.tableView.tableHeaderView = [self tableViewHeaderView];
}

- (UIView *)tableViewHeaderView{

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width_sd, (self.view.width_sd * 0.6) + 50)];
    headerView.backgroundColor = UIColorFromRGB(0xebebeb);
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, headerView.width_sd - 20, headerView.height_sd - 10)];
    mainView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:mainView];
    
    self.bannerView = ({
        CycleScrollView *bannerView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, mainView.width_sd, mainView.height_sd - 50) animationDuration:3];
        bannerView.scrollView.showsHorizontalScrollIndicator = NO;
        bannerView.scrollView.showsVerticalScrollIndicator = NO;
        bannerView.scrollView.pagingEnabled = YES;
        bannerView;
    });
    [mainView addSubview:_bannerView];
    
    self.pageControl=({
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.bannerView.left_sd, self.bannerView.height_sd - 20, self.bannerView.width_sd, 20)];
        pageControl;
    });
    [mainView addSubview:_pageControl];
    
    self.tableViewHeaderImgView = [[SYRoundHeadView alloc] initWithFrame:CGRectMake(10, self.bannerView.bottom_sd + 5, 40, 40)];
    [mainView addSubview:self.tableViewHeaderImgView];
    
    self.tableViewNeighborNameLab = [[UILabel alloc] initWithFrame:CGRectMake(self.tableViewHeaderImgView.right_sd + 10, self.tableViewHeaderImgView.top_sd, mainView.width_sd - self.tableViewHeaderImgView.right_sd - 20, 20)];
    [mainView addSubview:self.tableViewNeighborNameLab];
    
    UILabel *contentLab = [[UILabel alloc] initWithFrame:CGRectMake(self.tableViewNeighborNameLab.left_sd, self.tableViewNeighborNameLab.bottom_sd, self.tableViewNeighborNameLab.width_sd, self.tableViewNeighborNameLab.height_sd)];
    contentLab.text = @"欢迎入住本小区";
    contentLab.textColor = UIColorFromRGB(0x999999);
    contentLab.font = [UIFont systemFontOfSize:12];
    [mainView addSubview:contentLab];
    
    return headerView;
}

- (void)updataHeaderView:(SYMyCommunityModel *)model{
    if (!model) {
        return;
    }
    
    SYNeighborMsgModel *neiModel = model.neighbor_msg_list.firstObject;
    self.tableViewNeighborNameLab.text = neiModel.fneibname;
    [self.tableViewHeaderImgView setTitle:neiModel.fneibname withshowWordLength:2];
    
    //===banner===
    self.pageControl.numberOfPages = (!model.imag_list) ? 3 : model.imag_list.count;
    
    WEAK_SELF;
    self.bannerView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        
        weakSelf.pageControl.currentPage = weakSelf.bannerView.currentPageIndex;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, weakSelf.bannerView.width, weakSelf.bannerView.height_sd)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        if (!model.imag_list || (model.imag_list.count - 1) < pageIndex) {
            [imageView setImage:[UIImage imageNamed:@"sy_home_banner_bg_normal"]];
            return imageView;
        }
        
        if (model.imag_list.count > pageIndex) {
            
            SYImagpathModel *adModel = [model.imag_list objectAtIndex:pageIndex];
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",adModel.imagpath]] placeholderImage:[UIImage imageNamed:@"sy_home_banner_bg_normal"]];
        }
        return imageView;
    };
    self.bannerView.totalPagesCount = ^NSInteger(void){
        
        return model.imag_list ? model.imag_list.count : 3;
    };
    self.bannerView.TapActionBlock = ^(NSInteger pageIndex){
        NSLog(@"点击了第%ld个",(long)pageIndex);
        
    };
}

- (void)getCommunityInfo{
    WEAK_SELF;
    SYCommunityHttpDAO *communityHttpDAO = [[SYCommunityHttpDAO alloc] init];
    [communityHttpDAO getNeiborMsgWithDepartmentID:[SYAppConfig shareInstance].bindedModel.neibor_id.department_id Succeed:^(SYMyCommunityModel *model) {
        
        weakSelf.myCommunityModel = model;
        [weakSelf updataHeaderView:model];
        [weakSelf.tableView reloadData];
    } fail:^(NSError *error) {
        
    }];
}


#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.myCommunityModel.html_list.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SYMyCommunityTableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify = @"SYMyCommunityTableViewCell";
    
    SYMyCommunityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[SYMyCommunityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (self.myCommunityModel.neighbor_msg_list.count > 0) {
         SYNeighborMsgModel *neighborMsgModel = self.myCommunityModel.neighbor_msg_list.firstObject;
   
        if (indexPath.row == 0) {
            cell.strTel = neighborMsgModel.ftel;
            [cell updateLeftInfo:[NSString stringWithFormat:@"客服电话: %@",neighborMsgModel.ftel] Type:btnType];
        }
        else {
            //indexPath.row 从1开始
            if (self.myCommunityModel.html_list.count > indexPath.row - 1) {
                SYMyCommunityHTMLModel *htmlModel = [self.myCommunityModel.html_list objectAtIndex:indexPath.row - 1];
                [cell updateLeftInfo:htmlModel.fheadline Type:arrowType];
            }
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.myCommunityModel.neighbor_msg_list.count > 0) {

        NSString *strHTML = nil;
        if (self.myCommunityModel.html_list.count > 0) {
            SYMyCommunityHTMLModel *htmlModel = self.myCommunityModel.html_list.firstObject;
            strHTML = htmlModel.fhtml_url;
        }
        
        if (indexPath.row == 0) {

        }
        else {
            if (self.myCommunityModel.html_list.count > indexPath.row - 1) {
                SYMyCommunityHTMLModel *htmlModel = [self.myCommunityModel.html_list objectAtIndex:indexPath.row - 1];
                SYWKWebViewController *vc = [[SYWKWebViewController alloc] initWithURL:htmlModel.fhtml_url Title:htmlModel.fheadline];
                [FrameManager pushViewController:vc animated:YES];
            }
        }
    }
}


#pragma mark - SYMyCommunityTableViewCell delegate
- (void)callService:(NSString *)number{

    if (!number) {
        [self showErrorWithContent:@"号码格式错误" duration:1];
        return;
    }
    NSString *str = [[NSString alloc] initWithFormat:@"telprompt://%@",number];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];

//    NSMutableString * str = [[NSMutableString alloc] initWithFormat:@"tel:%@",number];
//    UIWebView * callWebview = [[UIWebView alloc] init];
//    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
//    [self.view addSubview:callWebview];
}
@end
