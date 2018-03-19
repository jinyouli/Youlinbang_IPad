//
//  SYVideoClearTableViewCell.h
//  YLB
//
//  Created by sayee on 17/6/19.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SYVideoClearTableViewCellHeight 50

@interface SYVideoClearTableViewCell : UITableViewCell

@property (nonatomic, retain) UIImageView *arrowImgView;

- (void)updateLeftInfo:(NSString *)leftInfo ShowRightImg:(BOOL)isShowRightImg;
@end
