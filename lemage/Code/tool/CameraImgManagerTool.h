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
typedef void (^ LEMAGE_COMPLETE_RESULT)(NSArray *allAlbumArray);
@interface CameraImgManagerTool : NSObject
/**
 获取相册权限

 @param handler nil;
 */
+ (void)requestPhotosLibraryAuthorization:(void(^)(BOOL ownAuthorization))handler;
/**
 获取所有相册的图片和视频

 @param type 类型(只返回图片、相册或所有)
 @param complete 完成回调
 */
+(void)getAllImagesType:(NSString *)type complete:(LEMAGE_COMPLETE_RESULT)complete;

/**
 获取所有的相册名称和图片

 @param type 类型(只返回图片、相册或所有)
 @param complete 完成回调
 */
+ (void)getAllAlbum:(NSString *)type complete:(LEMAGE_COMPLETE_RESULT)complete;

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

/**
 压缩图片到指定的size

 @param imageData 图片data
 @param size 图片
 @return 指定size图片
 */
+ (UIImage *)compressImageSize:(NSData *)imageData toSize:(CGSize)size;
@end
