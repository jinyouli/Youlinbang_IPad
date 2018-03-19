//
//  SYMyCommunityTableViewCell.h
//  YLB
//
//  Created by sayee on 17/4/1.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SYMyCommunityTableViewCellHeight 50

@protocol SYMyCommunityTableViewCellDelegate <NSObject>

- (void)callService:(NSString *)number;

@end

@interface SYMyCommunityTableViewCell : UITableViewCell

@property (nonatomic, weak) id<SYMyCommunityTableViewCellDelegate> delegate;

- (void)updateLeftInfo:(NSString *)leftInfo Type:(RightType)type;

@property (nonatomic, copy) NSString *strTel;   //物业电话
@end
