//
//  ProgressHUD.h
//  lemage
//
//  Created by 王炜光 on 2018/7/3.
//  Copyright © 2018年 LemonIT.CN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressHUD : UIView

- (instancetype)initWithHudColor:(UIColor *)hudColor backgroundColor:(UIColor *)backgroundColor;
- (instancetype)initWithNotAllHudColor:(UIColor *)hudColor backgroundColor:(UIColor *)backgroundColor;
- (void)progressHUDStart;
- (void)progressHUDStop;
@property NSString *labelText;

@end
