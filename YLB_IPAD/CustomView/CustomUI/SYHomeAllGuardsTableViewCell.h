//
//  SYHomeAllGuardsTableViewCell.h
//  YLB
//
//  Created by sayee on 17/4/1.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SYHomeAllGuardsTableViewCellHeight 50


@protocol SYHomeAllGuardsTableViewCellDelegate <NSObject>

- (void)guardSelect:(NSIndexPath *)indexPath;

@end

@interface SYHomeAllGuardsTableViewCell : UITableViewCell

@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, weak) id<SYHomeAllGuardsTableViewCellDelegate> delegate;


- (void)updateGuardTitle:(NSString *)title;
@end
