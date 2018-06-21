//
//  BrowseImageController.h
//  wkWebview
//
//  Created by 王炜光 on 2018/6/6.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaAssetModel.h"

typedef void (^ LEMAGE_RESULT_BLOCK)(NSArray<NSString *> *imageUrlList , BOOL isOriginal);

@interface BrowseImageController : UIViewController
/**
 @brief 最大选择照片数量(为空时认为是不带有选择的预览)
 */
@property (nonatomic, assign) NSUInteger restrictNumber;
/**
 @brief MediaAssetModel数组
 */
@property (nonatomic, strong) NSMutableArray <MediaAssetModel *>*mediaAssetArray;
/**
 @brief asset的localID数组或网络图片地址数组
 */
@property (nonatomic, strong) NSMutableArray *localIdentifierArr;
/**
 @brief 已选择的图片MediaAssetModel
 */
@property (nonatomic, strong) NSMutableArray *selectedImgArr;

@property(nonatomic,copy) LEMAGE_RESULT_BLOCK willClose;
@property(nonatomic,copy) LEMAGE_RESULT_BLOCK closed;
/**
 @brief 当前展示的数组下标
 */
@property (nonatomic, assign) NSInteger showIndex;

/**
 @brief title
 */
@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic, strong) UIColor *themeColor;
@end
