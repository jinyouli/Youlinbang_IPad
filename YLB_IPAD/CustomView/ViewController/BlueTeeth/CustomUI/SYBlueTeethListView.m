//
//  SYBlueTeethListView.m
//  YLB
//
//  Created by sayee on 17/6/1.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYBlueTeethListView.h"

@interface SYBlueTeethListView ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *sourcesMArr;
@property (nonatomic, retain) UIButton *btnClose;
@end

@implementation SYBlueTeethListView

- (instancetype)initWithFrame:(CGRect)frame WithPeripheralArr:(NSArray *)peripheralArr{
    
    if (self = [super initWithFrame:frame]) {
        if (peripheralArr) {
            self.sourcesMArr = [[NSMutableArray alloc] initWithArray:peripheralArr];
            [self initUI];
        }
    }
    return self;
}

- (void)initUI{
    
    self.backgroundColor = [UIColor clearColor];
    
    self.btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnClose.frame = self.bounds;
    [self.btnClose addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.btnClose];
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width * 0.7, self.width * 0.7)];
    mainView.center = CGPointMake(self.width * 0.5f, self.height * 0.5f);
    mainView.layer.cornerRadius = 5;
    mainView.layer.masksToBounds = YES;
    [self addSubview:mainView];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainView.width, 30)];
    topView.backgroundColor = UIColorFromRGB(0xd23023);
    [mainView addSubview:topView];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, mainView.width, topView.height)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = @"门禁列表";
    [topView addSubview:lab];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topView.bottom_sd, mainView.width_sd, mainView.height_sd - topView.height_sd) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = UIColorFromRGB(0xebebeb);
    [mainView addSubview:self.tableView];
}


#pragma mark - public
- (void)tableViewReload:(NSArray *)arr{
    [self.sourcesMArr removeAllObjects];
    [self.sourcesMArr addObjectsFromArray:arr];
    [self.tableView reloadData];
}

- (void)showBlueTeethListView{
    WEAK_SELF;
    if (self.alpha == 1) {
        return;
    }
    [UIView animateWithDuration:0.1 animations:^{
         weakSelf.alpha = 1;
    } completion:^(BOOL finished) {
         weakSelf.hidden = NO;
    }];
}

- (void)hiddenBlueTeethListView{
    WEAK_SELF;
    [UIView animateWithDuration:0.1 animations:^{
        weakSelf.alpha = 0;
    } completion:^(BOOL finished) {
        weakSelf.hidden = YES;
    }];
}


#pragma mark - event
- (void)closeView{
    [self hiddenBlueTeethListView];
}


#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sourcesMArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify = @"UITableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    
    if (self.sourcesMArr.count > indexPath.row) {
        SYBlueTeethPeripheralModel *model = [self.sourcesMArr objectAtIndex:indexPath.row];
        cell.textLabel.text = model.guardName;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.sourcesMArr.count > indexPath.row) {
        SYBlueTeethPeripheralModel *model = [self.sourcesMArr objectAtIndex:indexPath.row];
        if (self.SYBlueTeethListClickBlock) {
            self.SYBlueTeethListClickBlock(indexPath.row, model);
        }
    }
}
@end
