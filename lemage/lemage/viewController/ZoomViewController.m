//
//  ZoomViewController.m
//  wkWebview
//
//  Created by 王炜光 on 2018/6/7.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import "ZoomViewController.h"
#import "DrawingSingle.h"
@interface ZoomViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UISlider *progressBar;
@property (nonatomic, strong) UILabel *currentPlayTimeLabel;
//@property (nonatomic, strong) id playTimeObserver;
@property (nonatomic, assign) BOOL isSliding;
@property (nonatomic, strong) UIButton *playOrPauseBtn;
@property CGFloat current;
@end

@implementation ZoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (instancetype)init{
    if (self = [super init]) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        self.scrollView.delegate = self;
        self.scrollView.minimumZoomScale = 1;
        self.scrollView.maximumZoomScale = 3;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        
        [self.view addSubview:self.scrollView];
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:self.imageView];
        
        self.tapGestureView = [[UIView alloc] initWithFrame:self.view.frame];
        self.tapGestureView.userInteractionEnabled = YES;
        [self.view addSubview:self.tapGestureView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showOrHideBar:)];
        //把手势添加到置指定的控件上
        [self.tapGestureView addGestureRecognizer:tap];
        
        
        //添加播放按钮
        self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.playBtn.frame = CGRectMake(0, 0, 100, 100);
        [self.playBtn setBackgroundImage:[[DrawingSingle shareDrawingSingle]getPlayImageSize:self.playBtn.frame.size color:[UIColor whiteColor]] forState:UIControlStateNormal];
        self.playBtn.center = self.tapGestureView.center;
        [self.tapGestureView addSubview:self.playBtn];
        [self.playBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)monitoringPlayback:(AVPlayerItem *)item {
    __weak typeof(self)WeakSelf = self;
    // 观察间隔, CMTime 为30分之一秒
    _playTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        WeakSelf.current = CMTimeGetSeconds(time);
        NSLog(@"当前播放时长 %f",WeakSelf.current);
        WeakSelf.setCurrentTime(WeakSelf.current);
        return;
    }];
}

- (void)playVideo:(UIButton*)btn{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    if (_playTimeObserver) {
        
        [self.player removeTimeObserver:_playTimeObserver];
        _playTimeObserver = nil;
    }

    if(self.player.rate){
        self.playBtn.alpha = 1;
        [self.player pause];
    }else{
        self.playBtn.alpha = 0;
        [self.player play];
        self.hideBGView();
    }
    [self monitoringPlayback:self.playerItem];
    
}

- (void)showOrHideBar:(UITapGestureRecognizer *)tap{
    self.gestureBlock();
}
- (void)playbackFinished:(NSNotification *)ntf {
    self.showBGView();
    self.playBtn.alpha = 1;
    if (_playTimeObserver) {
        
        [self.player removeTimeObserver:_playTimeObserver];
        _playTimeObserver = nil;
    }
    [self.player seekToTime:kCMTimeZero];
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)initAvplayer{
    [self.player pause];
    [self.player cancelPendingPrerolls];
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    self.playerItem = nil;
    self.imageView.layer.sublayers = NULL;
}

- (void)setImageFrame{
    self.tapGestureView.frame = self.view.frame;
    self.playBtn.center = self.tapGestureView.center;
    self.scrollView.userInteractionEnabled = YES;
    UIImage *image = self.imageView.image;
    CGFloat picHeight = self.view.frame.size.width * image.size.height/image.size.width;
    CGFloat picWidth = self.view.frame.size.width;
    if (picHeight>self.view.frame.size.height) {
        picHeight = self.view.frame.size.height;
        picWidth = picHeight * image.size.width/image.size.height;
        self.scrollView.maximumZoomScale = self.view.frame.size.width/picWidth+3;
    }else{
        self.scrollView.maximumZoomScale = 3;
    }
    self.imageView.frame = CGRectMake(0, 0, picWidth, picHeight>0?picHeight:0);
    self.scrollView.contentSize = CGSizeMake(picWidth, picHeight>0?picHeight:0);
    self.scrollView.center = self.view.center;
    [self matchImageViewCenter];
}

- (void)setVideoFrame{
    self.tapGestureView.frame = self.view.frame;
    self.playBtn.center = self.tapGestureView.center;
    [self.scrollView setZoomScale:1 animated:true];
    CGFloat picHeight = self.view.frame.size.height;
    CGFloat picWidth = self.view.frame.size.width;
    self.imageView.frame = CGRectMake(0, 0, picWidth, picHeight);
    self.scrollView.contentSize = CGSizeMake(picWidth, picHeight);
    self.scrollView.center = self.view.center;
    self.scrollView.userInteractionEnabled = NO;
    self.playerLayer.frame = self.view.frame;
    [self matchImageViewCenter];
    self.playBtn.center = self.tapGestureView.center;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
     [self matchImageViewCenter];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initScrollview{
    [self.scrollView setZoomScale:1 animated:true];
    
}

//配置imageView 的中心位置: 初始化、变焦前后分别调用
- (void)matchImageViewCenter {
    
    CGFloat contentWidth = self.scrollView.contentSize.width;
    CGFloat horizontalDiff = CGRectGetWidth(self.view.bounds) - contentWidth;//水平方向偏差 总是0
    CGFloat horizontalAddition = horizontalDiff > 0.0 ? horizontalDiff : 0.0;//设置偏差量
    
    CGFloat contentHeight = self.scrollView.contentSize.height;
    CGFloat verticalDiff = CGRectGetHeight(self.view.bounds) - contentHeight;//垂直方向偏差
    
    //设置偏差量 当图片的高宽比大于屏幕的高宽比时,imageView的Y轴为0
    CGFloat verticalAdditon = verticalDiff > 0.0 ? verticalDiff : 0.0;
    //校正图片中心
    _imageView.center = CGPointMake((contentWidth + horizontalAddition) / 2.0, (contentHeight + verticalAdditon) / 2.0);
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.scrollView.frame = self.view.frame;
    if (self.playerLayer) {
        [self setVideoFrame];
    }else{
        [self setImageFrame];
    }
    [self initScrollview];
    [self matchImageViewCenter];
 
}

- (void)setPlayerURL:(NSURL *)playerURL{
    [self initAvplayer];
    _playerURL = playerURL;
    self.playerItem = [[AVPlayerItem alloc]initWithURL:playerURL];
    //    如果要切换视频需要调AVPlayer的replaceCurrentItemWithPlayerItem:方法
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.imageView.bounds;
    //放置播放器的视图
    [self.imageView.layer addSublayer:self.playerLayer];
    self.tapGestureView.alpha = 1;
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
- (void)dealloc
{
    [_player removeTimeObserver:_playTimeObserver];
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
