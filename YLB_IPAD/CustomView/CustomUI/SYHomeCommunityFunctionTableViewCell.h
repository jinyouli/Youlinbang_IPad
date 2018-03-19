//
//  SYHomeCommunityFunctionTableViewCell.h
//  YLB
//
//  Created by sayee on 17/3/30.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SYHomeCommunityFunctionTableViewCellHeight 100

typedef enum : NSUInteger {
    sy_home_my_communityBtnTag = 0,
    sy_home_repair_propertyBtnTag,
    sy_home_property_complaintsBtnTag,
    sy_home_smart_homeBtnTag,
    sy_home_my_communityLabTag,
    sy_home_repair_propertyLabTag,
    sy_home_property_complaintsLabTag,
    sy_home_smart_homeLabTag
} functionTag;


@protocol SYHomeCommunityFunctionTableViewCellDelegate <NSObject>

- (void)functionBtnSelect:(functionTag)type;

@end

@interface SYHomeCommunityFunctionTableViewCell : UITableViewCell

@property (nonatomic, weak) id<SYHomeCommunityFunctionTableViewCellDelegate> delegate;
@end
