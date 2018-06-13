//
//  DrawingSingle.m
//  wkWebview
//
//  Created by 王炜光 on 2018/6/12.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import "DrawingSingle.h"

@implementation DrawingSingle
+(DrawingSingle *)shareDrawingSingle{
    static DrawingSingle *single = nil;
    static dispatch_once_t takeOnce;
    dispatch_once(&takeOnce,^{
        single = [[DrawingSingle alloc]init];
    });
    return single;
}

-(UIImage *)getCircularSize:(CGSize)size color:(UIColor *)color insideColor:(UIColor *)insideColor solid:(BOOL)solid{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //获取颜色RGB
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    CGContextSetRGBStrokeColor(context,red,green,blue,1.0);//画笔线的颜色
    CGContextSetLineWidth(context, 1.0);//线的宽度
    
    if (solid) {
        CGContextAddArc(context, size.width/2, size.height/2, size.width/2-1, 0, 2*M_PI, 0);
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextDrawPath(context, kCGPathFill);//绘制填充
  
        [insideColor getRed:&red green:&green blue:&blue alpha:&alpha];
        CGPoint sPoints[3];
        CGContextRef  ctx= UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(ctx, 2.0);
        CGContextSetRGBStrokeColor(ctx,red,green,blue,1.0);//画笔线的颜色
        sPoints[0] =CGPointMake(5, 11);//坐标1
        sPoints[1] =CGPointMake( 10, 16);//坐标2
        sPoints[2] = CGPointMake( 18 , 7);//坐标3
        CGContextAddLines(ctx, sPoints, 3);//添加线
        CGContextDrawPath(ctx, kCGPathStroke); //绘制路径
        
    }else{
        CGContextAddArc(context, size.width/2, size.height/2, size.width/2-1, 0, 2*M_PI, 0); //添加一个圆
        CGContextDrawPath(context, kCGPathStroke); //绘制路径
    }
    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图形上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)getTriangleSize:(CGSize)size color:(UIColor *)color positive:(BOOL)positive{
    //开启图形上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    //从图形上下文获取图片
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context,0);
    CGPoint sPoints[3];//坐标点
    CGFloat imgHeight;
    if (positive) {
        imgHeight = size.height/4;
    }else{
        imgHeight = size.height/4*3;
    }
    
    sPoints[0] =CGPointMake(0, imgHeight);//坐标1
    sPoints[1] =CGPointMake( size.width,imgHeight);//坐标2
    CGFloat point3 = positive?sqrt((size.width*size.width - size.width/2*size.width/2)):size.height-sqrt((size.width*size.width - size.width/2*size.width/2));
    sPoints[2] = CGPointMake( size.width/2 , point3);//坐标3
    CGContextAddLines(context, sPoints, 3);//添加线
    CGContextClosePath(context);//封起来
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图形上下文
    UIGraphicsEndImageContext();
    return newImage;
    
}
@end
