//
//  HAVPlayer.h
//  Join
//
//  Created by 王炜光 on 2018/7/4.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HAVPlayer : UIView
- (instancetype)initWithFrame:(CGRect)frame withShowInView:(UIView *)bgView url:(NSURL *)url;

@property (copy, nonatomic) NSURL *videoUrl;

- (void)stopPlayer;

@end
