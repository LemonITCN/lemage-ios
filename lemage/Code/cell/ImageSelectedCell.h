//
//  imageSelectedCell.h
//  wkWebview
//
//  Created by 王炜光 on 2018/6/6.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaAssetModel.h"
@interface ImageSelectedCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIButton *selectHideButton;
@property (nonatomic, strong) void (^selectedBlock)(BOOL selected);
@property (nonatomic, strong) MediaAssetModel *assetModel;
@property (nonatomic, assign) BOOL canSelected;
@property (nonatomic, strong) UIView *whiteView;
@property (nonatomic, strong) NSString *imgNo;
@property (nonatomic, strong) UIColor *themeColor;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *videoImageView;
@end
