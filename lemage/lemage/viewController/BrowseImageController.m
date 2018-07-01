//
//  BorwseImageController.m
//  wkWebview
//
//  Created by 王炜光 on 2018/6/6.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//
#define KIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#import "BrowseImageController.h"
#import "ZoomViewController.h"
#import "MediaAssetModel.h"
#import "CameraImgManagerTool.h"
#import "LemageUsageText.h"
#import "Lemage.h"
#import "LemageUrlInfo.h"
#import "DrawingSingle.h"
#import "MediaProgressBar.h"
@interface BrowseImageController ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource,UIScrollViewDelegate>

/**
 pageview通过三个VC 来进行左右滑动
 */
@property ZoomViewController *leftVC;
@property ZoomViewController *middleVC;
@property ZoomViewController *rightVC;

/**
 动画是否在执行
 */
@property BOOL isAnimate;
/**
 @brief 标题Bar
 */
@property UIView *titleBarBGView;
/**
 @brief 选择按钮
 */
@property UIButton *selectButton;
/**
 @brief 完成按钮
 */
@property UIButton *finishBtn;
/**
 @brief pageviewcontrollver的scrollview
 */
@property UIScrollView *tempScrollview;
/**
 @brief 实现轮播的pageVC
 */
@property UIPageViewController *tempPageVC;
/**
 @brief 底部的BG
 */
@property UIView *footerBarBGView;
/**
 @brief 顶部title
 */
@property UILabel *titleLabel;
/**
 @brief 返回按钮
 */
@property UIButton *backBtn;



@property UIView *funtionBGView;

@property UIButton *playOrPauseBtn;

@property MediaProgressBar *progressBar;

@property UILabel *currentPlayTimeLabel;

@property UILabel *allTimeLabel;

@property (nonatomic, assign) BOOL isSliding;

@property NSURLSessionDataTask *sessionDataTaskLeft;
@property NSURLSessionDataTask *sessionDataTaskMiddle;
@property NSURLSessionDataTask *sessionDataTaskRight;
@end
static dispatch_queue_t queue;

@implementation BrowseImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (_localIdentifierArr.count <= 0) {
        _localIdentifierArr = [NSMutableArray arrayWithArray:_selectedImgArr];
    }
    _mediaAssetArray = [NSMutableArray new];
    for (NSString *localId in _localIdentifierArr) {
        MediaAssetModel *tempModel = [[MediaAssetModel alloc] init];
//        if ([urlInfo.source isEqualToString:@"album"]) {
//
//            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[urlInfo.tag] options:nil][0];
//            tempModel.mediaType = asset.mediaType;
//        }else{
        
            tempModel.mediaType = 0;
//        }
//        NSLog(@"%ld",tempModel.mediaType);
        [self.mediaAssetArray addObject:tempModel];
        
    }
    [self createMiddleVC];
    [self createRightVC];
    [self createLeftVC];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    
    // 设置UIPageViewController的配置项
    NSDictionary *options = @{UIPageViewControllerOptionInterPageSpacingKey : @(20)};
    
    
    _tempPageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    _tempPageVC.delegate = self;
    _tempPageVC.dataSource  = self;
    
    
    [_tempPageVC setViewControllers:@[_middleVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    _tempPageVC.view.frame = self.view.frame;

    
    
    [self addChildViewController:_tempPageVC];
    [self.view addSubview:_tempPageVC.view];

    
    _tempScrollview = [[UIScrollView alloc] init];
    for(id subview in _tempPageVC.view.subviews){
        
        if([subview isKindOfClass:UIScrollView.class]){
            _tempScrollview = subview;
            _tempScrollview.delegate = self;
            break;
        }
    }
    
    [self createTitleBar];
    [self createFooterBar];
    [self setSelectedButtonTitle:_showIndex];
    [self createFuntionBGView];
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showOrHideBar:)];
//        //把手势添加到置指定的控件上
//        [_tempPageVC.view addGestureRecognizer:tap];
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    ZoomViewController *tempView = _tempPageVC.viewControllers[0];
    [tempView.player pause];
    tempView.playBtn.alpha = 1;
    self.funtionBGView.alpha = 0;
    self.finishBtn.alpha = self.titleBarBGView.alpha;
    if (tempView.playTimeObserver) {
        [tempView.player removeTimeObserver:tempView.playTimeObserver];
        tempView.playTimeObserver = nil;
    }
    self.isSliding = NO;
    self.currentPlayTimeLabel.text = @"00:00";
    [tempView.player seekToTime:kCMTimeZero];
    self.progressBar.value = 0;
    [self.playOrPauseBtn setImage:[[DrawingSingle shareDrawingSingle]getPauseImageSize:CGSizeMake(50, 50) color:[UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1]] forState:UIControlStateNormal];
    [self setSelectedButtonTitle:tempView.showIndex];
    
}





- (void)viewWillAppear:(BOOL)animated{
    [self preferredStatusBarStyle];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)createLeftVC{
    _leftVC = [[ZoomViewController alloc] init];
    _leftVC.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showOrHideBar:)];
    //把手势添加到置指定的控件上
    [_leftVC.imageView addGestureRecognizer:tap];
    
    __weak typeof(self) weakSelf = self;
    _leftVC.gestureBlock = ^{
        if (weakSelf.leftVC.player.rate) {
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.funtionBGView.alpha = 1-weakSelf.titleBarBGView.alpha;
                weakSelf.titleBarBGView.alpha = 1-weakSelf.titleBarBGView.alpha;
                CGSize size = weakSelf.view.frame.size;
                weakSelf.titleBarBGView.frame=CGRectMake(0, -(size.width>size.height?44:KIsiPhoneX?84:64)-weakSelf.titleBarBGView.frame.origin.y, size.width,  size.width>size.height?44:KIsiPhoneX?84:64);
            }];
        }else{
            
            if(weakSelf.leftVC.playBtn.alpha){
                [weakSelf showOrHideBar:nil];
            }else{
                [UIView animateWithDuration:0.2 animations:^{
                    weakSelf.titleBarBGView.alpha = 1;
                    CGSize size = weakSelf.view.frame.size;
                    weakSelf.titleBarBGView.frame=CGRectMake(0, 0, size.width,  size.width>size.height?44:KIsiPhoneX?84:64);
                    weakSelf.finishBtn.alpha = weakSelf.selectedImgArr.count > 0?1:0.6;
                }];
                
            }
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.leftVC.playBtn.alpha = 1;
                weakSelf.funtionBGView.alpha = 0;
            }];
            
        }
    };
    _leftVC.showBGView = ^{
        [weakSelf showBar];
        
        weakSelf.progressBar.value = 0;
    };
    _leftVC.hideBGView = ^{
        [weakSelf hideBar];
//        weakSelf.funtionBGView.alpha = 1;
        weakSelf.isSliding = NO;
        [weakSelf.playOrPauseBtn setImage:[[DrawingSingle shareDrawingSingle]getPauseImageSize:CGSizeMake(50, 50) color:[UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1]] forState:UIControlStateNormal];
        [weakSelf setAlltimeLabelText:weakSelf.leftVC];
    };
    _leftVC.setCurrentTime = ^(CGFloat currentTime) {
        if (!weakSelf.isSliding) {
            weakSelf.currentPlayTimeLabel.text = [weakSelf timeFormatted:(int)currentTime];
            weakSelf.progressBar.value = currentTime;
        }
        
    };
}

- (void)createMiddleVC{
    _middleVC = [[ZoomViewController alloc] init];
    [self getImageforMediaAsset:_showIndex imageView:_middleVC.imageView viewController:(ZoomViewController *)_middleVC];
    _middleVC.showIndex = _showIndex;
    _middleVC.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showOrHideBar:)];
    //把手势添加到置指定的控件上
    [_middleVC.imageView addGestureRecognizer:tap];
    __weak typeof(self) weakSelf = self;
    _middleVC.gestureBlock = ^{
        if (weakSelf.middleVC.player.rate) {
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.funtionBGView.alpha = 1-weakSelf.titleBarBGView.alpha;
                weakSelf.titleBarBGView.alpha = 1-weakSelf.titleBarBGView.alpha;
                CGSize size = weakSelf.view.frame.size;
                weakSelf.titleBarBGView.frame=CGRectMake(0, -(size.width>size.height?44:KIsiPhoneX?84:64)-weakSelf.titleBarBGView.frame.origin.y, size.width,  size.width>size.height?44:KIsiPhoneX?84:64);
            }];
        }else{
            
            if(weakSelf.middleVC.playBtn.alpha){
                [weakSelf showOrHideBar:nil];
            }else{
                [UIView animateWithDuration:0.2 animations:^{
                    weakSelf.titleBarBGView.alpha = 1;
                    CGSize size = weakSelf.view.frame.size;
                    weakSelf.titleBarBGView.frame=CGRectMake(0, 0, size.width,  size.width>size.height?44:KIsiPhoneX?84:64);
                    weakSelf.finishBtn.alpha = weakSelf.selectedImgArr.count > 0?1:0.6;
                }];
                
            }
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.middleVC.playBtn.alpha = 1;
                weakSelf.funtionBGView.alpha = 0;
            }];
        }
    };
    
    _middleVC.showBGView = ^{
        [weakSelf showBar];
//        weakSelf.funtionBGView.alpha = 0;
        weakSelf.progressBar.value = 0;
    };
    _middleVC.hideBGView = ^{
        [weakSelf hideBar];
//        weakSelf.funtionBGView.alpha = weakSelf.titleBarBGView.alpha;
        weakSelf.isSliding = NO;
        [weakSelf.playOrPauseBtn setImage:[[DrawingSingle shareDrawingSingle]getPauseImageSize:CGSizeMake(50, 50) color:[UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1]] forState:UIControlStateNormal];
        [weakSelf setAlltimeLabelText:weakSelf.middleVC];
    };
    _middleVC.setCurrentTime = ^(CGFloat currentTime) {
        if (!weakSelf.isSliding) {
            weakSelf.currentPlayTimeLabel.text = [weakSelf timeFormatted:(int)currentTime];
            weakSelf.progressBar.value = currentTime;
        }
    };
    
}
- (void)createRightVC{
    _rightVC = [[ZoomViewController alloc] init];
    _rightVC.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showOrHideBar:)];
    //把手势添加到置指定的控件上
    [_rightVC.imageView addGestureRecognizer:tap];
    __weak typeof(self) weakSelf = self;
    _rightVC.gestureBlock = ^{
        if (weakSelf.rightVC.player.rate) {
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.funtionBGView.alpha = 1-weakSelf.titleBarBGView.alpha;
                weakSelf.titleBarBGView.alpha = 1-weakSelf.titleBarBGView.alpha;
                CGSize size = weakSelf.view.frame.size;
                weakSelf.titleBarBGView.frame=CGRectMake(0, -(size.width>size.height?44:KIsiPhoneX?84:64)-weakSelf.titleBarBGView.frame.origin.y, size.width,  size.width>size.height?44:KIsiPhoneX?84:64);
            }];
        }else{
            
            if(weakSelf.rightVC.playBtn.alpha){
                [weakSelf showOrHideBar:nil];
            }else{
                [UIView animateWithDuration:0.2 animations:^{
                    weakSelf.titleBarBGView.alpha = 1;
                    CGSize size = weakSelf.view.frame.size;
                    weakSelf.titleBarBGView.frame=CGRectMake(0, 0, size.width,  size.width>size.height?44:KIsiPhoneX?84:64);
                    weakSelf.finishBtn.alpha = weakSelf.selectedImgArr.count > 0?1:0.6;
                }];
                
            }
            
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.rightVC.playBtn.alpha = 1;
                weakSelf.funtionBGView.alpha = 0;
            }];
            
        }
    };
    _rightVC.showBGView = ^{
        [weakSelf showBar];
//        weakSelf.funtionBGView.alpha = 0;
        weakSelf.progressBar.value = 0;
    };
    _rightVC.hideBGView = ^{
        [weakSelf hideBar];
//        weakSelf.funtionBGView.alpha = 1;
        weakSelf.isSliding = NO;
        [weakSelf.playOrPauseBtn setImage:[[DrawingSingle shareDrawingSingle]getPauseImageSize:CGSizeMake(50, 50) color:[UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1]] forState:UIControlStateNormal];
        [weakSelf setAlltimeLabelText:weakSelf.rightVC];
    };
    _rightVC.setCurrentTime = ^(CGFloat currentTime) {
        if (!weakSelf.isSliding) {
            weakSelf.currentPlayTimeLabel.text = [weakSelf timeFormatted:(int)currentTime];
            weakSelf.progressBar.value = currentTime;
        }
    };
}
- (void)showBar{
    __weak typeof(self) weakSelf = self;
    if (!_isAnimate) {
        _isAnimate = YES;
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.funtionBGView.alpha = 0;
            weakSelf.titleBarBGView.alpha = 1;
            CGSize size = self.view.frame.size;
            weakSelf.titleBarBGView.frame=CGRectMake(0, 0, size.width,  size.width>size.height?44:KIsiPhoneX?84:64);
            weakSelf.finishBtn.alpha = weakSelf.selectedImgArr.count > 0?1:0.6;
        } completion:^(BOOL finished) {
            weakSelf.isAnimate = NO;
        }];
    }
    
    
}
- (void)hideBar{
    __weak typeof(self) weakSelf = self;
    if (!_isAnimate) {
        _isAnimate = YES;
        [UIView animateWithDuration:0.2 animations:^{
//            weakSelf.titleBarBGView.alpha = 0;
//            CGSize size = self.view.frame.size;
//            weakSelf.titleBarBGView.frame=CGRectMake(0, -(size.width>size.height?44:KIsiPhoneX?84:64), size.width,  size.width>size.height?44:KIsiPhoneX?84:64);
            weakSelf.funtionBGView.alpha = weakSelf.titleBarBGView.alpha;
            weakSelf.finishBtn.alpha = 0;
        } completion:^(BOOL finished) {
            weakSelf.isAnimate = NO;
        }];
    }
    
    
}
- (void)showOrHideBar:(UITapGestureRecognizer *)tap{
    __weak typeof(self) weakSelf = self;
    if (!_isAnimate) {
        _isAnimate = YES;
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.titleBarBGView.alpha = 1-weakSelf.titleBarBGView.alpha;
            CGSize size = self.view.frame.size;
            weakSelf.titleBarBGView.frame=CGRectMake(0, -(size.width>size.height?44:KIsiPhoneX?84:64)-weakSelf.titleBarBGView.frame.origin.y, size.width,  size.width>size.height?44:KIsiPhoneX?84:64);
            weakSelf.finishBtn.alpha = weakSelf.finishBtn.alpha>0?0:(weakSelf.selectedImgArr.count > 0?1:0.6);
        } completion:^(BOOL finished) {
            weakSelf.isAnimate = NO;
        }];
    }
    
    
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    ZoomViewController * tempVC  = (ZoomViewController *)viewController;
    _showIndex = tempVC.showIndex;
    [self setSelectedButtonTitle:_showIndex];
    if (_showIndex>=1) {
        [_leftVC initScrollview];
        [_middleVC initScrollview];
        [_rightVC initScrollview];
        if (_middleVC == viewController) {
            _leftVC.showIndex =_showIndex - 1;
            [self getImageforMediaAsset:_showIndex-1 imageView:_leftVC.imageView viewController:_leftVC];
            return _leftVC;
        }else if (_leftVC == viewController){
            _rightVC.showIndex =_showIndex - 1;
            [self getImageforMediaAsset:_showIndex-1 imageView:_rightVC.imageView viewController:_rightVC];
            return _rightVC;
        }else{
            _middleVC.showIndex =_showIndex - 1;
            [self getImageforMediaAsset:_showIndex-1 imageView:_middleVC.imageView viewController:_middleVC];
            return _middleVC;
        }
    }else{
        return nil;
    }
}




- (void)getImageforMediaAsset:(NSInteger)index imageView:(UIImageView *)imageView viewController:(ZoomViewController *)viewController{
    
    viewController.tapGestureView.alpha = 0;
    [viewController initAvplayer];
    
    LemageUrlInfo *urlInfo = [[LemageUrlInfo alloc] initWithLemageUrl:_localIdentifierArr[index]];
    NSURL *url = [NSURL URLWithString:_localIdentifierArr[index]];
    MediaAssetModel *assetModel = _mediaAssetArray[index];
    
    
    Float64 seconds = 0;
    AVAsset *videoAsset;
        if ([urlInfo.type isEqualToString:@"localVideo"]) {
            imageView.image = nil;
            [viewController setVideoFrame];
            viewController.playerLayer = [[AVPlayerLayer alloc] init];
            viewController.playerLayer.frame = viewController.imageView.frame;
            [viewController.imageView.layer addSublayer:viewController.playerLayer];
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[urlInfo.tag] options:nil][0];
            [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
                viewController.player = [AVPlayer playerWithPlayerItem:playerItem];
                viewController.playerLayer.player = viewController.player;
            }];
            viewController.tapGestureView.alpha = 1;
        }else{
            imageView.image = [UIImage imageNamed:@"placeholder"];
            if (assetModel.imageClear) {
                imageView.image = assetModel.imageClear;
                [viewController setImageFrame];
            }else{
                NSString *dataTastName = @"";
                switch (viewController== _leftVC?1:viewController== _middleVC?2:3) {
                    case 1:
                        dataTastName = @"sessionDataTaskLeft";
                        break;
                    case 2:
                        dataTastName = @"sessionDataTaskMiddle";
                        break;
                    case 3:
                        dataTastName = @"sessionDataTaskRight";
                        break;
                        
                    default:
                        break;
                }
                NSURLSessionDataTask *dataTak = (NSURLSessionDataTask *)[self valueForKey:dataTastName];
                if (dataTak) {
                    [dataTak cancel];
                }
                
//                NSURL *url = [NSURL URLWithString:_localIdentifierArr[index]];
                
                // 2.创建一个网络请求
                
                NSURLRequest *request =[NSURLRequest requestWithURL:url];
                
                // 3.获得会话对象
                
                NSURLSession *session = [NSURLSession sharedSession];
                
                // 4.根据会话对象，创建一个Task任务：
                NSURLSessionDataTask *tempSessionDataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSDictionary *dictionary = ((NSHTTPURLResponse *)response).allHeaderFields;
                    if ([dictionary[@"Content-Type"] containsString:@"image"]) {
                        assetModel.mediaType = 1;
                        NSString *filePath = [Lemage saveImageOrVideoWithData:data url:url type:@"image"];
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]];
                            if (image) {
                                imageView.image = image;
                            }
                            [viewController setImageFrame];
                        });
                    } else if ([dictionary[@"Content-Type"] containsString:@"video"]) {
                        assetModel.mediaType = 2;
                        NSString *filePath = [Lemage saveImageOrVideoWithData:data url:url type:@"video"];
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            imageView.image = nil;
                            [viewController setVideoFrame];
                            viewController.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:filePath]];
                            viewController.player = [[AVPlayer alloc] initWithPlayerItem:viewController.playerItem];
                            viewController.playerLayer = [AVPlayerLayer playerLayerWithPlayer:viewController.player];
                            viewController.playerLayer.frame = imageView.bounds;
                            //放置播放器的视图
                            [viewController.imageView.layer addSublayer:viewController.playerLayer];
                            viewController.tapGestureView.alpha = 1;
                        });
                    }else{
                        
                        //                        NSLog(@"%@",jsonDict);
                        NSLog(@"%@",response.MIMEType);
                        NSLog(@"7");
                        if ([response.MIMEType isEqualToString:@"tempFile/unknow"]) {
                            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                            NSLog(@"8");
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                if ([jsonDict[@"type"] isEqualToString:@"image"]) {
                                    NSLog(@"9");
                                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:jsonDict[@"fileName"]]];
                                    NSLog(@"10");
                                    if (image) {
                                        imageView.image = image;
                                    }
                                    [viewController setImageFrame];
                                    
                                }else{
                                    imageView.image = nil;
                                    [viewController setVideoFrame];
                                    viewController.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:jsonDict[@"fileName"]]];
                                    viewController.player = [[AVPlayer alloc] initWithPlayerItem:viewController.playerItem];
                                    viewController.playerLayer = [AVPlayerLayer playerLayerWithPlayer:viewController.player];
                                    viewController.playerLayer.frame = imageView.bounds;
                                    //放置播放器的视图
                                    [viewController.imageView.layer addSublayer:viewController.playerLayer];
                                    viewController.tapGestureView.alpha = 1;
                                }
                            });
                        }else{
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                UIImage *image = [UIImage imageWithData:data];
                                if (image) {
                                    imageView.image = image;
                                }
                                [viewController setImageFrame];
                            });
                        }
                        /*
                         
                         对从服务器获取到的数据data进行相应的处理：
                         
                         */
                        
                    }
                    self.mediaAssetArray[index] = assetModel;
                }];
                // 5.最后一步，执行任务（resume也是继续执行）:
                [tempSessionDataTask resume];
                [self setValue:tempSessionDataTask forKey:dataTastName];
            }
            
        }

}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    ZoomViewController * tempVC  = (ZoomViewController *)viewController;
    _showIndex = tempVC.showIndex;
    [self setSelectedButtonTitle:_showIndex];
    
    if(_showIndex<_localIdentifierArr.count-1){
        [_leftVC initScrollview];
        [_middleVC initScrollview];
        [_rightVC initScrollview];
        if (_middleVC == viewController) {
            
            
            _rightVC.showIndex =_showIndex + 1;
            [self getImageforMediaAsset:_showIndex+1 imageView:_rightVC.imageView viewController:_rightVC];
            return _rightVC;
        }else if (_leftVC == viewController){
            
            _middleVC.showIndex =_showIndex + 1;
            [self getImageforMediaAsset:_showIndex+1 imageView:_middleVC.imageView viewController:_middleVC];
            return _middleVC;
        }else{
            
            _leftVC.showIndex =_showIndex + 1;
            [self getImageforMediaAsset:_showIndex+1 imageView:_leftVC.imageView viewController:_leftVC];
            return _leftVC;
        }
    }else{
        return nil;
    }
    
}

- (void)setSelectedButtonTitle:(NSInteger)index{
    
    if ([_selectedImgArr containsObject:self.localIdentifierArr[index]]) {
        [_selectButton setTitle:[NSString stringWithFormat:@"%ld",[_selectedImgArr indexOfObject:self.localIdentifierArr[index]]+1] forState:UIControlStateNormal];
        _selectButton.layer.borderWidth = 0;
        [_selectButton setBackgroundColor:_themeColor];
    }else{
        _selectButton.layer.borderWidth = 2;
        [_selectButton setTitle:@"" forState:UIControlStateNormal];
        [_selectButton setBackgroundColor:[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1]];
    }
    
    if(_selectedImgArr.count>0){
        [_finishBtn setTitle:[NSString stringWithFormat:@"%@(%ld)",[Lemage getUsageText].complete,_selectedImgArr.count] forState:UIControlStateNormal];
        _finishBtn.userInteractionEnabled = YES;
        _finishBtn.alpha = _finishBtn.alpha==0?0:1;
    }else{
        [_finishBtn setTitle:[Lemage getUsageText].complete forState:UIControlStateNormal];
        _finishBtn.userInteractionEnabled = NO;
        _finishBtn.alpha = _finishBtn.alpha==0?0:0.6;
    }
    _titleLabel.text = [NSString stringWithFormat:@"%ld/%ld",index+1,_localIdentifierArr.count];
    
}

- (void)createTitleBar{
    _titleBarBGView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, KIsiPhoneX?84:64)];
    _titleBarBGView.backgroundColor = [UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:0.8];
    [self.view addSubview:_titleBarBGView];
    [self.view bringSubviewToFront:_titleBarBGView];
    
    CGFloat selectedBtnHW = 24;
    _selectButton = [[UIButton alloc] initWithFrame:CGRectMake(0 , 0, selectedBtnHW, selectedBtnHW)];
    _selectButton.center = CGPointMake( _titleBarBGView.frame.size.width-28, _titleBarBGView.frame.size.height-22);
    _selectButton.layer.borderWidth = 2;
    _selectButton.alpha = _restrictNumber>0;
    _selectButton.layer.borderColor = [UIColor colorWithRed:188/255.0 green:188/255.0 blue:188/255.0 alpha:1].CGColor;
    [_selectButton setBackgroundColor:[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1]];
    _selectButton.layer.cornerRadius = 12.0;
    [_selectButton addTarget:self action:@selector(selectedImg:) forControlEvents:UIControlEventTouchUpInside];
    [_titleBarBGView addSubview:_selectButton];

    
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backBtn setTitle:[Lemage getUsageText].back forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    _backBtn.frame = CGRectMake(16, _titleBarBGView.frame.size.height-34, 64, 24);
    _backBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    _backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_titleBarBGView addSubview:_backBtn];

    _titleLabel = [[UILabel alloc]init];
    _titleLabel.frame = CGRectMake(80, _titleBarBGView.frame.size.height-34, self.view.frame.size.width-160, 24);
    _titleLabel.text = [NSString stringWithFormat:@"%ld/%ld",_showIndex+1,_localIdentifierArr.count];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_titleBarBGView addSubview:_titleLabel];
}

- (void)createFooterBar{
    _finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_finishBtn setTitle:[Lemage getUsageText].complete forState:UIControlStateNormal];
    
    _finishBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_finishBtn setBackgroundColor: _themeColor];
    _finishBtn.frame = CGRectMake(0, 0, 160, 45);
    _finishBtn.center = CGPointMake(self.view.center.x, self.view.frame.size.height-40);
    _finishBtn.layer.cornerRadius = 22.5;
    [_finishBtn addTarget:self action:@selector(finishedSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.view  addSubview:_finishBtn];
    [self.view bringSubviewToFront:_finishBtn];
}

- (void)finishedSelected:(UIButton *)btn{
    if (self.willClose) {
        self.willClose([NSArray arrayWithArray:_selectedImgArr], NO);
    }
    
    [self.presentingViewController.presentingViewController?self.presentingViewController.presentingViewController:self dismissViewControllerAnimated:YES completion:^{
        if (self.closed) {
            self.closed(self.selectedImgArr, NO);
        }
    }];
}

- (void)back:(UIButton *)btn{
    if (self.cancelBack) {
        self.cancelBack([NSArray arrayWithArray:_selectedImgArr], NO,self.nowMediaType);
    }
    [self dismissViewControllerAnimated:YES completion:nil];

    
}

- (void)selectedImg:(UIButton *)btn{
    MediaAssetModel *tempModel =self.mediaAssetArray[_showIndex];
    if(_selectedImgArr.count<=self.restrictNumber){
        if (!([self.styleType isEqualToString:@"unique"]?(self.nowMediaType>0?(tempModel.mediaType == self.nowMediaType?YES:NO):YES):YES)) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"类型不统一" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *iKnow = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:iKnow];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        if([_selectedImgArr containsObject:self.localIdentifierArr[_showIndex]]){
            
            [self.selectedImgArr removeObject:self.localIdentifierArr[_showIndex]];
            if (self.selectedImgArr.count == 0) {
                self.nowMediaType = 0;
            }
            tempModel.selected = NO;
            tempModel.imgNo = nil;
            self.mediaAssetArray[_showIndex] = tempModel;
        }else{
            if (_selectedImgArr.count<self.restrictNumber) {
                self.nowMediaType = tempModel.mediaType;
                tempModel.selected = YES;
                tempModel.imgNo = [NSString stringWithFormat:@"%ld",_showIndex+1];
                self.mediaAssetArray[_showIndex] = tempModel;
                [self.selectedImgArr addObject:self.localIdentifierArr[_showIndex]];
            }else{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:[Lemage getUsageText].tipSelectedCount,_restrictNumber] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *iKnow = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:iKnow];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        }
    }
    [self setSelectedButtonTitle:_showIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillLayoutSubviews{
    if (!_isAnimate) {
        
        CGSize size = self.view.frame.size;
        _titleBarBGView.frame=CGRectMake(0, 0, size.width,  size.width>size.height?44:KIsiPhoneX?84:64);
        _titleBarBGView.alpha = 1;
        _selectButton.center = CGPointMake( _titleBarBGView.frame.size.width-28, _titleBarBGView.frame.size.height-22);
        _titleLabel.frame = CGRectMake(80, _titleBarBGView.frame.size.height-34, size.width-160, 24);
        _finishBtn.center = CGPointMake(size.width/2, size.height-40);
        _finishBtn.alpha = 1;
        _backBtn.frame = CGRectMake(16, _titleBarBGView.frame.size.height-34, 64,24);
        _funtionBGView.frame = CGRectMake(0, self.view.frame.size.height-60, self.view.frame.size.width, 60);
        _progressBar.frame = CGRectMake(60, 30, self.view.frame.size.width-70, 20);
    }
}

- (void)createFuntionBGView{
    self.funtionBGView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-60, self.view.frame.size.width, 60)];
    [self.view addSubview:self.funtionBGView];
    self.funtionBGView.backgroundColor = [UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:0.8];
    [self.view bringSubviewToFront:self.funtionBGView]; 
    
    self.playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playOrPauseBtn.frame = CGRectMake(0, 0, 60, 60);
    [self.playOrPauseBtn setImage:[[DrawingSingle shareDrawingSingle]getPauseImageSize:CGSizeMake(50, 50) color:[UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1]] forState:UIControlStateNormal];
    [self.playOrPauseBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.funtionBGView addSubview:self.playOrPauseBtn];
    
    self.currentPlayTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 40, 20)];
    self.currentPlayTimeLabel.textColor  = [UIColor whiteColor];
    self.currentPlayTimeLabel.font = [UIFont systemFontOfSize:13];
    self.currentPlayTimeLabel.text = @"00:00";
    self.currentPlayTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.funtionBGView addSubview:self.currentPlayTimeLabel];
    
    UILabel *divisionLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 10, 20)];
    divisionLabel.text = @"/";
    divisionLabel.font = [UIFont systemFontOfSize:13];
    divisionLabel.textColor = [UIColor whiteColor];
    divisionLabel.textAlignment = NSTextAlignmentCenter;
    [self.funtionBGView addSubview:divisionLabel];
    
    
    self.allTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 40, 20)];
    self.allTimeLabel.textColor  = [UIColor whiteColor];
    self.allTimeLabel.font = [UIFont systemFontOfSize:13];
    self.allTimeLabel.text = @"00:00";
    self.allTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.funtionBGView addSubview:self.allTimeLabel];
    self.funtionBGView.alpha = 0;
    
    self.progressBar = [[MediaProgressBar alloc] initWithFrame:CGRectMake(60, 30, self.view.frame.size.width-70, 20)];
    [self.progressBar setThumbImage:[[DrawingSingle shareDrawingSingle] OriginImageToSize:CGSizeMake(20, 20)] forState:UIControlStateNormal];
    self.progressBar.userInteractionEnabled = YES;
    self.progressBar.minimumTrackTintColor = [UIColor whiteColor];
    self.progressBar.maximumTrackTintColor = [UIColor grayColor];
    [self.funtionBGView addSubview:self.progressBar];
    [self.progressBar addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.progressBar addTarget:self action:@selector(sliderValueEndChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
}

- (void)playVideo:(UIButton*)btn{
    ZoomViewController *tempView = _tempPageVC.viewControllers[0];

    if (tempView.playTimeObserver) {
        
        [tempView.player removeTimeObserver:tempView.playTimeObserver];
        tempView.playTimeObserver = nil;
    }
    if(tempView.player.rate){
        [self.playOrPauseBtn setImage:[[DrawingSingle shareDrawingSingle]getPlayImageSize:CGSizeMake(50, 50) color:[UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1]] forState:UIControlStateNormal];
        _isSliding = YES;
        
        [tempView.player pause];
    }else{
        [self.playOrPauseBtn setImage:[[DrawingSingle shareDrawingSingle]getPauseImageSize:CGSizeMake(50, 50) color:[UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1]] forState:UIControlStateNormal];
        _isSliding = NO;
        [tempView.player play];
    }
    [tempView monitoringPlayback:tempView.playerItem];
}
- (void)sliderValueChanged:(UISlider *)slider {
    _isSliding = YES;
    ZoomViewController *tempView = _tempPageVC.viewControllers[0];
    [tempView.player pause];
    self.currentPlayTimeLabel.text = [self timeFormatted:(int)MIN(MAX(self.progressBar.value, 0), self.progressBar.maximumValue)];
    [self.playOrPauseBtn setImage:[[DrawingSingle shareDrawingSingle]getPlayImageSize:CGSizeMake(50, 50) color:[UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1]] forState:UIControlStateNormal];
    CMTime changedTime = CMTimeMakeWithSeconds(MIN(MAX(self.progressBar.value, 0), self.progressBar.maximumValue), 10.0);
    [tempView.player seekToTime:changedTime];
}

-(void)sliderValueEndChanged:(UISlider *)slider{
    
    ZoomViewController *tempView = _tempPageVC.viewControllers[0];
    CMTime changedTime = CMTimeMakeWithSeconds(MIN(MAX(self.progressBar.value, 0), self.progressBar.maximumValue), 10.0);
    __block typeof(self) weakSelf = self;
    [tempView.player seekToTime:changedTime completionHandler:^(BOOL finished) {
        weakSelf.isSliding = NO;
        [tempView.player play];
        [weakSelf.playOrPauseBtn setImage:[[DrawingSingle shareDrawingSingle]getPauseImageSize:CGSizeMake(50, 50) color:[UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1]] forState:UIControlStateNormal];
    }];
}


- (NSString *)timeFormatted:(int)totalSeconds{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    if (hours==0) {
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}
//格式话小数 四舍五入类型
- (NSString *) decimalwithFormat:(NSString *)format  floatV:(float)floatV{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    [numberFormatter setPositiveFormat:format];
    
    return  [numberFormatter stringFromNumber:[NSNumber numberWithFloat:floatV]];
}

- (void)setAlltimeLabelText:(ZoomViewController *)viewController{
    CMTime time = viewController.player.currentItem.asset.duration;
    Float64 seconds = CMTimeGetSeconds(time);
    self.allTimeLabel.text = [self timeFormatted:[[self decimalwithFormat:@"0" floatV:seconds] intValue]];
    self.progressBar.maximumValue = seconds;
}
- (void)dealloc
{
    [Lemage expiredTmpTermUrl];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
