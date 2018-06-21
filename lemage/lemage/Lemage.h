//
//  lemage.h
//  lemage
//
//  Created by 1iURI on 2018/6/11.
//  Copyright © 2018年 LemonIT.CN. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Lemage中返回结果Block预定义

 @param imageUrlList 选择的图片对应的lemageUrl列表
 @param isOriginal 用户是否选择了原图选项，如果该组件关闭或不支持原图按钮选项，那么此值会始终返回YES
 */
typedef void (^ LEMAGE_RESULT_BLOCK)(NSArray<NSString *> *imageUrlList , BOOL isOriginal);

@interface Lemage : NSObject

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
                                closed: (LEMAGE_RESULT_BLOCK) closed;


/**
 启动图片预览器

 @param imageUrlArr 要预览的图片URL数组，支持lemageURL和http(s)URL如果对象为nil或数组为空，那么拒绝显示图片预览器
 @param choosedImageUrlArr 已经选择的图片Url数组
 @param allowChooseCount 允许选择的图片数量，如果传<=0的数，表示关闭选择功能（选择器右上角是否有选择按钮），如果允许选择数量大于choosedImageUrlArr数组元素数量，那么会截取choosedImageUrlArr中的数组前allowChooseCount个元素作为已选择图片
 @param themeColor 主题颜色，这个颜色会作为完成按钮、选择顺序标识的背景色
 @param willClose 当界面即将被关闭的时候的回调函数，若用户在选择器中点击了关闭按钮，那么回调函数中的imageUrlList为nil
 @param closed 当界面已经全部关闭的时候的回调函数，回调函数中的参数与willClose中的参数完全一致
 */
+ (void)startPreviewerWithImageUrlArr: (NSArray<NSString *> *)imageUrlArr
                   choosedImageUrlArr: (NSArray<NSString *> *)choosedImageUrlArr
                     allowChooseCount: (NSInteger)allowChooseCount
                            showIndex: (NSInteger)showIndex
                           themeColor: (UIColor *) themeColor
                            willClose: (LEMAGE_RESULT_BLOCK)willClose
                               closed: (LEMAGE_RESULT_BLOCK)closed;

@end

NS_ASSUME_NONNULL_END
