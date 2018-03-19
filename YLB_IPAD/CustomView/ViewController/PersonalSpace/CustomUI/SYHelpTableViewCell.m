//
//  SYHelpTableViewCell.m
//  YLB
//
//  Created by YAYA on 2017/3/19.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYHelpTableViewCell.h"

@interface SYHelpTableViewCell()

@property (nonatomic, retain) UILabel *titleLab;
@property (nonatomic, retain) UILabel *contentLab;
@property (nonatomic, retain) UIView *mainView;

@end


@implementation SYHelpTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIColorFromRGB(0xebebeb);
        
        self.mainView = [[UIView alloc] initWithFrame:CGRectMake(10, -5, kScreenWidth - dockWidth - 100, 40)];
        self.mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.mainView];
        
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.mainView.width - 20, 20)];
        self.titleLab.font = [UIFont systemFontOfSize:14.0];
        self.titleLab.textColor = UIColorFromRGB(0x55555);
        [self.mainView addSubview:self.titleLab];
        
        _contentLab = [[UILabel alloc] initWithFrame:CGRectMake(10, _titleLab.bottom, self.mainView.width - 20, 20)];
        self.contentLab.font = [UIFont systemFontOfSize:14.0];
        self.contentLab.numberOfLines = 0;
        self.contentLab.textColor = [UIColor darkGrayColor];
        [self.mainView addSubview:self.contentLab];
        
    }
    return self;
}

- (void)updateTitle:(NSString *)title Content:(NSString *)content ContentHeight:(CGSize)size{

    if (title) {
        self.titleLab.text = title;
    }
    if (content) {
        self.contentLab.text = content;
        self.contentLab.frame = (CGRect){self.contentLab.origin, size};
    }
    
    self.mainView.frame = (CGRect){self.mainView.origin, {self.mainView.width, self.contentLab.bottom + 10}};
}
@end
