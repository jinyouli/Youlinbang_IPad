//
//  YLBDock.m
//  YLB_IPAD
//
//  Created by jinyou on 2017/6/26.
//  Copyright © 2017年 com.jinyou. All rights reserved.
//

#import "YLBDock.h"
#import "YLBDockItem.h"

@interface YLBDock()
@property (nonatomic,strong) UIView *lineView;

@end

@implementation YLBDock

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleRightMargin;
        
        self.arrayButtons = [NSMutableArray array];
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.headImage = [[UIImageView alloc] init];
    self.headImage.image = [UIImage imageNamed:@"no_head_bg"];
//    [self.headImage.layer setBorderWidth:1];
//    [self.headImage.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    self.headImage.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.headImage];
    
    self.nickName = [[UILabel alloc] init];
    self.nickName.textAlignment = NSTextAlignmentCenter;
    self.nickName.font = [UIFont systemFontOfSize:14.0f];
    self.nickName.textColor = [UIColor darkGrayColor];
    [self addSubview:self.nickName];
    
    UIButton *buttn = [UIButton buttonWithType:UIButtonTypeCustom];
    buttn.backgroundColor = [UIColor clearColor];
    [self addSubview:buttn];
    self.buttn = buttn;
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = UIColorFromRGB(0xebebeb);
    self.lineView = lineView;
    [self addSubview:lineView];
    
    [self addTabItems];
    
    YLBDockItem *tabItem = [self.arrayButtons objectAtIndex:0];
    tabItem.backgroundColor = [UIColor redColor];
    tabItem.selected = YES;
}

- (void)addTabItems
{
    //首页
    [self addSingleTab:@"Slice 82a" selectedImage:@"Slice 82" title:@"首页" weight:1];
    
    //发现
    [self addSingleTab:@"Slice 80a" selectedImage:@"Slice 80" title:@"发现" weight:2];
    
    //我的
    [self addSingleTab:@"Slice 79a" selectedImage:@"Slice 79" title:@"我的" weight:3];
    
    //消息
    [self addSingleTab:@"Slice 81a" selectedImage:@"Slice 81" title:@"消息" weight:4];
    
}

- (void)addSingleTab:(NSString *)backgroundImage selectedImage:(NSString *)selectedImage title:(NSString*)title weight:(int)weight
{
    YLBDockItem *tabItem=[[YLBDockItem alloc]init];
    [tabItem setTitle:title forState:UIControlStateNormal];
    [tabItem setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [tabItem setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    tabItem.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [tabItem setImage:[UIImage imageNamed:backgroundImage] forState:UIControlStateNormal];
    [tabItem setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
    
    [tabItem addTarget:self action:@selector(tabItemTouchEvent:) forControlEvents:UIControlEventTouchDown];
    tabItem.tag = weight - 1;
    [self addSubview:tabItem];
    [self.arrayButtons addObject:tabItem];
}

- (void)layoutSubviews
{
    self.headImage.frame = CGRectMake(self.frame.size.width * 0.5 - 25, 50, 50, 50);
    self.headImage.layer.cornerRadius = self.headImage.frame.size.width * 0.5;
    self.headImage.layer.masksToBounds = YES;
    
    self.buttn.frame = CGRectMake(0, 50, self.frame.size.width, 100);
    self.nickName.frame = CGRectMake(0, CGRectGetMaxY(self.headImage.frame) - 10, self.frame.size.width, 60);
    self.lineView.frame = CGRectMake(self.frame.size.width - 1, 0, 1, self.frame.size.height);
    
    int index = 0;
    
    CGFloat sizeCell = screenHeight - self.nickName.frame.origin.y - self.nickName.frame.size.height;
    sizeCell = sizeCell / 4;
    //sizeCell = 120;
    
    for (YLBDockItem *tabItem in self.arrayButtons) {
        tabItem.frame = CGRectMake(0, self.nickName.frame.origin.y + self.nickName.frame.size.height + sizeCell * index, self.frame.size.width, 90);
        index ++;
    }
}

- (void)tabItemTouchEvent:(YLBDockItem *)tabItem
{
    for (int i=0; i<self.arrayButtons.count; i++) {
        YLBDockItem *item = [self.arrayButtons objectAtIndex:i];
        item.backgroundColor = [UIColor clearColor];
        item.selected = NO;
    }
    
    tabItem.backgroundColor = [UIColor redColor];
    tabItem.selected = YES;
    [self.delgeate touchButton:tabItem.tag];
}

@end
