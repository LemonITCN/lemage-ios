//
//  ZoomViewController.h
//  wkWebview
//
//  Created by 王炜光 on 2018/6/7.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
typedef void (^ LEMAGE_GESTURE_BLOCK)(void);
typedef void (^ LEMAGE_CURRENT_BLOCK)(CGFloat currentTime);
@interface ZoomViewController : UIViewController

/**
 @brief 承载image
 */
@property (nonatomic, strong) UIImageView *imageView;
/**
 @brief 放大缩小
 */
@property (nonatomic, strong) UIScrollView *scrollView;
/**
 当先数组下标
 */
@property (nonatomic, assign) NSUInteger showIndex;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) NSURL *playerURL;
@property(nonatomic, copy) LEMAGE_GESTURE_BLOCK gestureBlock;
@property(nonatomic, copy) LEMAGE_GESTURE_BLOCK hideBGView;
@property(nonatomic, copy) LEMAGE_GESTURE_BLOCK showBGView;
@property(nonatomic, copy) LEMAGE_CURRENT_BLOCK setCurrentTime;
@property (nonatomic, strong) UIView *tapGestureView;
@property (nonatomic, strong) UIButton *playBtn;


@property (nonatomic, strong) id playTimeObserver;
/**
 放大后缩小
 */
-(void)initScrollview;
/**
 自适应图片大小
 */
-(void)setImageFrame;
-(void)setVideoFrame;
-(void)initAvplayer;
- (void)monitoringPlayback:(AVPlayerItem *)item;
@end
