//
//  CollectionViewCell.m
//  自定义UICollectionView的布局
//
//  Created by Tengfei on 16/1/4.
//  Copyright © 2016年 tengfei. All rights reserved.
//

#import "CollectionViewCell.h"
#define KRandomColor     [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];

@interface CollectionViewCell ()


@end

@implementation CollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
}

- (void)setStrImage:(NSString *)strImage
{
    _strImage = strImage;
    
    NSData *dataImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:strImage]];
    self.adImage.contentMode = UIViewContentModeScaleAspectFill;
    self.adImage.image = [UIImage imageWithData:dataImage];
}

@end
