//
//  CameraViewController.h
//  lemage
//
//  Created by 王炜光 on 2018/7/4.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^TakeOperationSureBlock)(id item);
@interface CameraViewController : UIViewController


/**
 @brief 确定图片或者视频后回调(url)
 */
@property (copy, nonatomic) TakeOperationSureBlock takeBlock;
/**
 @brief 主题色
 */
@property (nonatomic, strong) UIColor *themeColor;
/**
 视频长度
 */
@property (assign, nonatomic) CGFloat HSeconds;
@end
