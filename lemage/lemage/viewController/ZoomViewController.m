//
//  ZoomViewController.m
//  wkWebview
//
//  Created by 王炜光 on 2018/6/7.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import "ZoomViewController.h"

@interface ZoomViewController ()<UIScrollViewDelegate>

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
//        [self.scrollView setZoomScale:0.5 animated:YES];
        
        [self.view addSubview:self.scrollView];
        //
        self.imageView = [[UIImageView alloc] init];
        self.imageView.image = [UIImage imageNamed:@"1.jpg"];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:self.imageView];
    }
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    NSLog(@"%@",scrollView);
//    NSLog(@"%@",self.imageView);
    return self.imageView;
}


- (void)initImageViewFrame{
    UIImage *image = self.imageView.image;
    CGFloat picHeight = self.view.frame.size.width * image.size.height/image.size.width;
    CGFloat picWidth = self.view.frame.size.width;
    if (picHeight>self.view.frame.size.height) {
        picHeight = self.view.frame.size.height;
        picWidth = picHeight * image.size.width/image.size.height;
    }
    self.scrollView.frame = CGRectMake(0, 0, picWidth, picHeight);
    //    self.scrollView.frame = CGRectMake(self.view.frame.size.width/2-picWidth/2, self.view.frame.size.height/2-picHeight/2, picWidth, picHeight);
    self.imageView.frame = CGRectMake(0, 0, picWidth, picHeight);
    self.scrollView.center = self.view.center;
    self.scrollView.backgroundColor  = [UIColor cyanColor];
}

- (void)setImageFrame{
    UIImage *image = self.imageView.image;
    CGFloat picHeight = self.view.frame.size.width * image.size.height/image.size.width;
    CGFloat picWidth = self.view.frame.size.width;
    if (picHeight>self.view.frame.size.height) {
        picHeight = self.view.frame.size.height;
        picWidth = picHeight * image.size.width/image.size.height;
    }
//    self.scrollView.frame = CGRectMake(0, 0, picWidth, picHeight);
//    self.scrollView.frame = CGRectMake(self.view.frame.size.width/2-picWidth/2, self.view.frame.size.height/2-picHeight/2, picWidth, picHeight);
    
    self.imageView.frame = CGRectMake(0, 0, picWidth, picHeight>0?picHeight:0);
    self.scrollView.center = self.view.center;
    [self matchImageViewCenter];
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






/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
