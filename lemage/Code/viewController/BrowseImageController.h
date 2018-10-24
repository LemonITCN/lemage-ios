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
typedef void (^ LEMAGE_CANCEL_BLOCK)(NSArray<NSString *> *imageUrlList , BOOL isOriginal ,NSInteger NowMediaType);

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
/**
 @brief 将要关闭回调
 */
@property(nonatomic,copy) LEMAGE_RESULT_BLOCK willClose;
/**
 @brief 已经关闭回调
 */
@property(nonatomic,copy) LEMAGE_RESULT_BLOCK closed;
/**
 取消选择的回调
 */
@property(nonatomic,copy) LEMAGE_CANCEL_BLOCK cancelBack;
/**
 @brief 当前展示的数组下标
 */
@property (nonatomic, assign) NSInteger showIndex;
/**
 @brief title
 */
@property (nonatomic, strong) NSString *titleStr;
/**
 @brief  unique:只能选择一种,mix:都可以选择;
 */
@property (nonatomic, strong) NSString *styleType;
/**
 @brief 当前选择的类型
 */
@property (nonatomic, assign) NSInteger nowMediaType;
/**
 主体颜色
 */
@property (nonatomic, strong) UIColor *themeColor;
/**
@brief 完成按钮
*/
@property UIButton *finishBtn;
/**
 @brief 播放暂停按钮/进度条背景图
 */
@property UIView *funtionBGView;
@end
