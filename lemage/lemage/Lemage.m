//
//  Lemage.m
//  lemage
//
//  Created by 1iURI on 2018/6/13.
//  Copyright © 2018年 LemonIT.CN. All rights reserved.
//

#import "Lemage.h"

@implementation Lemage

/**
 启动Lemage
 */
+ (void)startUp {
    
}

/**
 根据UIImage对象来生成LemageURL字符串
 原理：将UIImage转成二进制数据存储到沙盒中的文件，然后生成指向沙盒中二进制文件的Lemage格式的URL
 
 @param image 要生成LemageURL的UIImage对象
 @param longTerm 是否永久有效，如果传YES，那么该URL直到调用[Lemage expiredAllLongTermUrl]方法后才失效，如果传NO，在下次APP启动调用[Lemage startUp]方法时URL就会失效，也可以通过[Lemage expiredAllShortTermUrl]来强制使其失效
 @return 生成的LemageURL
 */
+ (NSString *)generateLemageUrl: (UIImage *)image
                       longTerm: (BOOL)longTerm {
    NSString *fileName;
    if(longTerm){
        fileName = @"long";
    }else{
        fileName = @"short";
    }
    NSString *filePath = [NSString  stringWithFormat:@"%@img/%@/imgBinary.plist",NSTemporaryDirectory(),fileName];
    if([self creatFileWithPath:filePath]){
        
        NSMutableDictionary *tempImgDic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath]?[NSMutableDictionary dictionaryWithContentsOfFile:filePath]:[NSMutableDictionary new];
        //写入内容
        NSString *key = [self randomStringWithLength:16];
        [tempImgDic setObject:UIImageJPEGRepresentation(image, 0.8) forKey:key];
        [tempImgDic writeToFile:filePath atomically:YES];
        return [NSString stringWithFormat:@"lemage://sandbox/%@/%@",fileName,key];
    }
    return nil;
}

/**
 根据LemageURL加载对应的图片的NSData数据，如果用户传入的LemageURL有误或已过期，会返回nil
 注意：此方法并不会处理图片的缩放参数，即LemageURL中的width参数和height参数会被忽略，若需要请调用[Lemage loadImageDataByLemageUrl]方法
 原理：根据LemageURL解析出沙盒对应的文件路径，然后从沙盒读取文件数据转换成NSData数据对象后返回
 
 @param lemageUrl LemageURL字符串
 @return 根据LemageURL逆向转换回来的图片NSData数据对象，如果URL无效会返回nil
 */
+ (NSData *)loadImageDataByLemageUrl: (NSString *)lemageUrl {
    NSString *key = [lemageUrl stringByReplacingOccurrencesOfString:@"lemage://" withString:@""];
    NSArray *strArr = [key componentsSeparatedByString:@"/"];
    if (strArr.count <3) {
        return nil;//文件路径错误
    }
    if ([strArr[0] isEqualToString:@"sandbox"]) {
        key = strArr[2];
        NSMutableDictionary *tempImgDic = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@img/%@/imgBinary.plist",NSTemporaryDirectory(),strArr[1]]];
        return tempImgDic[key];//查询对应的key为空时自动返会nil;
    }else{
        //相册
    }
    
    return nil;
}

/**
 根据LemageURL加载对应的图片的UIImage对象，如果用户传入的LemageURL有误或已过期，会返回nil
 原理：根据LemageURL解析出沙盒对应的文件路径，然后从沙盒读取文件数据转换成NSData数据后转换成UIImage对象返回
 
 @param lemageUrl LemageURL字符串
 @return 根据LemageURL逆向转换回来的图片UIImage对象，如果URL无效会返回nil
 */
+ (UIImage *)loadImageByLemageUrl: (NSString *)lemageUrl {
    NSString *key = [lemageUrl stringByReplacingOccurrencesOfString:@"lemage://" withString:@""];
    NSArray *strArr = [key componentsSeparatedByString:@"/"];
    if (strArr.count <3) {
        return nil;
    }
    if ([strArr[0] isEqualToString:@"sandbox"]) {
        key = strArr[2];
        NSMutableDictionary *tempImgDic = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@img/%@/imgBinary.plist",NSTemporaryDirectory(),strArr[1]]];
        return [UIImage imageWithData:tempImgDic[key]];
    }else{
       //相册
    }
    return nil;
}

/**
 让所有长期的LemageURL失效
 原理：删除所有本地长期LemageURL对应的沙盒图片文件
 */
+ (void)expiredAllLongTermUrl {
    NSString *filePath = [NSString stringWithFormat:@"%@img/long",NSTemporaryDirectory()];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:nil];
}

/**
 让所有短期的LemageURL失效
 原理：删除所有本地短期LemageURL对应的沙盒图片文件
 */
+ (void)expiredAllShortTermUrl {
    NSString *filePath = [NSString stringWithFormat:@"%@img/short",NSTemporaryDirectory()];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:nil];
}

/**
 强制让指定的LemageURL过期，不区分当前URL是长期还是短期
 原理：删除这个LemageURL对应的沙盒图片文件
 
 @param lemageUrl 要使其过期的LemageURL
 */
+ (void)expiredUrl: (NSString *)lemageUrl {
    NSString *key = [lemageUrl stringByReplacingOccurrencesOfString:@"lemage://" withString:@""];
    NSArray *strArr = [key componentsSeparatedByString:@"/"];
    if (strArr.count <3) {
        NSLog(@"文件路径错误");
    }
    if ([strArr[0] isEqualToString:@"sandbox"]) {
        key = strArr[2];
        NSMutableDictionary *tempImgDic = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@img/%@/imgBinary.plist",NSTemporaryDirectory(),strArr[1]]];
        [tempImgDic removeObjectForKey:key];
        [tempImgDic writeToFile:[NSString stringWithFormat:@"%@img/%@/imgBinary.plist",NSTemporaryDirectory(),strArr[1]] atomically:YES];
    }else{
        //相册的东西
    }
    
    
}



/**
 创建图片NSData文件
 原理:先查询是否已经创建过文件夹,如果没有则创建一个相应的文件用来存储图片data
 @param filePath 文件路径
 @return 是否已经创建过
 */
+(BOOL)creatFileWithPath:(NSString *)filePath
{
    BOOL isSuccess = YES;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL temp = [fileManager fileExistsAtPath:filePath];
    if (temp) {
        return YES;
    }
    NSError *error;
    //stringByDeletingLastPathComponent:删除最后一个路径节点
    NSString *dirPath = [filePath stringByDeletingLastPathComponent];
    isSuccess = [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"creat File Failed. errorInfo:%@",error);
    }
    if (!isSuccess) {
        return isSuccess;
    }
    isSuccess = [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    return isSuccess;
}


/**
 根据传入的长度随机生成等长度的UUID字符串

 @param len 字符串长度
 @return 返回的字符串
 */
+(NSString *)randomStringWithLength:(NSInteger)len {
    
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}


@end
