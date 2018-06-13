//
//  NSURLProtocol+Lemage.m
//  lemage
//
//  Created by 1iURI on 2018/6/13.
//  Copyright © 2018年 LemonIT.CN. All rights reserved.
//

#import "NSURLProtocol+Lemage.h"
#import <WebKit/WebKit.h>

@implementation NSURLProtocol (Lemage)

FOUNDATION_STATIC_INLINE Class ContextControllerClass() {
    static Class cls;
    if (!cls) {
        cls = [[[WKWebView new] valueForKey:@"browsingContextController"] class];
    }
    return cls;
}

FOUNDATION_STATIC_INLINE SEL RegisterSchemeSelector() {
    return NSSelectorFromString(@"registerSchemeForCustomProtocol:");
}

FOUNDATION_STATIC_INLINE SEL UnregisterSchemeSelector() {
    return NSSelectorFromString(@"unregisterSchemeForCustomProtocol:");
}

/**
 注册监听WKWebview中的指定协议头的网络请求
 
 @param protocol 协议头字符串
 */
+ (void)registerToWKWebviewWithProtocol: (NSString *)protocol {
    Class cls = ContextControllerClass();
    SEL sel = RegisterSchemeSelector();
    if ([(id)cls respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [(id)cls performSelector:sel withObject:protocol];
#pragma clang diagnostic pop
    }
}

/**
 解除监听WKWebview中的指定协议头的网络请求
 
 @param protocol 协议头字符串
 */
+ (void)unregisterToWKWebviewWithProtocol: (NSString *)protocol {
    Class cls = ContextControllerClass();
    SEL sel = UnregisterSchemeSelector();
    if ([(id)cls respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [(id)cls performSelector:sel withObject:protocol];
#pragma clang diagnostic pop
    }
}

@end
