//
//  SYHomeBannerTableViewCell.m
//  YLB
//
//  Created by sayee on 17/3/30.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYHomeBannerTableViewCell.h"
#import "CycleScrollView.h"
#import "UIImageView+WebCache.h"
#import "SYAdvertInfoListModel.h"
#import "CollectionViewCell.h"
#import "LineLayout.h"

static NSString *const ID = @"cell";

@interface SYHomeBannerTableViewCell()<FSPagerViewDataSource,FSPagerViewDelegate>
@property (nonatomic,strong) UIView *mainView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSMutableArray *offsetImages;
@property (nonatomic,assign) CGFloat offset;
/**自动轮播定时器*/
@property (nonatomic, strong) NSTimer *timer;
@end


@implementation SYHomeBannerTableViewCell
@synthesize dataArray = _dataArray;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIColorFromRGB(0xebebeb);
        self.offset = (screenWidth - dockWidth) * 0.5;
        
        
        NSMutableArray *arrayImg = [NSMutableArray array];
        for (int i=1; i<4; i++) {
            [arrayImg addObject:[NSString stringWithFormat:@"banner_%d",i]];
        }
        self.offsetImages = [[NSMutableArray alloc] initWithArray:arrayImg];
        
        
        self.mainView = [[UIView alloc] initWithFrame:CGRectMake(14, 0, screenWidth - dockWidth - 28, SYHomeBannerTableViewCellHeight)];
        self.mainView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.mainView];
        
        /*
        LineLayout *flowLayout = [[LineLayout alloc]init];
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:self.mainView.bounds collectionViewLayout:flowLayout];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:ID];
        self.bannerView = collectionView;
        [self.mainView addSubview:_bannerView];
         */
        
        [self.mainView addSubview:self.bannerView];
        
        self.pageControl=({
            UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.mainView.height_sd , self.mainView.width_sd, 20)];
            [pageControl addTarget:self action:@selector(pageControlClick:) forControlEvents:UIControlEventValueChanged];
            pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
            pageControl.currentPageIndicatorTintColor = [UIColor redColor];
            pageControl;
        });
        [self.mainView addSubview:_pageControl];
        
        NSTimer *timer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(startScrollAutomtically) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        self.timer = timer;
    }
    return self;
}

- (FSPagerView *)bannerView
{
    if (!_bannerView) {
        _bannerView = [[FSPagerView alloc] init];
        _bannerView.delegate = self;
        _bannerView.dataSource = self;
        
        [_bannerView registerClass:[FSPagerViewCell class] forCellWithReuseIdentifier:@"cell"];
        _bannerView.isInfinite = YES;
        _bannerView.transformer = [[FSPagerViewTransformer alloc] initWithType:FSPagerViewTransformerTypeOverlap];
        CGAffineTransform transform = CGAffineTransformMakeScale(0.6, 0.75);
        _bannerView.itemSize = CGSizeApplyAffineTransform(self.bannerView.frame.size, transform);
    }
    return _bannerView;
}

#pragma mark 自动滚动
- (void)startScrollAutomtically
{
    return;
    NSInteger currentIndex = _pageControl.currentPage + 1;
    
    NSLog(@"currentindex==%d,%d,%d",currentIndex,_pageControl.currentPage,self.dataArray.count);
    if (currentIndex == self.dataArray.count - 2) {
        currentIndex = 0;
    }

    //[self.bannerView setContentOffset:CGPointMake(self.offset * currentIndex, 0) animated:YES];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.mainView.frame = CGRectMake(14, 0, screenWidth - dockWidth - 28, SYHomeBannerTableViewCellHeight);
    self.bannerView.frame = CGRectMake(0, 0, self.mainView.width_sd, self.mainView.height_sd - 25);
    self.pageControl.frame = CGRectMake(0, CGRectGetMaxY(self.bannerView.frame) + 2, self.mainView.width_sd, 20);
}

#pragma mark - event
- (void)pageControlClick:(UIPageControl *)pageControl{
//    self.bannerView.currentPageIndex = pageControl.currentPage;
//    [self.bannerView updateScrollContentOffetWithPage:pageControl.currentPage];
}


#pragma mark - public
-(void)updateBannerInfo:(NSMutableArray *)banners{

    if (banners.count > 0) {
        SYAdvertInfoListModel *model = [banners objectAtIndex:0];
        
        if (model.pic_list.count > 0) {
            SYAdvertInfoModel *picModel = [model.pic_list objectAtIndex:0];
        }
        [self setDataArray:banners];
        
        self.pageControl.numberOfPages = banners.count;
    }else{
        [_dataArray removeAllObjects];
        self.pageControl.numberOfPages = self.offsetImages.count;
    }
    [self.bannerView reloadData];
}

#pragma mark - FSPagerViewDataSource

- (NSInteger)numberOfItemsInPagerView:(FSPagerView *)pagerView
{
    if (_dataArray.count > 0) {
        return _dataArray.count;
    }else {
        return self.offsetImages.count;
    }
}

- (FSPagerViewCell *)pagerView:(FSPagerView *)pagerView cellForItemAtIndex:(NSInteger)index
{
    FSPagerViewCell * cell = [pagerView dequeueReusableCellWithReuseIdentifier:@"cell" atIndex:index];
    
    cell.imageView.contentMode = UIViewContentModeScaleToFill;
    cell.imageView.clipsToBounds = YES;
    
    if (self.dataArray.count > 0) {
        SYAdvertInfoListModel *model = [self.dataArray objectAtIndex:index];
        if (model.pic_list.count > 0) {
            SYAdvertInfoModel *picModel = [model.pic_list objectAtIndex:0];
            
            NSData *dataImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:picModel.img_path]];
            cell.imageView.image = [UIImage imageWithData:dataImage];
        }
    }else{
        cell.imageView.image = [UIImage imageNamed:self.offsetImages[index]];
    }
    
    return cell;
}

#pragma mark - FSPagerViewDelegate

- (void)pagerView:(FSPagerView *)pagerView didSelectItemAtIndex:(NSInteger)index
{
    [pagerView deselectItemAtIndex:index animated:YES];
    
    if (self.dataArray.count > 0) {
        SYAdvertInfoListModel *model = [self.dataArray objectAtIndex:index];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openWebpage" object:model];
    }
    
    [pagerView scrollToItemAtIndex:index animated:YES];
}

- (void)pagerViewDidScroll:(FSPagerView * )pagerView
{
    _pageControl.currentPage = pagerView.currentIndex;
}

/*
#pragma mark -- CollectionView delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.dataArray.count == 0) {
        return self.offsetImages.count;
    }
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    
    if (self.dataArray.count > 0) {
        SYAdvertInfoListModel *model = [self.dataArray objectAtIndex:indexPath.row];
        if (model.pic_list.count > 0) {
            SYAdvertInfoModel *picModel = [model.pic_list objectAtIndex:0];
            cell.strImage = picModel.img_path;
        }
    }else{
        cell.strImage = nil;
        cell.adImage.image = [UIImage imageNamed:[self.offsetImages objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataArray.count > 0) {
        SYAdvertInfoListModel *model = [self.dataArray objectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openWebpage" object:model];
    }
    
}
 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x  / ((screenWidth - dockWidth) * 0.3 + 100);
    
    if (self.dataArray.count > 0) {
        if (index == 0) {//滚动到左边
            scrollView.contentOffset = CGPointMake(self.offset * (_dataArray.count - 2), 0);
            _pageControl.currentPage = _dataArray.count - 2;
        }else if (index == _dataArray.count - 1){//滚动到右边
            scrollView.contentOffset = CGPointMake(self.offset, 0);
            _pageControl.currentPage = 0;
        }else{
            _pageControl.currentPage = index - 1;
        }
    }else {
        if (index == 0) {
            scrollView.contentOffset = CGPointMake(self.offset * (self.offsetImages.count - 2), 0);
            _pageControl.currentPage = self.offsetImages.count - 2;
            
        }else if (index == self.offsetImages.count - 1){
            scrollView.contentOffset = CGPointMake(self.offset, 0);
            _pageControl.currentPage = 0;
        }else{
            _pageControl.currentPage = index - 1;
        }
    }
}
*/

- (void)setDataArray:(NSMutableArray *)dataArray
{
    if (dataArray.count > 0) {
        _dataArray = [NSMutableArray arrayWithArray:dataArray];
    }else {
        _dataArray = [NSMutableArray array];
    }
    [self.bannerView reloadData];
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
        self.pageControl.numberOfPages = self.offsetImages.count;
    }
    return _dataArray;
}

@end
