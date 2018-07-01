//
//  CameraImgManagerTool.m
//  wkWebview
//
//  Created by 王炜光 on 2018/6/6.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import "CameraImgManagerTool.h"

@implementation CameraImgManagerTool
/**
 获取相册权限
 @param handler 获取权限结果
 */
+ (void)requestPhotosLibraryAuthorization:(void(^)(BOOL ownAuthorization))handler {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (handler) {
            BOOL boolean = false;
            if (status == PHAuthorizationStatusAuthorized) {
                boolean = true;
            }
            handler(boolean);
        }
    }];
}

+(void)getAllImagesType:(NSString *)type complete:(LEMAGE_COMPLETE_RESULT)complete{
    //
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];//请求选项设置
    options.resizeMode = PHImageRequestOptionsResizeModeExact;//自定义图片大小的加载模式
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = YES;//是否同步加载
    
    //容器类
    
    NSMutableArray *mmediaAssetArray = [NSMutableArray array];
    NSMutableArray *tempAssetArr = [NSMutableArray new];
    for (PHAsset *asset in [PHAsset fetchAssetsWithOptions:nil]) {
        if ([type isEqualToString:@"image"]) {
            if (asset.mediaType == 1) {
                [tempAssetArr addObject:asset];
            }
        }else if ([type isEqualToString:@"video"]){
            if (asset.mediaType == 2) {
                [tempAssetArr addObject:asset];
            }
        }else{
            [tempAssetArr addObject:asset];
        }
        [mmediaAssetArray addObject:@"0"];
    }
    
    for (NSInteger i = 0;i<tempAssetArr.count;i++) {
        PHAsset *asset  = tempAssetArr[i];
        NSString *index = [NSString stringWithFormat:@"%ld",i];
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            if (asset.mediaType == 2) {
                
                [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
                    
                    //    如果要切换视频需要调AVPlayer的replaceCurrentItemWithPlayerItem:方法
                    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
                    CMTime time = player.currentItem.asset.duration;
                    Float64 seconds = CMTimeGetSeconds(time);
                    
                    MediaAssetModel *object = [[MediaAssetModel alloc] init];
                    object.localIdentifier = [NSString stringWithFormat:@"local%@/%@",asset.mediaType == 1?@"Image":@"Video",asset.localIdentifier];
                    object.imageThumbnail = result;
                    object.videoTime = [NSString stringWithFormat:@"%f",seconds];
                    object.asset = asset;
                    object.mediaType = asset.mediaType;
                    mmediaAssetArray[[index integerValue]] = object;
 
                    if (![mmediaAssetArray containsObject:@"0"]) {
                        if (complete) {
                            complete(mmediaAssetArray);
                        }
                    }
                }];
            }else{
                MediaAssetModel *object = [[MediaAssetModel alloc] init];
                object.localIdentifier = [NSString stringWithFormat:@"local%@/%@",asset.mediaType == 1?@"Image":@"Video",asset.localIdentifier];
                object.imageThumbnail = result;
                object.asset = asset;
                object.mediaType = asset.mediaType;
                mmediaAssetArray[[index integerValue]] = object;
                
                if (![mmediaAssetArray containsObject:@"0"]) {
                    if (complete) {
                        complete(mmediaAssetArray);
                    }
                }
            }
            
        }];

    }
    
//    return mmediaAssetArray;
}

+ (PHFetchOptions *)configImageOptions {
    PHFetchOptions *fetchResoultOption = [[PHFetchOptions alloc] init];
    fetchResoultOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];//按照日期降序排序
//    fetchResoultOption.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];//过滤剩下照片类型
    return fetchResoultOption;
}

+ (void)getAllAlbum:(NSString *)type complete:(LEMAGE_COMPLETE_RESULT)complete{

    NSMutableArray *nameArr = [NSMutableArray array];//用于存储assets's名字
    NSMutableArray *assetArr = [NSMutableArray array];//用于存储assets's内容
    NSMutableArray *nameAndAssetArr = [NSMutableArray new];
    NSMutableArray *statusArr = [NSMutableArray new];
    
    // 获取系统设置的相册信息(没有<照片流>等)
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    for (PHAssetCollection *collection in smartAlbums) {
        PHFetchResult *results = [PHAsset fetchAssetsInAssetCollection:collection options:nil];

        NSMutableArray *tempPHF = [NSMutableArray new];
        for (PHAsset *tempAsset in results) {

            if ([type isEqualToString:@"image"]) {
                if (tempAsset.mediaType == 1) {
                    [tempPHF addObject:tempAsset];
                }
            }else if ([type isEqualToString:@"video"]){
                if (tempAsset.mediaType == 2) {
                    [tempPHF addObject:tempAsset];
                }
            }else{
                [tempPHF addObject:tempAsset];
            }
        }
        [nameArr addObject:collection.localizedTitle];//存储assets's名字
        [assetArr addObject:tempPHF];//存储assets's内容
        [nameAndAssetArr addObject:@{@"albumName":collection.localizedTitle,@"assetArr":tempPHF}];
        [statusArr addObject:tempPHF.count>0?@"0":@"1"];
    }
    
    //  用户自定义的资源
    PHFetchResult *customCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in customCollections) {
        PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        NSMutableArray *tempPHF = [NSMutableArray new];
        for (PHAsset *tempAsset in assets) {
            
            if ([type isEqualToString:@"image"]) {
                if (tempAsset.mediaType == 1) {
                    [tempPHF addObject:tempAsset];
                }
            }else if ([type isEqualToString:@"video"]){
                if (tempAsset.mediaType == 2) {
                    [tempPHF addObject:tempAsset];
                }
            }else{
                [tempPHF addObject:tempAsset];
            }
        }
        [nameArr addObject:collection.localizedTitle];
        [nameAndAssetArr addObject:@{@"albumName":collection.localizedTitle,@"assetArr":tempPHF}];
        [statusArr addObject:tempPHF.count>0?@"0":@"1"];
    }
    
    for (NSInteger i = 0;i<nameAndAssetArr.count;i++) {
        NSDictionary *tempDic = nameAndAssetArr[i];
        NSArray *tempArr = tempDic[@"assetArr"];
        NSMutableArray *modelArr = [NSMutableArray new];
        NSString *index = [NSString stringWithFormat:@"%ld",i];
        for (NSInteger k = 0; k<tempArr.count; k++) {
            [modelArr addObject:@"0"];
        }
        for (NSInteger j = 0; j<tempArr.count; j++) {
            PHAsset *asset = tempArr[j];
            NSString *jindex = [NSString stringWithFormat:@"%ld",j];
            
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                
                if (asset.mediaType == 2) {
                    
                    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
                        
                        //    如果要切换视频需要调AVPlayer的replaceCurrentItemWithPlayerItem:方法
                        AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
                        CMTime time = player.currentItem.asset.duration;
                        Float64 seconds = CMTimeGetSeconds(time);
                        
                        MediaAssetModel *object = [[MediaAssetModel alloc] init];
                        object.localIdentifier = [NSString stringWithFormat:@"local%@/%@",asset.mediaType == 1?@"Image":@"Video",asset.localIdentifier];
                        object.imageThumbnail = result;
                        object.videoTime = [NSString stringWithFormat:@"%f",seconds];
                        object.asset = asset;
                        object.mediaType = asset.mediaType;
                        modelArr[[jindex integerValue]] = object;
                        if (![modelArr containsObject:@"0"]) {
                            nameAndAssetArr[[index integerValue]] = @{@"albumName":tempDic[@"albumName"],@"assetArr":modelArr};
                            statusArr[[index integerValue]] = @"1";
                            if ([statusArr containsObject:@"0"]) {
                                
                            }else{
                                if (complete) {
                                    complete(nameAndAssetArr);
                                }
                            }
                        }
                        
                    }];
                }else{
                    MediaAssetModel *object = [[MediaAssetModel alloc] init];
                    object.localIdentifier = [NSString stringWithFormat:@"local%@/%@",asset.mediaType == 1?@"Image":@"Video",asset.localIdentifier];
                    object.imageThumbnail = result;
                    object.asset = asset;
                    object.mediaType = asset.mediaType;
                    modelArr[[jindex integerValue]] = object;
                    if (![modelArr containsObject:@"0"]) {
                        nameAndAssetArr[[index integerValue]] = @{@"albumName":tempDic[@"albumName"],@"assetArr":modelArr};
                        statusArr[[index integerValue]] = @"1";
                        if ([statusArr containsObject:@"0"]) {
                            
                        }else{
                            if (complete) {
                                complete(nameAndAssetArr);
                            }
                        }
                    }
                }
                
            }];
        }
    }
}

+ (void)fetchCostumMediaAssetModel:(MediaAssetModel *)model localIdentifier:(NSString *)localIdentifier handler:(void (^)(NSData *imageData))handler{
    PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil][0];

//
    PHImageRequestOptions *imageRequestOption = [self configImageRequestOption];
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:imageRequestOption resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        if (handler) {
            if (model) {
                model.imageClear = [UIImage imageWithData:imageData];
            }
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

+ (UIImage *)compressImageSize:(NSData *)imageData toSize:(CGSize)size {

    NSData *data = imageData;
    UIImage *resultImage = [UIImage imageWithData:data];
    UIGraphicsBeginImageContext(size);
    [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

@end
