//
//  SYHomeCommandMessageCollectionViewCell.h
//  YLB
//
//  Created by sayee on 17/8/24.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYAdpublishModel.h"

#define SYHomeCommandMessageCollectionViewCellHeight 75

@interface SYHomeCommandMessageCollectionViewCell : UICollectionViewCell

- (void)updateRecommandInfo:(SYAdpublishModel *)model ShowTag:(BOOL)isShowTag;
@end
