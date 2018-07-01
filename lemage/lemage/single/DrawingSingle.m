//
//  DrawingSingle.m
//  wkWebview
//
//  Created by 王炜光 on 2018/6/12.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import "DrawingSingle.h"
#define Degrees_To_Radians(angle) ((angle) / 180.0 * M_PI)
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

-(UIImage *)getVideoImageSize:(CGSize)size color:(UIColor *)color{
    //获取颜色RGB
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    CGFloat floatHeight = size.height/6*5;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    //开启图形上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    //从图形上下文获取图片
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context,1.0);
    CGContextSetRGBStrokeColor(context,red,green,blue,1.0);
//    CGContextStrokeRect(context,CGRectMake((size.width-size.height*2/6*5)/2, 0, size.height, floatHeight));//画方框
    CGPoint jPoints[4];
    jPoints[0] = CGPointMake((size.width-size.height*2/6*5)/2, size.height/12);
    jPoints[1] = CGPointMake((size.width-size.height*2/6*5)/2, size.height/12+floatHeight);
    jPoints[2] = CGPointMake((size.width-size.height*2/6*5)/2+size.height, size.height/12 + floatHeight);
    jPoints[3] = CGPointMake((size.width-size.height*2/6*5)/2+size.height, size.height/12);
    CGContextAddLines(context, jPoints, 4);//添加线
    CGContextClosePath(context);//封起来
    CGPoint sPoints[4];//坐标点
    sPoints[0] = CGPointMake((size.width-size.height*2/6*5)/2+size.height+2, size.height/2-floatHeight/4);
    sPoints[1] = CGPointMake((size.width-size.height*2/6*5)/2+size.height+2, size.height/2+floatHeight/4);
    sPoints[2] = CGPointMake(size.width-(size.width-size.height*2/6*5)/2, size.height/12 + floatHeight);
    sPoints[3] = CGPointMake(size.width-(size.width-size.height*2/6*5)/2, size.height/12);
    CGContextAddLines(context, sPoints, 4);//添加线
    CGContextClosePath(context);//封起来
    CGContextDrawPath(context, kCGPathStroke);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图形上下文
    UIGraphicsEndImageContext();
    return newImage;
}


-(UIImage *)getPlayImageSize:(CGSize)size color:(UIColor *)color{
    CGFloat radious = size.width/2;
    //获取颜色RGB
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    //开启图形上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    //从图形上下文获取图片
    CGContextRef context = UIGraphicsGetCurrentContext();
    //边框圆
//    CGContextSetRGBStrokeColor(context,red,green,blue,1.0);//画笔线的颜色
    CGContextSetFillColorWithColor(context, color.CGColor);//填充颜色
//    CGContextSetLineWidth(context, 2.0);//线的宽度
    //void CGContextAddArc(CGContextRef c,CGFloat x, CGFloat y,CGFloat radius,CGFloat startAngle,CGFloat endAngle, int clockwise)1弧度＝180°/π （≈57.3°） 度＝弧度×180°/π 360°＝360×π/180 ＝2π 弧度
    // x,y为圆点坐标，radius半径，startAngle为开始的弧度，endAngle为 结束的弧度，clockwise 0为顺时针，1为逆时针。
    CGContextAddArc(context, radious, radious, radious-4, 0, 2*M_PI, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathFill); //绘制路径
    CGFloat tempRadious =  radious/2;
    CGPoint Points[3];
    Points[0] = CGPointMake(radious - (tempRadious/2), radious-(tempRadious)*cos(Degrees_To_Radians(30)));
    Points[1] = CGPointMake(radious - (tempRadious/2), radious+(tempRadious)*cos(Degrees_To_Radians(30)));
    Points[2] = CGPointMake(radious+tempRadious, radious);
    CGContextAddLines(context, Points, 3);//添加线
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:0.8].CGColor);//填充颜色
    CGContextClosePath(context);//封起来
    CGContextDrawPath(context, kCGPathFill);
    
    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图形上下文
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *)getPauseImageSize:(CGSize)size color:(UIColor *)color{
    CGFloat radious = size.width/2;
    //获取颜色RGB
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    //开启图形上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    //从图形上下文获取图片
    CGContextRef context = UIGraphicsGetCurrentContext();
    //实心圆
    CGContextSetFillColorWithColor(context, color.CGColor);//填充颜色
    //void CGContextAddArc(CGContextRef c,CGFloat x, CGFloat y,CGFloat radius,CGFloat startAngle,CGFloat endAngle, int clockwise)1弧度＝180°/π （≈57.3°） 度＝弧度×180°/π 360°＝360×π/180 ＝2π 弧度
    // x,y为圆点坐标，radius半径，startAngle为开始的弧度，endAngle为 结束的弧度，clockwise 0为顺时针，1为逆时针。
    CGContextAddArc(context, radious, radious, radious-4, 0, 2*M_PI, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathFill); //绘制路径
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:0.8].CGColor);//填充颜色
    CGContextFillRect(context,CGRectMake(radious-radious/8-radious/4, radious-radious/2, radious/4, radious));//填充框
    CGContextDrawPath(context, kCGPathStroke);
    
    CGContextFillRect(context,CGRectMake(radious+radious/8, radious-radious/2, radious/4, radious));//填充框
    CGContextDrawPath(context, kCGPathStroke);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图形上下文
    UIGraphicsEndImageContext();
    return newImage;
}


-(UIImage*) OriginImageToSize:(CGSize)size{
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
