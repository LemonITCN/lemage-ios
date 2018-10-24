//
//  ProgressHUD.m
//  lemage
//
//  Created by 王炜光 on 2018/7/3.
//  Copyright © 2018年 LemonIT.CN. All rights reserved.
//

#import "ProgressHUD.h"
@interface ProgressHUD ()
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIView *shadowView;
@end
@implementation ProgressHUD

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithHudColor:(UIColor *)hudColor backgroundColor:(UIColor *)backgroundColor{

    CGRect frame = [UIApplication sharedApplication].keyWindow.frame;
    if (self = [super initWithFrame:frame]) {
        
        
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/3, self.frame.size.width/3)];
        bgView.backgroundColor = backgroundColor;
        bgView.center = self.center;
        [self addSubview:bgView];
        bgView.layer.cornerRadius = 10;
        bgView.layer.masksToBounds = YES;
        
        CGFloat hudWidth = self.frame.size.width/4;
        self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
        [bgView addSubview:self.activityIndicator];
        //设置小菊花的frame
        self.activityIndicator.frame= CGRectMake(0, 0, hudWidth, hudWidth);
        self.activityIndicator.center = CGPointMake(bgView.frame.size.width/2, bgView.frame.size.height/2-20);
        
        //设置小菊花颜色
        self.activityIndicator.color = hudColor;
        //刚进入这个界面会显示控件，并且停止旋转也会显示，只是没有在转动而已，没有设置或者设置为YES的时候，刚进入页面不会显示
        self.activityIndicator.hidesWhenStopped = YES;
        
        CGAffineTransform transform = CGAffineTransformMakeScale(1.2, 1.2);
        self.activityIndicator.transform = transform;
        
        
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, bgView.frame.size.height-40, bgView.frame.size.width, 20)];
        self.textLabel.font = [UIFont systemFontOfSize:14];
        self.textLabel.textColor = hudColor;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.text = @"loading";
        [bgView addSubview:self.textLabel];
        
        
        self.alpha = 0;
    }
    
    return self;
}

- (instancetype)initWithNotAllHudColor:(UIColor *)hudColor backgroundColor:(UIColor *)backgroundColor{
    CGRect frame = CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.frame.size.width/3, [UIApplication sharedApplication].keyWindow.frame.size.width/3);
    if (self = [super initWithFrame:frame]) {
        
        self.center =CGPointMake([UIApplication sharedApplication].keyWindow.frame.size.width/2, [UIApplication sharedApplication].keyWindow.frame.size.height/2);
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        
        CGFloat hudWidth = self.frame.size.width/4*3;
        self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
        [self addSubview:self.activityIndicator];
        //设置小菊花的frame
        self.activityIndicator.frame= CGRectMake(0, 0, hudWidth, hudWidth);
        self.activityIndicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2-20);
        
        //设置小菊花颜色
        self.activityIndicator.color = hudColor;
        //刚进入这个界面会显示控件，并且停止旋转也会显示，只是没有在转动而已，没有设置或者设置为YES的时候，刚进入页面不会显示
        self.activityIndicator.hidesWhenStopped = YES;
        
        CGAffineTransform transform = CGAffineTransformMakeScale(1.2, 1.2);
        self.activityIndicator.transform = transform;
        
        
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-40, self.frame.size.width, 20)];
        self.textLabel.font = [UIFont systemFontOfSize:14];
        self.textLabel.textColor = hudColor;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.text = @"loading";
        [self addSubview:self.textLabel];
        
        
        self.alpha = 0;
    }
    
    return self;
}

- (void)progressHUDStart{

    [[self superview]  bringSubviewToFront:self.shadowView];
    self.activityIndicator.hidesWhenStopped = NO;
    [self.activityIndicator startAnimating];
    self.alpha = 1;
}

- (void)progressHUDStop{

    self.alpha = 0;
    self.activityIndicator.hidesWhenStopped = YES;
    [self.activityIndicator stopAnimating];
}

-(UIViewController *)getCurrentVC{
    //获得当前活动窗口的根视图
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1)
    {
        //根据不同的页面切换方式，逐步取得最上层的viewController
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}

@end
