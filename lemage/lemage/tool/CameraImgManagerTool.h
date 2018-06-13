//
//  CameraImgManagerTool.h
//  wkWebview
//
//  Created by 王炜光 on 2018/6/6.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "MediaAssetModel.h"
@interface CameraImgManagerTool : NSObject

/**
 获取所有相册的图片

 @return 所有相册
 */
+(NSArray *)getAllImages;
/**
 获取所有的相册名称和图片

 @return 相册名称和图片(数组下标对应)
 */
+ (NSArray *)getAllAlbum;

/**
 获取高清图片

 @param model model
 @param handler 回调block
 */
+ (void)fetchCostumMediaAssetModel:(MediaAssetModel *)model localIdentifier:(NSString *)localIdentifier handler:(void (^)(NSData *imageData))handler;


/**
 压缩图片

 @param imageData 要压缩的图片
 @param maxLength 图片大小(kb)
 @return 返回的图片
 */
+ (NSData *)compressImageSize:(NSData *)imageData toKB:(NSUInteger)maxLength;
@end
