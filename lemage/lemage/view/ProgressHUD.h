//
//  ProgressHUD.h
//  lemage
//
//  Created by 王炜光 on 2018/7/3.
//  Copyright © 2018年 LemonIT.CN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressHUD : UIView

/**
 初始化等待框

 @param hudColor 小菊花菊花颜色
 @param backgroundColor 背景颜色
 */
- (instancetype)initWithHudColor:(UIColor *)hudColor backgroundColor:(UIColor *)backgroundColor;
/**
 初始化等待框(背景遮挡)
 
 @param hudColor 小菊花菊花颜色
 @param backgroundColor 背景颜色
 */
- (instancetype)initWithNotAllHudColor:(UIColor *)hudColor backgroundColor:(UIColor *)backgroundColor;
/**
 开始
 */
- (void)progressHUDStart;
/**
 停止
 */
- (void)progressHUDStop;
/**
 等待时文字
 */
@property NSString *labelText;

@end
