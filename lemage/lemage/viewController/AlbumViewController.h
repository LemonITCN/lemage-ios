//
//  secondViewController.h
//  wkWebview
//
//  Created by 王炜光 on 2018/5/28.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ LEMAGE_RESULT_BLOCK)(NSArray<NSString *> *imageUrlList , BOOL isOriginal);

@interface AlbumViewController : UIViewController

/**
 @brief 选择照片数量
 */
@property (nonatomic, assign) NSUInteger restrictNumber;

/**
 @brief 是否显示原图按钮
 */
@property (nonatomic, assign) BOOL hideOriginal;

/**
 将要关闭回调
 */
@property(nonatomic,copy) LEMAGE_RESULT_BLOCK willClose;
/**
 已经关闭回调
 */
@property(nonatomic,copy) LEMAGE_RESULT_BLOCK closed;

/**
 主题颜色
 */
@property (nonatomic, strong) UIColor *themeColor;
/**
 @brief image:只有图片,video:只有视频,all:包含视频和图片
 */
@property (nonatomic, strong) NSString *selectedType;
/**
 @brief  unique:只能选择一种,mix:都可以选择;
 */
@property (nonatomic, strong) NSString *styleType;
@end
