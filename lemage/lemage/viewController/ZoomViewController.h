//
//  ZoomViewController.h
//  wkWebview
//
//  Created by 王炜光 on 2018/6/7.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ZoomViewController : UIViewController

/**
 @brief 承载image
 */
@property (nonatomic, strong) UIImageView *imageView;
/**
 @brief 放大缩小
 */
@property (nonatomic, strong) UIScrollView *scrollView;
/**
 当先数组下标
 */
@property (nonatomic, assign) NSUInteger showIndex;
/**
 放大后缩小
 */
-(void)initScrollview;
/**
 自适应图片大小
 */
-(void)setImageFrame;
@end
