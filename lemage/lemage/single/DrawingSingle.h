//
//  DrawingSingle.h
//  wkWebview
//
//  Created by 王炜光 on 2018/6/12.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface DrawingSingle : NSObject

+(DrawingSingle *)shareDrawingSingle;
/**
 获得三角符号图片

 @param size 图片大小
 @param color 三角符号图片的颜色
 @param positive 尖朝上还是朝下
 @return 返回的图片
 */
- (UIImage *)getTriangleSize:(CGSize)size color:(UIColor *)color positive:(BOOL)positive;
/**
 获得空心圆或者实心圆对号图片

 @param size 图片大小
 @param color 背景颜色(默认对号是绿色)
 @param insideColor 对号颜色
 @param solid 是否是实心圆
 @return 返回的图片
 */
-(UIImage *)getCircularSize:(CGSize)size color:(UIColor *)color insideColor:(UIColor *)insideColor solid:(BOOL)solid;
/**
 显示视频图片

 @param size 大小
 @param color 颜色
 @return 返回的图片
 */
-(UIImage *)getVideoImageSize:(CGSize)size color:(UIColor *)color;
/**
 播放图片

 @param size 大小
 @param color 颜色
 @return 返回的图片
 */
-(UIImage *)getPlayImageSize:(CGSize)size color:(UIColor *)color;
/**
 暂停的图片

 @param size 代销
 @param color 颜色
 @return 返回的大小
 */
-(UIImage *)getPauseImageSize:(CGSize)size color:(UIColor *)color;
/**
 创建slider的圆点图片

 @param size 圆点的大熊啊
 @return 返回的图片
 */
-(UIImage*) OriginImageToSize:(CGSize)size;
@end
