//
//  SYHomeCollectionViewHeaderCollectionReusableView.h
//  YLB
//
//  Created by sayee on 17/8/25.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>
#define SYHomeCollectionViewHeaderCollectionReusableViewHeight 40
@interface SYHomeCollectionViewHeaderCollectionReusableView : UICollectionReusableView

@property(nonatomic, copy) void(^clickCallBack)(void);

- (void)updateTitle:(NSString *)title moreLabel:(NSString *)moreLabel;
@end
