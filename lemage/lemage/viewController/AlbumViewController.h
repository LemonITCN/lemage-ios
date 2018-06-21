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

@property(nonatomic,copy) LEMAGE_RESULT_BLOCK willClose;
@property(nonatomic,copy) LEMAGE_RESULT_BLOCK closed;

@property (nonatomic, strong) UIColor *themeColor;
@end
