//
//  LemageURLProtocol.m
//  lemage
//
//  Created by 1iURI on 2018/6/13.
//  Copyright © 2018年 LemonIT.CN. All rights reserved.
//

#import "LemageURLProtocol.h"
#import "LemageUrlInfo.h"
#import "Lemage.h"
#import <Photos/Photos.h>


@implementation LemageURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
 
    if ([NSURLProtocol propertyForKey: LEMAGE inRequest:request]) {
        // 处理后的request会打上LEMAGE标记，在这里判断一下，如果打过标记的request会放过，防止死循环
        return NO;
    }
    if ([request.URL.scheme caseInsensitiveCompare: LEMAGE] == NSOrderedSame) {
        return YES;
    }
    return NO;
}
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading{
    NSMutableURLRequest* request = self.request.mutableCopy;
    [NSURLProtocol setProperty:@YES forKey: LEMAGE inRequest:request];
    __block typeof(self) weakSelf = self;
    if ([request.URL.scheme caseInsensitiveCompare: LEMAGE] == NSOrderedSame) {
        NSLog(@"--------------------------");
        
        [Lemage loadImageDataByLemageUrl:request.URL.absoluteString complete:^(NSData * _Nonnull imageData) {
            dispatch_async(dispatch_queue_create("imageDownloadQueueeee", NULL), ^{
                NSLog(@"--------------------------");
                NSData *data = imageData;
                NSURLResponse* response = [[NSURLResponse alloc] initWithURL:weakSelf.request.URL MIMEType:@"lemage/png" expectedContentLength:data.length textEncodingName:nil];
                [weakSelf.client URLProtocol:weakSelf didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
                [weakSelf.client URLProtocol:weakSelf didLoadData:data];
                [weakSelf.client URLProtocolDidFinishLoading:weakSelf];
            });
            
        }];
    }
}
- (void)stopLoading {
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    
    completionHandler(NSURLSessionResponseAllow);
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[self client] URLProtocol:self didLoadData:data];
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
