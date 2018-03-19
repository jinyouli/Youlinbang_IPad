//
//  SYBlueTeethListView.h
//  YLB
//
//  Created by sayee on 17/6/1.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseView.h"
#import "SYBlueTeethPeripheralModel.h"

@interface SYBlueTeethListView : BaseView

- (instancetype)initWithFrame:(CGRect)frame WithPeripheralArr:(NSArray *)peripheralArr;

@property (nonatomic , copy) void (^SYBlueTeethListClickBlock)(int index, SYBlueTeethPeripheralModel *model);

- (void)tableViewReload:(NSArray *)arr;
- (void)hiddenBlueTeethListView;
- (void)showBlueTeethListView;
@end
