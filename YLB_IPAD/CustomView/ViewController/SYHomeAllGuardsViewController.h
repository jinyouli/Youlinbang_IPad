//
//  SYHomeAllGuardsViewController.h
//  YLB
//
//  Created by sayee on 17/4/1.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "BaseViewController.h"

@interface SYHomeAllGuardsViewController : BaseViewController

@property (nonatomic, assign) BOOL isAllGuardIn;    //是否是全部门禁进来，是的话~~点击cell则显示监控弹框，否,点击cell则添加门禁
@property (nonatomic, assign) int clickIndex; //点了4个常用门禁的哪个门禁进来，用于刷新对应门禁
@end
