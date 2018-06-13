//
//  LemageUrlInfo.h
//  lemage
//
//  Created by 1iURI on 2018/6/13.
//  Copyright © 2018年 LemonIT.CN. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const LEMAGE = @"lemage";
static NSString * const LEMAGE_SCHEME = @"lemage://";

@interface LemageUrlInfo : NSObject

/**
 图片来源
 */
@property NSString *source;
/**
 图片分类
 */
@property NSString *type;
/**
 图片标识信息
 */
@property NSString *tag;
/**
 LemageURL中的参数列表
 */
@property NSDictionary<NSString *, NSString *> *params;

/**
 通过LemageURL初始化本对象

 @param lemageUrl lemageUrl字符串
 @return LemageURL信息对象实例
 */
- (instancetype)initWithLemageUrl: (NSString *)lemageUrl;

@end

NS_ASSUME_NONNULL_END
