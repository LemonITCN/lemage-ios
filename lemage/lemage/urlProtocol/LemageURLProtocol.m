//
//  LemageURLProtocol.m
//  lemage
//
//  Created by 1iURI on 2018/6/13.
//  Copyright © 2018年 LemonIT.CN. All rights reserved.
//

#import "LemageURLProtocol.h"
#import "LemageUrlInfo.h"

@implementation LemageURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([request.URL.scheme caseInsensitiveCompare: LEMAGE] == NSOrderedSame) {
        return YES;
    }
    if ([NSURLProtocol propertyForKey: LEMAGE inRequest:request]) {
        // 处理后的request会打上LEMAGE标记，在这里判断一下，如果打过标记的request会放过，防止死循环
        return NO;
    }
    return NO;
}

- (void)startLoading{
    NSMutableURLRequest* request = self.request.mutableCopy;
    [NSURLProtocol setProperty:@YES forKey: LEMAGE inRequest:request];
    if ([request.URL.scheme caseInsensitiveCompare: LEMAGE] == NSOrderedSame) {
        
    }
    else {
        
    }
}

/**
 根据lemageUrl信息对象逆向找到对应的相册图片，然后将其NSData数据返回

 @param lemageUrlInfo lemageUrl信息对象
 @return lemageUrl信息对象对应的图片的数据NSData对象
 */
- (NSData *)loadImageDataFromAlbumWithLemageURLInfo: (LemageUrlInfo *)lemageUrlInfo {
    return nil;
}

/**
 根据lemageUrl信息对象逆向找到对应的沙盒中的图片文件，然后将其NSData数据返回

 @param lemageUrlInfo lemageUrl信息对象
 @return lemageUrl信息对象对应的图片的数据NSData对象
 */
- (NSData *)loadImageDataFromSandBoxWithLemageURLInfo: (LemageUrlInfo *)lemageUrlInfo {
    return nil;
}

@end
