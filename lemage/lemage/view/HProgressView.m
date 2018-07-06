//
//  HProgressView.m
//  Join
//
//  Created by 王炜光 on 2018/7/4.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import "HProgressView.h"

@interface HProgressView ()

/**
 *  进度值0-1.0之间
 */
@property (nonatomic,assign)CGFloat progressValue;

/**
 当前进行的时间
 */
@property (nonatomic, assign) CGFloat currentTime;

/**
 最早设置的frame
 */
@property (nonatomic, assign) CGRect frameHasSet;

@end

@implementation HProgressView


-(instancetype)initWithFrame:(CGRect)frame{
    _frameHasSet = frame;
    if (self = [super initWithFrame:frame]) {
        
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();//获取上下文
//    Plog(@"width = %f",self.frame.size.width);
    CGPoint center = CGPointMake(self.frame.size.width/2.0, self.frame.size.width/2.0);  //设置圆心位置
    CGFloat radius = self.frame.size.width/2.0-5;  //设置半径
    CGFloat startA = - M_PI_2;  //圆起点位置
    CGFloat endA = -M_PI_2 + M_PI * 2 * _progressValue;  //圆终点位置
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
    
    CGContextSetLineWidth(ctx, 10); //设置线条宽度
    [_themeColor setStroke]; //设置描边颜色
    
    CGContextAddPath(ctx, path.CGPath); //把路径添加到上下文
    
    CGContextStrokePath(ctx);  //渲染
    
    
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, self.frame.size.width/2-10, 0, 2*M_PI, 0);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextDrawPath(ctx, kCGPathFill);//绘制填充
    
}

- (void)setTimeMax:(NSInteger)timeMax {
    _timeMax = timeMax-0.5;
    self.currentTime = 0;
    self.progressValue = 0;
    CGPoint center = self.center;
    [UIView animateWithDuration:0.1 animations:^{
        self.frame = CGRectMake(self.frame.origin.x-12.5, self.frame.origin.y-12.5, self.frame.size.width+25, self.frame.size.height+25);
    }];
    
    self.center = center;
    self.layer.cornerRadius =self.frame.size.width/2;
    [self setNeedsDisplay];
    self.hidden = NO;
    [self performSelector:@selector(startProgress) withObject:nil afterDelay:0.01];
}

- (void)clearProgress {
    _currentTime = _timeMax;
    self.hidden = YES;
    CGPoint center = self.center;
    self.frame = _frameHasSet;
    self.layer.cornerRadius =self.frame.size.width/2;

    self.center = center;
    
}

- (void)showPorgress{
    self.hidden = NO;
    _currentTime = 0;
    _progressValue = 0;
    [self setNeedsDisplay];
}

- (void)startProgress {
    _currentTime += 0.01;
    if (_timeMax > _currentTime) {
        _progressValue = _currentTime/_timeMax;
        [self setNeedsDisplay];
        [self performSelector:@selector(startProgress) withObject:nil afterDelay:0.01];
    }
    if (_timeMax <= _currentTime) {
        [self clearProgress];
    }
}

@end
