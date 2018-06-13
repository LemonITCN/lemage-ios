//
//  LemageUrlInfo.m
//  lemage
//
//  Created by 1iURI on 2018/6/13.
//  Copyright © 2018年 LemonIT.CN. All rights reserved.
//

#import "LemageUrlInfo.h"

@implementation LemageUrlInfo

- (instancetype)initWithLemageUrl:(NSString *)lemageUrl {
    if (self = [super init]) {
        if ([lemageUrl rangeOfString: LEMAGE_SCHEME].location != 0) {
            // 该字符串并不是LEMAGE规定的协议开头
            self = nil;
        }
        else {
            NSArray<NSString *> *parts = [lemageUrl componentsSeparatedByString: @"?"];
            NSArray<NSString *> *strItems = [parts[0] componentsSeparatedByString: @"/"];
            if (strItems.count < 5) {
                // 数组元素少于5，不符合规则
                self = nil;
            }
            NSInteger prefixLength = 0;
            for (NSInteger index = 0; index < 4; index ++) {
                prefixLength += (strItems[index].length + 1);
            }
            self.tag = [lemageUrl substringFromIndex: prefixLength];
            self.source = strItems[2];
            self.type = strItems[3];
            NSMutableDictionary *paramsTemp = [[NSMutableDictionary alloc] init];
            if (parts.count > 1) {
                // 说明有参数列表
                NSArray<NSString *> *paramStrs = [parts[1] componentsSeparatedByString: @"&"];
                for (NSString *paramItem in paramStrs) {
                    // 遍历所有键值对参数
                    NSArray<NSString *> *paramParts = [paramItem componentsSeparatedByString: @"="];
                    if (paramParts.count > 1) {
                        paramsTemp[paramParts[0]] = paramParts[1];
                    }
                }
            }
            self.params = paramsTemp;
        }
    }
    return self;
}

@end
