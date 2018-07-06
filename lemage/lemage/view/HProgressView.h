//
//  HProgressView.h
//  Join
//
//  Created by 王炜光 on 2018/7/4.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HProgressView : UIView

@property (assign, nonatomic) NSInteger timeMax;

@property (nonatomic, strong)UIColor *themeColor;

- (void)clearProgress;
- (void)showPorgress;
@end
