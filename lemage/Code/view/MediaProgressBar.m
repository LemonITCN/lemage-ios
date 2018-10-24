//
//  MediaProgressBar.m
//  lemage
//
//  Created by 王炜光 on 2018/6/29.
//  Copyright © 2018年 LemonIT.CN. All rights reserved.
//

#import "MediaProgressBar.h"

@implementation MediaProgressBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (CGRect)trackRectForBounds:(CGRect)bounds
{
//    [self setThumbImage:[self OriginImageToSize:CGSizeMake(bounds.size.height/2, bounds.size.height/2)] forState:UIControlStateNormal];
    return CGRectMake(0, bounds.size.height/2-1.5, bounds.size.width, 3);
}

-(UIImage*) OriginImageToSize:(CGSize)size

{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    //从图形上下文获取图片
    CGContextRef context = UIGraphicsGetCurrentContext();//填充圆，无边框
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);//填充颜色
    CGContextAddArc(context, size.width/2, size.width/2, size.width/2, 0, 2*M_PI, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathFill);//绘制填充
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图形上下文
    UIGraphicsEndImageContext();
    return newImage;
    
}
@end
