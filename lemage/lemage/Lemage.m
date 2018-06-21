//
//  Lemage.m
//  lemage
//
//  Created by 1iURI on 2018/6/13.
//  Copyright © 2018年 LemonIT.CN. All rights reserved.
//

#import "Lemage.h"
#import "LemageUrlInfo.h"
#import <Photos/Photos.h>
#import "CameraImgManagerTool.h"
#import "AlbumViewController.h"
#import "BrowseImageController.h"
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
    
    NSString *key = [self randomStringWithLength:16];
    NSString *filePath = [NSString  stringWithFormat:@"/private/%@/img/%@/%@.data",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject,fileName,key];
    if([self creatFileWithPath:filePath]){
        //写入内容
        [UIImageJPEGRepresentation(image, 1) writeToFile:filePath atomically:YES];
        return [NSString stringWithFormat:@"lemage://sandbox/%@/%@",fileName,key];
    }
    return nil;
}

/**
 根据LemageURL加载对应的图片的NSData数据，如果用户传入的LemageURL有误或已过期，会返回nil
 注意：此方法并不会处理图片的缩放参数，即LemageURL中的width参数和height参数会被忽略，若需要请调用[Lemage loadImageDataByLemageUrl]方法
 原理：根据LemageURL解析出沙盒对应的文件路径，然后从沙盒读取文件数据转换成NSData数据对象后返回

 @param lemageUrl LemageURL字符串
 @param complete 根据LemageURL逆向转换回来的图片NSData数据对象，如果URL无效会返回nil
 */
+ (void)loadImageDataByLemageUrl: (NSString *)lemageUrl complete:(void(^)(NSData *imageData))complete {

    
    LemageUrlInfo *urlInfo = [[LemageUrlInfo alloc]initWithLemageUrl:lemageUrl];
    if (urlInfo) {
        if ([urlInfo.source isEqualToString:@"sandbox"]) {
                complete([NSData dataWithContentsOfFile:[NSString  stringWithFormat:@"/private/%@/img/%@/%@.data",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject,urlInfo.type,urlInfo.tag]]);
            
        }else{
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[urlInfo.tag] options:nil][0];
            if(asset){
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    if (complete) {
                        complete(imageData);
                    }
                    
                    
                }];
            }else{
                
                    complete(nil);
                
            }
            
        }
    }

}


/**
 根据LemageURL加载对应的图片的UIImage对象，如果用户传入的LemageURL有误或已过期，会返回nil
 原理：根据LemageURL解析出沙盒对应的文件路径，然后从沙盒读取文件数据转换成NSData数据后转换成UIImage对象返回

 @param lemageUrl lemageUrl LemageURL字符串
 @param complete 根据LemageURL逆向转换回来的图片UIImage对象，如果URL无效会返回nil
 */
+ (void)loadImageByLemageUrl: (NSString *)lemageUrl size:(CGSize)size complete:(void(^)(UIImage *image))complete  {

    LemageUrlInfo *urlInfo = [[LemageUrlInfo alloc]initWithLemageUrl:lemageUrl];
    if (urlInfo) {
        if ([urlInfo.source isEqualToString:@"sandbox"]) {
            
            complete([CameraImgManagerTool compressImageSize:[NSData dataWithContentsOfFile:[NSString  stringWithFormat:@"/private/%@/img/%@/%@.data",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject,urlInfo.type,urlInfo.tag]] toSize:size]);
        }else{
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[urlInfo.tag] options:nil][0];
            if(asset){
                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    complete(result);
                }];
            }else{
                complete(nil);
            }

        }
    }
}

/**
 让所有长期的LemageURL失效
 原理：删除所有本地长期LemageURL对应的沙盒图片文件
 */
+ (void)expiredAllLongTermUrl {
    NSString *filePath = [NSString  stringWithFormat:@"/private/%@/img/long",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:nil];
}

/**
 让所有短期的LemageURL失效
 原理：删除所有本地短期LemageURL对应的沙盒图片文件
 */
+ (void)expiredAllShortTermUrl {
    NSString *filePath = [NSString  stringWithFormat:@"/private/%@/img/short",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:nil];
}

/**
 强制让指定的LemageURL过期，不区分当前URL是长期还是短期
 原理：删除这个LemageURL对应的沙盒图片文件
 
 @param lemageUrl 要使其过期的LemageURL
 */
+ (void)expiredUrl: (NSString *)lemageUrl {

    LemageUrlInfo *urlInfo = [[LemageUrlInfo alloc]initWithLemageUrl:lemageUrl];
    if (urlInfo) {
         if ([urlInfo.source isEqualToString:@"sandbox"]) {
             NSString *filePath = [NSString  stringWithFormat:@"/private/%@/img/%@/%@.data",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject,urlInfo.type,urlInfo.tag];
             NSFileManager *fileManager = [NSFileManager defaultManager];
             [fileManager removeItemAtPath:filePath error:nil];
         }else{
             PHFetchResult *pAsset = [PHAsset fetchAssetsWithLocalIdentifiers:@[urlInfo.tag] options:nil];
             if (pAsset) {
                 [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                     [PHAssetChangeRequest deleteAssets:pAsset];
                 } error:nil];
             }
         }
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

/**
 启动图片选择器
 
 @param maxChooseCount 允许最多选择的图片张数，支持范围：1-99
 @param needShowOriginalButton 是否提供【原图】选项按钮，如果不提供，那么选择结果中的【用户是否选择了原图选项】会始终返回YES
 @param themeColor 主题颜色，这个颜色会作为完成按钮、选择顺序标识、相册选择标识的背景色
 @param willClose 当界面即将被关闭的时候的回调函数，若用户在选择器中点击了取消按钮，那么回调函数中的imageUrlList为nil
 @param closed 当界面已经全部关闭的时候的回调函数，回调函数中的参数与willClose中的参数完全一致
 */
+ (void)startChooserWithMaxChooseCount: (NSInteger) maxChooseCount
                needShowOriginalButton: (BOOL) needShowOriginalButton
                            themeColor: (UIColor *) themeColor
                             willClose: (LEMAGE_RESULT_BLOCK) willClose
                                closed: (LEMAGE_RESULT_BLOCK) closed{
    AlbumViewController *VC = [[AlbumViewController alloc]init];
    VC.restrictNumber = MAX(1, MIN(99, maxChooseCount));;
    VC.hideOriginal = !needShowOriginalButton;
    VC.themeColor = themeColor;

    VC.willClose = ^(NSArray<NSString *> *imageUrlList, BOOL isOriginal) {
        willClose(imageUrlList,isOriginal);
    };
    VC.closed = ^(NSArray<NSString *> *imageUrlList, BOOL isOriginal) {
        closed(imageUrlList,isOriginal);
    };
    [[self getCurrentVC] presentViewController:VC animated:YES completion:nil];
}



/**
 启动图片预览器
 
 @param imageUrlArr 要预览的图片URL数组，如果对象为nil或数组为空，那么拒绝显示图片预览器
 @param chooseImageUrlArr 已经选择的图片Url数组
 @param allowChooseCount 允许选择的图片数量，如果传<=0的数，表示关闭选择功能（选择器右上角是否有选择按钮），如果允许选择数量大于chooseImageUrlArr数组元素数量，那么会截取chooseImageUrlArr中的数组前allowChooseCount个元素作为已选择图片
 @param themeColor 主题颜色，这个颜色会作为完成按钮、选择顺序标识的背景色
 @param willClose 当界面即将被关闭的时候的回调函数，若用户在选择器中点击了关闭按钮，那么回调函数中的imageUrlList为nil
 @param closed 当界面已经全部关闭的时候的回调函数，回调函数中的参数与willClose中的参数完全一致
 */
+ (void)startPreviewerWithImageUrlArr: (NSArray<NSString *> *)imageUrlArr
                   chooseImageUrlArr: (NSArray<NSString *> *)chooseImageUrlArr
                     allowChooseCount: (NSInteger)allowChooseCount
                            showIndex: (NSInteger)showIndex
                           themeColor: (UIColor *) themeColor
                            willClose: (LEMAGE_RESULT_BLOCK)willClose
                               closed: (LEMAGE_RESULT_BLOCK)closed{
    BrowseImageController *VC = [[BrowseImageController alloc] init];
    VC.localIdentifierArr = [NSMutableArray arrayWithArray:imageUrlArr];
    VC.selectedImgArr = [NSMutableArray arrayWithArray:chooseImageUrlArr];
    VC.restrictNumber = allowChooseCount;
    VC.themeColor = themeColor;
    VC.showIndex = showIndex;
    VC.willClose = ^(NSArray<NSString *> *imageUrlList, BOOL isOriginal) {
        willClose(imageUrlList,isOriginal);
    };
    VC.closed = ^(NSArray<NSString *> *imageUrlList, BOOL isOriginal) {
        closed(imageUrlList,isOriginal);
    };
    [[self getCurrentVC] presentViewController:VC animated:YES completion:nil];
    
}

/**
 获取当前正在显示的viewcontroller

 @return 正在显示的viewcontroller
 */
+ (UIViewController *)getCurrentVC{
        //获得当前活动窗口的根视图
        UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (1)
        {
            //根据不同的页面切换方式，逐步取得最上层的viewController
            if ([vc isKindOfClass:[UITabBarController class]]) {
                vc = ((UITabBarController*)vc).selectedViewController;
            }
            if ([vc isKindOfClass:[UINavigationController class]]) {
                vc = ((UINavigationController*)vc).visibleViewController;
            }
            if (vc.presentedViewController) {
                vc = vc.presentedViewController;
            }else{
                break;
            }
        }
        return vc;
    }

@end
