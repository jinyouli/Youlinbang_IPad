//
//  SYHomeGuardTableViewCell.m
//  YLB
//
//  Created by sayee on 17/3/30.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYHomeGuardTableViewCell.h"
#import "SYHomeGuardCollectionViewCell.h"
#import "SYHomeAllGuardCollectionViewCell.h"
#import "SYLockListModel.h"

@interface SYHomeGuardTableViewCell()<UICollectionViewDelegate, UICollectionViewDataSource, SYHomeGuardCollectionViewCellDelegate>

@property (nonatomic, retain) UIImageView *iconImgView; //门禁图片
@property (nonatomic, retain) UIView *mainView;
@property (nonatomic, retain) UILabel *guardNameLab;    //门禁名
@property (nonatomic, retain) UIButton *guardnBtn;  //门禁点击区域

@property (nonatomic, retain) UICollectionView *guardCollectionView;
@end


@implementation SYHomeGuardTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIColorFromRGB(0xebebeb);
        
        self.mainView = [[UIView alloc] initWithFrame:CGRectMake(14, 0, kScreenWidth - dockWidth - 28, (screenWidth - dockWidth) * (170 / 300.0))];
        self.mainView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.mainView];

        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        self.guardCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.mainView.width_sd, self.mainView.height_sd ) collectionViewLayout:layout];
        self.guardCollectionView.scrollEnabled = NO;
        self.guardCollectionView.delegate = self;
        self.guardCollectionView.dataSource = self;
        self.guardCollectionView.backgroundColor = UIColorFromRGB(0xebebeb);
        [self.mainView addSubview:self.guardCollectionView];
        [self.guardCollectionView registerClass:[SYHomeGuardCollectionViewCell class] forCellWithReuseIdentifier:@"SYHomeGuardCollectionViewCell"];
        [self.guardCollectionView registerClass:[SYHomeAllGuardCollectionViewCell class] forCellWithReuseIdentifier:@"SYHomeAllGuardCollectionViewCell"];
    }
    return self;
}

#pragma mark - private
- (void)layoutSubviews {
    [super layoutSubviews];
    self.mainView.frame = CGRectMake(14, 0, kScreenWidth - dockWidth - 28, (screenWidth - dockWidth) * (170 / 300.0) + 50);
    self.guardCollectionView.frame = CGRectMake(0, 0, self.mainView.width_sd, (screenWidth - dockWidth) * (170 / 300.0));
    [self.guardCollectionView reloadData];
}

#pragma mark - collection deleagte
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float fGuardViewWidth = (self.mainView.width_sd - 15) * 0.5f;
    return CGSizeMake(fGuardViewWidth, (170 / 300.0) * fGuardViewWidth);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //全部门禁
//    if (indexPath.row == 4) {
//        static NSString *identify = @"SYHomeAllGuardCollectionViewCell";
//        SYHomeAllGuardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
//        cell.backgroundColor = UIColorFromRGB(0xffffff);
//        return cell;
//    }
    
    static NSString *identify = @"SYHomeGuardCollectionViewCell";
    SYHomeGuardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.backgroundColor = UIColorFromRGB(0xffffff);
    
    SYLockListModel *model = nil;
    if ([SYAppConfig shareInstance].selectedGuardMArr.count > indexPath.row) {
        model = [[SYAppConfig shareInstance].selectedGuardMArr objectAtIndex:indexPath.row];
    }
    [cell updateguardName:model];
    cell.lockChangeBtn.tag = indexPath.row;
    [cell.lockChangeBtn addTarget:self action:@selector(lockChangeBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.lockDeleteBtn.tag = indexPath.row;
    [cell.lockDeleteBtn addTarget:self action:@selector(lockDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SYHomeGuardCollectionViewCell *cell = (SYHomeGuardCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([cell.guardNameLab.text isEqualToString:@"添加门锁"]) {
        
        if ([self.delegate respondsToSelector:@selector(addNewDoor:)]) {
            [self.delegate addNewDoor:indexPath.row];
        }
    }
//    else{
//        if ([self.delegate respondsToSelector:@selector(guardClick:LockListModel:)]) {
//            
//            SYLockListModel *model = nil;
//            if ([SYAppConfig shareInstance].selectedGuardMArr.count > indexPath.row) {
//                model = [[SYAppConfig shareInstance].selectedGuardMArr objectAtIndex:indexPath.row];
//            }
//            [self.delegate guardClick:indexPath LockListModel:model];
//        }
//    }
}

#pragma mark - event
- (void)lockChangeBtn:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(changeNewDoor:)]) {
        [self.delegate changeNewDoor:btn.tag];
    }
}

- (void)lockDeleteBtn:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(deleteNewDoor:)]) {
        [self.delegate deleteNewDoor:btn.tag];
    }
}

#pragma mark - public
- (void)reloadGuardCollectionView{
    [self.guardCollectionView reloadData];
}



#pragma mark - SYHomeGuardCollectionViewCell deleagte
- (void)guardAddToLocal:(NSIndexPath *)indexPath LockListModel:(SYLockListModel *)model{

    if ([self.delegate respondsToSelector:@selector(addGuardClick:LockListModel:)]) {
        [self.delegate addGuardClick:indexPath LockListModel:model];
    }
}

@end
