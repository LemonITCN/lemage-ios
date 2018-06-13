//
//  MediaAssetModel.h
//  wkWebview
//
//  Created by 王炜光 on 2018/6/6.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface MediaAssetModel : NSObject

@property (nonatomic, assign) BOOL selected;//是否已被选中
@property (nonatomic, strong) NSString *imgNo;//图片顺序
@property (nonatomic, strong) PHAsset *asset;//元数据资源

@property (nonatomic, strong) NSString *localIdentifier; //assetId;(根据ID 获取asset)

///大小由宏定义
@property (nonatomic, strong) UIImage *imageClear;//清晰图（原尺寸图片或者是大图{2000, 200s0}）
@property (nonatomic, strong) UIImage *imageThumbnail;//缩略图{250, 250}

@end
