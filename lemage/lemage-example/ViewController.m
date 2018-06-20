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
}

- (void)selectedImg:(UIButton *)btn{
    AlbumViewController *VC = [[AlbumViewController alloc]init];
    VC.restrictNumber = 0;
    __block typeof(self) weakSelf = self;
    VC.imgIDBlock = ^(NSArray *localIdArr) {
        weakSelf.imgArr = localIdArr;
        weakSelf.tempTextView.text = [weakSelf.imgArr componentsJoinedByString:@","];
    };
    
    [self presentViewController:VC animated:YES completion:nil];
}

- (void)previewImg:(UIButton *)btn{
    if (self.imgArr.count>0) {
        BrowseImageController *vc = [[BrowseImageController alloc] init];
        vc.selectedImgArr = [NSMutableArray arrayWithArray:self.imgArr];
        vc.titleStr = @"预览";
        [self presentViewController:vc animated:YES completion:nil];
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
