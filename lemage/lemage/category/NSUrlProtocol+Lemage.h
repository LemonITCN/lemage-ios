//
//  NSURLProtocol+Lemage.h
//  lemage
//
//  Created by 1iURI on 2018/6/13.
//  Copyright © 2018年 LemonIT.CN. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLProtocol (Lemage)

/**
 注册监听WKWebview中的指定协议头的网络请求

 @param protocol 协议头字符串
 */
+ (void)registerToWKWebviewWithProtocol: (NSString *)protocol;

/**
 解除监听WKWebview中的指定协议头的网络请求

 @param protocol 协议头字符串
 */
+ (void)unregisterToWKWebviewWithProtocol: (NSString *)protocol;

@end

NS_ASSUME_NONNULL_END
