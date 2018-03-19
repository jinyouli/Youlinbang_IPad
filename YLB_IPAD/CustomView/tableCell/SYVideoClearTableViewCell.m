//
//  SYVideoClearTableViewCell.m
//  YLB
//
//  Created by sayee on 17/6/19.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYVideoClearTableViewCell.h"

@interface SYVideoClearTableViewCell()

@property (nonatomic, retain) UIView *mainView;
@property (nonatomic, retain) UILabel *leftLab;
@end

@implementation SYVideoClearTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIColorFromRGB(0xebebeb);
        
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth - dockWidth - 80, SYVideoClearTableViewCellHeight)];
        self.mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.mainView];
        
        _leftLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.mainView.width * 0.7, self.mainView.height)];
        self.leftLab.font = [UIFont systemFontOfSize:14.0];
        [self.mainView addSubview:self.leftLab];
        
        UIImage *img = [UIImage imageNamed:@"sy_viedo_clear_type"];
        _arrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.mainView.width - img.size.width - 10, 0, img.size.width, img.size.height)];
        self.arrowImgView.image = img;
        self.arrowImgView.center = CGPointMake(self.arrowImgView.centerX, self.mainView.height * 0.5f);
        [self.mainView addSubview:self.arrowImgView];
    }
    return self;
}

- (void)layoutSubviews
{
    _mainView.frame = CGRectMake(0, 0, screenWidth * 0.7, SYVideoClearTableViewCellHeight);
    
    _leftLab.frame = CGRectMake(10, 0, self.mainView.width * 0.7, self.mainView.height);
    
    UIImage *img = [UIImage imageNamed:@"sy_viedo_clear_type"];
    _arrowImgView.frame = CGRectMake(self.mainView.width - img.size.width - 10, 0, img.size.width, img.size.height);
    self.arrowImgView.center = CGPointMake(self.arrowImgView.centerX, self.mainView.height * 0.5f);
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - public
- (void)updateLeftInfo:(NSString *)leftInfo ShowRightImg:(BOOL)isShowRightImg{
    
    if (!leftInfo) {
        return;
    }
    
    self.leftLab.text = leftInfo;
    self.arrowImgView.hidden = !isShowRightImg;
}
@end
