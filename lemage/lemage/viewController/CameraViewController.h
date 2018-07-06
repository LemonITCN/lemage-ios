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


@property (copy, nonatomic) TakeOperationSureBlock takeBlock;
@property (nonatomic, strong) UIColor *themeColor;
@property (assign, nonatomic) CGFloat HSeconds;
@end
