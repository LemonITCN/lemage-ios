//
//  secondViewController.h
//  wkWebview
//
//  Created by 王炜光 on 2018/5/28.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumViewController : UIViewController

/**
 @brief 选择照片数量
 */
@property (nonatomic, assign) NSUInteger restrictNumber;

/**
 @brief 是否显示原图按钮
 */
@property (nonatomic, assign) BOOL hideOriginal;
@end
