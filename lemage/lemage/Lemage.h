//
//  lemage.h
//  lemage
//
//  Created by 1iURI on 2018/6/11.
//  Copyright © 2018年 LemonIT.CN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LemageUsageText;
NS_ASSUME_NONNULL_BEGIN

/**
 Lemage中返回结果Block预定义

 @param imageUrlList 选择的图片对应的lemageUrl列表
 @param isOriginal 用户是否选择了原图选项，如果该组件关闭或不支持原图按钮选项，那么此值会始终返回YES
 */
typedef void (^ LEMAGE_RESULT_BLOCK)(NSArray<NSString *> *imageUrlList , BOOL isOriginal);
typedef void (^ LEMAGE_CANCEL_BLOCK)(NSArray<NSString *> *imageUrlList , BOOL isOriginal ,NSInteger NowMediaType);
typedef void (^ LEMAGE_CAMERA_BLOCK)(id item);
@interface Lemage : NSObject

/**
 设置全局文本

 @param usageText 全局文本对象
 */
+ (void)setUsageText: (LemageUsageText *)usageText;

/**
 获取当前的全局文本对象

 @return 当前使用中的全局文本对象
 */
+ (LemageUsageText *)getUsageText;

/**
 启动Lemage
 */
+ (void)startUp;

/**
 根据UIImage对象来生成LemageURL字符串
 原理：将UIImage转成二进制数据存储到沙盒中的文件，然后生成指向沙盒中二进制文件的Lemage格式的URL
 
 @param image 要生成LemageURL的UIImage对象
 @param longTerm 是否永久有效，如果传YES，那么该URL直到调用[Lemage expiredAllLongTermUrl]方法后才失效，如果传NO，在下次APP启动调用[Lemage startUp]方法时URL就会失效，也可以通过[Lemage expiredAllShortTermUrl]来强制使其失效
 @return 生成的LemageURL
 */
+ (NSString *)generateLemageUrl: (UIImage *)image
                       longTerm: (BOOL)longTerm;
/**
 将拍摄的视频生成LemageURL字符串
 原理：将视频存储到沙盒中的文件，然后生成指向沙盒中二进制文件的Lemage格式的URL
 @param AtPath 当前的目录
 @param suffix 视频的后缀
 @return 生成的LemageURL
 */
+ (NSString *)generateLemageUrl: (NSString *)AtPath Suffix:(NSString *)suffix;
/**
 根据LemageURL加载对应的图片的NSData数据，如果用户传入的LemageURL有误或已过期，会返回nil
 注意：此方法并不会处理图片的缩放参数，即LemageURL中的width参数和height参数会被忽略，若需要请调用[Lemage loadImageByLemageUrl]方法
 原理：根据LemageURL解析出沙盒对应的文件路径，然后从沙盒读取文件数据转换成NSData数据对象后返回
 
 @param lemageUrl LemageURL字符串
 @param complete 根据LemageURL逆向转换回来的图片NSData数据对象，如果URL无效会返回nil
 */
+ (void)loadImageDataByLemageUrl: (NSString *)lemageUrl complete:(void(^)(NSData *imageData))complete;

/**
 根据LemageURL加载对应的图片的UIImage对象，如果用户传入的LemageURL有误或已过期，会返回nil
 该函数会解析LemageURL中的width、height参数，如果LemageURL中不存在这两个参数，那么会返回原图
 原理：根据LemageURL解析出沙盒对应的文件路径，然后从沙盒读取文件数据转换成NSData数据后转换成UIImage对象返回
 
 @param lemageUrl LemageURL字符串
 @param complete 根据LemageURL逆向转换回来的图片UIImage对象，如果URL无效会返回nil
 */
+ (void)loadImageByLemageUrl: (NSString *)lemageUrl complete:(void(^)(UIImage *image))complete;

/**
 根据LemageURL加载对应的图片的UIImage对象，如果用户传入的LemageURL有误或已过期，会返回nil
 原理：根据LemageURL解析出沙盒对应的文件路径，然后从沙盒读取文件数据转换成NSData数据后转换成UIImage对象返回
 
 @param lemageUrl LemageURL字符串
 @param size 图片指定大小
 @param complete 根据LemageURL逆向转换回来的图片UIImage对象，如果URL无效会返回nil
 */
+ (void)loadImageByLemageUrl: (NSString *)lemageUrl size:(CGSize)size complete:(void(^)(UIImage *image))complete;

/**
 让所有长期的LemageURL失效
 原理：删除所有本地长期LemageURL对应的沙盒图片文件
 */
+ (void)expiredAllLongTermUrl;

/**
 让所有短期的LemageURL失效
 原理：删除所有本地短期LemageURL对应的沙盒图片文件
 */
+ (void)expiredAllShortTermUrl;

/**
 强制让指定的LemageURL过期，不区分当前URL是长期还是短期
 原理：删除这个LemageURL对应的沙盒图片文件
 
 @param lemageUrl 要使其过期的LemageURL
 */
+ (void)expiredUrl: (NSString *)lemageUrl;
/**
 查询当前是否包含url的缓存文件
 原理:沙盒文件管理查询
 @param url url
 @return dic中如果filename为空表示没有文件
 */
+ (NSDictionary *)queryContainsFileForUrl:(NSURL *)url;
/**
 下载下来的二进制数据添加到缓存当中
 原理:将二进制存储到沙盒

 @param data 二进制文件
 @param url urlMD5加密后作为存贮的标识
 @param type image/video
 @return 返回的存储路径
 */
+(NSString *)saveImageOrVideoWithData:(NSData *)data url:(NSURL *)url type:(NSString *)type;
/**
 获取当前file的路径
 原理:url二进制加密后根据type类型在沙盒中查找
 @param url url
 @param type 类型
 @return filePath文件路径
 */
+(NSString *)getImageOrVideoFile:(NSURL *)url type:(NSString *)type;
/**
 删除缓存文件
 原理:删除所有本地temp对应的沙盒图片视频文件
 */
+ (void)expiredTmpTermUrl;
/**
 启动图片选择器

 @param maxChooseCount 允许最多选择的图片张数，支持范围：1-99
 @param needShowOriginalButton 是否提供【原图】选项按钮，如果不提供，那么选择结果中的【用户是否选择了原图选项】会始终返回YES
 @param themeColor 主题颜色，这个颜色会作为完成按钮、选择顺序标识、相册选择标识的背景色
 @param selectedType  选择器中显示的类型'all' 'image'和'video'默认all
 @param styleType 可以选一种合适都可以选择 'unique'和'mix'默认mix
 @param willClose 当界面即将被关闭的时候的回调函数，若用户在选择器中点击了取消按钮，那么回调函数中的imageUrlList为nil
 @param closed 当界面已经全部关闭的时候的回调函数，回调函数中的参数与willClose中的参数完全一致
 */
+ (void)startChooserWithMaxChooseCount: (NSInteger) maxChooseCount
                needShowOriginalButton: (BOOL) needShowOriginalButton
                            themeColor: (UIColor *) themeColor
                          selectedType: (NSString *) selectedType
                             styleType: (NSString *) styleType
                             willClose: (LEMAGE_RESULT_BLOCK) willClose
                                closed: (LEMAGE_RESULT_BLOCK) closed;


/**
 启动图片预览器

 @param imageUrlArr 要预览的图片URL数组，支持lemageURL和http(s)URL如果对象为nil或数组为空，那么拒绝显示图片预览器
 @param chooseImageUrlArr 已经选择的图片Url数组
 @param allowChooseCount 允许选择的图片数量，如果传<=0的数，表示关闭选择功能（选择器右上角是否有选择按钮），如果允许选择数量小于chooseImageUrlArr数组元素数量，那么会截取chooseImageUrlArr中的数组前allowChooseCount个元素作为已选择图片
 @param showIndex 当前页面所展示的图片下标
 @param themeColor 主题颜色，这个颜色会作为完成按钮、选择顺序标识的背景色
 @param styleType 可以选一种合适都可以选择 'unique'和'mix'默认mix
 @param nowMediaType 当前选择的类型 0 是都可以 1是图片 2是视频
 @param willClose 当界面即将被关闭的时候的回调函数，若用户在选择器中点击了关闭按钮，那么回调函数中的imageUrlList为nil
 @param closed 当界面已经全部关闭的时候的回调函数，回调函数中的参数与willClose中的参数完全一致
 @param cancelBack 当界面点击返回按钮时候的回调函数，回调函数中的参数与willClose中的参数完全一致
 */
+ (void)startPreviewerWithImageUrlArr: (NSArray<NSString *> *)imageUrlArr
                   chooseImageUrlArr: (NSArray<NSString *> *)chooseImageUrlArr
                     allowChooseCount: (NSInteger)allowChooseCount
                            showIndex: (NSInteger)showIndex
                           themeColor: (UIColor *)themeColor
                            styleType: (NSString *) styleType
                         nowMediaType: (NSInteger) nowMediaType
                            willClose: (LEMAGE_RESULT_BLOCK)willClose
                               closed: (LEMAGE_RESULT_BLOCK)closed
                            cancelBack: (LEMAGE_CANCEL_BLOCK)cancelBack;

/**
 开启自定义相机

 @param seconds 视频的长度
 @param themeColor 主体颜色
 @param cameraStatus photo:只拍照;video:只录像;all:都可以(默认)
 @param cameraReturn 返回值(图片或者视频视频的话是url)
 */
+(void)startCameraWithVideoSeconds:(CGFloat)seconds
                        themeColor: (UIColor *)themeColor
                      cameraStatus:(nullable NSString *)cameraStatus
                      cameraReturn:(LEMAGE_CAMERA_BLOCK)cameraReturn;


/**
 将下载下来的网络图片和视频放到指定的沙盒中

 @param AtPath 当前的路径
 @param type 类型(图片还是视频)用来区分文件夹
 @param suffix 文件后缀
 @param fileName 文件名称
 @return 存放的路径
 */
+(NSString *)saveImageOrVideoWithTmpURL:(NSString *)AtPath type:(NSString *)type suffix:(NSString *)suffix name:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
