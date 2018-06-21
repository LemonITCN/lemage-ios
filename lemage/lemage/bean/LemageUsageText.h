//
//  LemageUsageText.h
//  lemage
//
//  Created by 1iURI on 2018/6/21.
//  Copyright © 2018年 LemonIT.CN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LemageUsageText : NSObject

@property NSString *complete;
@property NSString *cancel;
@property NSString *back;
@property NSString *preview;
@property NSString *originalImage;
@property NSString *allImages;

+ (LemageUsageText *)cnText;
+ (LemageUsageText *)enText;

@end

