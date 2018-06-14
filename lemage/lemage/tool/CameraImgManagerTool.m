//
//  CameraImgManagerTool.m
//  wkWebview
//
//  Created by 王炜光 on 2018/6/6.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import "CameraImgManagerTool.h"

@implementation CameraImgManagerTool

+(NSMutableArray <MediaAssetModel *>*)getAllImages{
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];//请求选项设置
    options.resizeMode = PHImageRequestOptionsResizeModeExact;//自定义图片大小的加载模式
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = YES;//是否同步加载
    
    //容器类
    
    NSMutableArray <MediaAssetModel *>*mmediaAssetArray = [NSMutableArray array];
    for (PHAsset *asset in [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:[[self class] configImageOptions]]) {
        
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            MediaAssetModel *object = [[MediaAssetModel alloc] init];
            object.localIdentifier = asset.localIdentifier;
            object.imageThumbnail = result;
            object.asset = asset;
            [mmediaAssetArray addObject:object];
        }];

    }
    return mmediaAssetArray;
}

+ (PHFetchOptions *)configImageOptions {
    PHFetchOptions *fetchResoultOption = [[PHFetchOptions alloc] init];
    fetchResoultOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];//按照日期降序排序
    fetchResoultOption.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];//过滤剩下照片类型
    return fetchResoultOption;
}

+ (NSArray *)getAllAlbum{
    NSMutableArray *nameArr = [NSMutableArray array];//用于存储assets's名字
    NSMutableArray *assetArr = [NSMutableArray array];//用于存储assets's内容
    NSMutableArray *nameAndAssetArr = [NSMutableArray new];
    
    // 获取系统设置的相册信息(没有<照片流>等)
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    for (PHAssetCollection *collection in smartAlbums) {
        PHFetchResult *results = [PHAsset fetchAssetsInAssetCollection:collection options:nil];

        NSMutableArray *tempPHF = [NSMutableArray new];
        for (PHAsset *tempAsset in results) {
            if (tempAsset.mediaType ==PHAssetMediaTypeImage) {
                [[PHImageManager defaultManager] requestImageForAsset:tempAsset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    MediaAssetModel *object = [[MediaAssetModel alloc] init];
                    object.localIdentifier = tempAsset.localIdentifier;
                    object.imageThumbnail = result;
                    object.asset = tempAsset;
                    [tempPHF addObject:object];
                }];

            }
        }
        [nameArr addObject:collection.localizedTitle];//存储assets's名字
        [assetArr addObject:tempPHF];//存储assets's内容
        [nameAndAssetArr addObject:@{@"albumName":collection.localizedTitle,@"assetArr":tempPHF}];
    }
    
    //  用户自定义的资源
    PHFetchResult *customCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in customCollections) {
        PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        NSMutableArray *tempPHF = [NSMutableArray new];
        for (PHAsset *tempAsset in assets) {
            if (tempAsset.mediaType ==PHAssetMediaTypeImage) {
            
                [[PHImageManager defaultManager] requestImageForAsset:tempAsset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    MediaAssetModel *object = [[MediaAssetModel alloc] init];
                    object.localIdentifier = tempAsset.localIdentifier;
                    object.imageThumbnail = result;
                    object.asset = tempAsset;
                    [tempPHF addObject:object];
                }];
            }
        }
        [nameArr addObject:collection.localizedTitle];
        [assetArr addObject:tempPHF];
        [nameAndAssetArr addObject:@{@"albumName":collection.localizedTitle,@"assetArr":tempPHF}];
    }
    
    return [NSArray arrayWithArray:nameAndAssetArr];
}

+ (void)fetchCostumMediaAssetModel:(MediaAssetModel *)model localIdentifier:(NSString *)localIdentifier handler:(void (^)(NSData *imageData))handler{
    PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil][0];

//
    PHImageRequestOptions *imageRequestOption = [self configImageRequestOption];
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:imageRequestOption resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        if (handler) {
            handler(imageData);
        }
    }];
    
}


//同步配置
+ (PHImageRequestOptions *)configSynchronousImageRequestOptionWith:(PHImageRequestOptions *)imageRequestOption {
    imageRequestOption.synchronous = true;
    return imageRequestOption;
}


+ (PHImageRequestOptions *)configImageRequestOption {
    //图片请求选项配置
    PHImageRequestOptions *imageRequestOption = [[PHImageRequestOptions alloc] init];
    //图片版本:最新
    imageRequestOption.version = PHImageRequestOptionsVersionCurrent;
    //非同步
    imageRequestOption.synchronous = false;
    //图片交付模式:高质量格式
    imageRequestOption.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    //图片请求模式:精确的
    imageRequestOption.resizeMode = PHImageRequestOptionsResizeModeExact;
    //用于对原始尺寸的图像进行裁剪，基于比例坐标。resizeMode 为 Exact 时有效。
    //  imageRequestOption.normalizedCropRect = CGRectMake(0, 0, 100, 100);
    return imageRequestOption;
}


+ (NSData *)compressImageSize:(NSData *)imageData toKB:(NSUInteger)maxLength {
    maxLength = maxLength*1024;
    NSData *data = imageData;
    UIImage *resultImage = [UIImage imageWithData:data];
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        // Use image to draw (drawInRect:), image is larger but more compression time
        // Use result image to draw, image is smaller but less compression time
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, 1);
    }
    
    return data;
}

@end
