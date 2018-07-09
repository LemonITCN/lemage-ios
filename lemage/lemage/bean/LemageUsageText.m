//
//  LemageUsageText.m
//  lemage
//
//  Created by 1iURI on 2018/6/21.
//  Copyright © 2018年 LemonIT.CN. All rights reserved.
//

#import "LemageUsageText.h"

static LemageUsageText *CN_TEXT;
static LemageUsageText *EN_TEXT;

@implementation LemageUsageText

+ (LemageUsageText *)cnText{
    if (!CN_TEXT) {
        CN_TEXT = [[LemageUsageText alloc] init];
        CN_TEXT.complete = @"完成";
        CN_TEXT.cancel = @"取消";
        CN_TEXT.back = @"返回";
        CN_TEXT.preview = @"预览";
        CN_TEXT.originalImage = @"原图";
        CN_TEXT.allImages = @"全部图片";
        CN_TEXT.noImages = @"没有图片";
        CN_TEXT.tipSelectedCount = @"最多只能选择%ld张";
        CN_TEXT.selectedType = @"类型不统一";
        CN_TEXT.photoTip = @"轻触拍照,按住摄像";
    }
    return CN_TEXT;
}

+ (LemageUsageText *)enText{
    if (!EN_TEXT) {
        EN_TEXT = [[LemageUsageText alloc] init];
        EN_TEXT.complete = @"Complete";
        EN_TEXT.cancel = @"Cancel";
        EN_TEXT.back = @"Back";
        EN_TEXT.preview = @"Preview";
        EN_TEXT.originalImage = @"Original";
        EN_TEXT.allImages = @"All images";
        EN_TEXT.noImages = @"No images";
        EN_TEXT.tipSelectedCount = @"Select a maximum of %ld images";
        EN_TEXT.selectedType = @"Type disunity";
        EN_TEXT.photoTip = @"Tap to take photot and hold to record video";
    }
    return EN_TEXT;
}

@end
