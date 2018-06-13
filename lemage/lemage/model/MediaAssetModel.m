//
//  MediaAssetModel.m
//  wkWebview
//
//  Created by 王炜光 on 2018/6/6.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import "MediaAssetModel.h"

@implementation MediaAssetModel

-(void)setAsset:(PHAsset *)asset {
    _asset = [asset isKindOfClass:[PHAsset class]]?asset:nil;// 防止崩溃
}
@end
