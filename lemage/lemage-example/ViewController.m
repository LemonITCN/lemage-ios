//
//  ViewController.m
//  lemage-example
//
//  Created by 1iURI on 2018/6/12.
//  Copyright © 2018年 LemonIT.CN. All rights reserved.
//

#import "ViewController.h"
#import "AlbumViewController.h"
#import "CameraImgManagerTool.h"
#import "BrowseImageController.h"
#import "Lemage.h"
#import "DrawingSingle.h"

@interface ViewController ()
@property (nonatomic, strong)NSArray *imgArr;
@property (nonatomic, strong)UITextView *tempTextView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imgArr = [NSArray new];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectedBtn.frame =CGRectMake(0, 0, 100, 50);
    selectedBtn.center = CGPointMake(self.view.center.x/2, 75);
    [selectedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [selectedBtn setTitle:@"选择照片" forState:UIControlStateNormal];
    [self.view addSubview:selectedBtn];
    [selectedBtn addTarget:self action:@selector(selectedImg:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *previewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    previewBtn.frame =CGRectMake(0, 0, 100, 50);
    previewBtn.center = CGPointMake(self.view.center.x/2*3, 75);
    [previewBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [previewBtn setTitle:@"预览照片" forState:UIControlStateNormal];
    [self.view addSubview:previewBtn];
    [previewBtn addTarget:self action:@selector(previewImg:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [CameraImgManagerTool requestPhotosLibraryAuthorization:nil];

    
    _tempTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 100)];
    _tempTextView.editable = NO;
    [self.view addSubview:_tempTextView];
    
    
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraBtn.frame = CGRectMake(0, 0, 100, 50);
    cameraBtn.center = CGPointMake(self.view.center.x/2, 225);
    [cameraBtn setTitle:@"相机" forState:UIControlStateNormal];
    [cameraBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(takeCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraBtn];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(000, 200, 100, 100)];
//    imageView.image = [[DrawingSingle shareDrawingSingle] getPlayImageSize:imageView.frame.size color:[UIColor redColor]];
//    [self.view addSubview:imageView];
    
//    getPauseImageSize
    
    
//    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(000, 350, 100, 100)];
//    imageView2.image = [[DrawingSingle shareDrawingSingle] getPauseImageSize:imageView.frame.size color:[UIColor redColor]];
//    imageView2.userInteractionEnabled = YES;
//    [self.view addSubview:imageView2];
//
//    UISwipeGestureRecognizer *r3 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(doSwipe:)];
//
//    r3.direction = UISwipeGestureRecognizerDirectionRight;
//
//    [imageView2 addGestureRecognizer:r3];
//
//    UISwipeGestureRecognizer *r4 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(doSwipe:)];
//
//    r4.direction = UISwipeGestureRecognizerDirectionLeft;
//    [imageView2 addGestureRecognizer:r4];
}
-(void)doSwipe:(UISwipeGestureRecognizer *)sender{
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        
    }
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        
    }
    CGPoint point = [sender locationInView:self.view];
    NSLog(@"point == %@",NSStringFromCGPoint(point));
}

- (void)selectedImg:(UIButton *)btn{
    [Lemage startChooserWithMaxChooseCount:5 needShowOriginalButton:YES themeColor:[UIColor redColor] selectedType:@"all" styleType:@"unique" willClose:^(NSArray<NSString *> * _Nonnull imageUrlList, BOOL isOriginal) {
        NSLog(@"willClose = %@",imageUrlList);
        self.imgArr = [NSArray arrayWithArray:imageUrlList];
        self.tempTextView.text = [self.imgArr componentsJoinedByString:@","];
    } closed:^(NSArray<NSString *> * _Nonnull imageUrlList, BOOL isOriginal) {
        self.imgArr = [NSArray arrayWithArray:imageUrlList];
        NSLog(@"closed = %@",imageUrlList);
    }];
}

- (void)previewImg:(UIButton *)btn{
//    if (self.imgArr.count>0) {
//        NSArray *tempArr = @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1530359389929&di=eb7ff66711e7e1c58754cd97b39a58ab&imgtype=0&src=http%3A%2F%2Fimg.mukewang.com%2F570762280001d49906000338-590-330.jpg",@"http://static.yoyolearn.com/2.jpg",@"http://wxsnsdy.tc.qq.com/105/20210/snsdyvideodownload?filekey=30280201010421301f0201690402534804102ca905ce620b1241b726bc41dcff44e00204012882540400&bizid=1023&hy=SH&fileparam=302c020101042530230204136ffd93020457e3c4ff02024ef202031e8d7f02030f42400204045a320a0201000400",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1530359389929&di=eb7ff66711e7e1c58754cd97b39a58ab&imgtype=0&src=http%3A%2F%2Fimg.mukewang.com%2F570762280001d49906000338-590-330.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1530359427707&di=2732fca67b3d6c3e21ecd47db8cc5b5a&imgtype=jpg&src=http%3A%2F%2Fimg0.imgtn.bdimg.com%2Fit%2Fu%3D1849880595%2C2259467430%26fm%3D214%26gp%3D0.jpg",@"http://static.yoyolearn.com/1.jpg",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1530359389920&di=39a03b44b581afa2e6092e8b0711e78a&imgtype=0&src=http%3A%2F%2Ftc.sinaimg.cn%2Fmaxwidth.2048%2Ftc.service.weibo.com%2Fp%2Fimage01_xzhichang_com%2F6847f2b222661ff1f2211986f899a074.jpg",@"http://wxsnsdy.tc.qq.com/105/20210/snsdyvideodownload?filekey=30280201010421301f0201690402534804102ca905ce620b1241b726bc41dcff44e00204012882540400&bizid=1023&hy=SH&fileparam=302c020101042530230204136ffd93020457e3c4ff02024ef202031e8d7f02030f42400204045a320a0201000400"];
        [Lemage startPreviewerWithImageUrlArr:self.imgArr chooseImageUrlArr:self.imgArr allowChooseCount:0 showIndex:0 themeColor:[UIColor greenColor] styleType:@"unique" nowMediaType:0 willClose:^(NSArray<NSString *> * _Nonnull imageUrlList, BOOL isOriginal) {
            NSLog(@"preview willClose = %@",imageUrlList);
            self.imgArr = [NSArray arrayWithArray:imageUrlList];
            self.tempTextView.text = [self.imgArr componentsJoinedByString:@","];
        } closed:^(NSArray<NSString *> * _Nonnull imageUrlList, BOOL isOriginal) {
            NSLog(@"preview closed = %@",imageUrlList);
        } cancelBack:^(NSArray<NSString *> * _Nonnull imageUrlList, BOOL isOriginal,NSInteger NowMediaType) {
            
        }];
//    }
    
}

- (void)takeCamera:(UIButton *)btn{
    [Lemage startCameraWithVideoSeconds:5 themeColor:[UIColor cyanColor] cameraStatus:nil cameraReturn:^(id  _Nonnull item) {
        NSLog(@"%@",item);
        self.imgArr = @[item];
        self.tempTextView.text = item;
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
