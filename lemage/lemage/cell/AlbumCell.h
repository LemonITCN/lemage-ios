//
//  albumCell.h
//  wkWebview
//
//  Created by 王炜光 on 2018/6/8.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaAssetModel.h"
#import "DrawingSingle.h"
@interface AlbumCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSString *albumTitleStr;
@property (nonatomic, strong) UILabel *albumTitleLabel;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) void (^selectedBlock)(BOOL selected);
@property (nonatomic, strong) MediaAssetModel *assetModel;
@end
