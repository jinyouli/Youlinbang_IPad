//
//  SYSettingTableViewCell.h
//  YLB
//
//  Created by YAYA on 2017/3/18.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SYSettingTableViewCellHeight 50

typedef enum {
    arrowType = 0,
    btnType,
    switchType,
    labelType,
    txtFieldType,
    phoneType,
    seitchWithSetGesturePWType  //手势密码修改专用
}RightType;

@protocol SYSettingTableViewCellDelegate <NSObject>

- (void)switchChange:(BOOL)change;

@end

@interface SYSettingTableViewCell : UITableViewCell

@property (nonatomic, assign) CGRect rectCell;
@property (nonatomic, retain) UILabel *leftLab;
@property (nonatomic, retain) UISwitch *rightSwitch;
@property (nonatomic, retain) UIView *underLineView;
@property (nonatomic, retain) UILabel *otherLab;
@property (nonatomic, retain) UIImageView *arrowImgView;

@property (nonatomic, weak) id<SYSettingTableViewCellDelegate> delegate;

- (void)updateLeftInfo:(NSString *)leftInfo Type:(RightType)type;
@end
