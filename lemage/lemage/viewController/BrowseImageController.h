//
//  BrowseImageController.h
//  wkWebview
//
//  Created by 王炜光 on 2018/6/6.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaAssetModel.h"
@protocol BrowseImageControllerDelegate<NSObject>

/**
 将选择的数组传递回上一页
 
 @param selectedArr 数组
 */
- (void)sendSelectedImgArr:(NSMutableArray *)selectedArr;

@end
@interface BrowseImageController : UIViewController
/**
 @brief 最大选择照片数量
 */
@property (nonatomic, assign) NSUInteger restrictNumber;
//@property (nonatomic, strong) UICollectionView *collection;
/**
 @brief MediaAssetModel数组
 */
@property (nonatomic, strong) NSMutableArray <MediaAssetModel *>*mediaAssetArray;
@property (nonatomic, strong) NSMutableArray *localIdentifierArr;
//@property (nonatomic, assign) NSUInteger selectedCount;
/**
 @brief 已选择的图片MediaAssetModel
 */
@property (nonatomic, strong) NSMutableArray *selectedImgArr;
/**
 @brief 将选择照片的状态传递给首页
 */
@property (nonatomic, assign) id<BrowseImageControllerDelegate>delegate;
/**
 @brief 当前展示的数组下标
 */
@property (nonatomic, assign) NSInteger showIndex;

/**
 @brief title
 */
@property (nonatomic, strong) NSString *titleStr;
@end
