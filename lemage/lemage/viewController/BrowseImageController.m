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
@interface BrowseImageController ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource,UIScrollViewDelegate>

/**
 pageview通过三个VC 来进行左右滑动
 */
@property ZoomViewController *leftVC;
@property ZoomViewController *middleVC;
@property ZoomViewController *rightVC;
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
@end

@implementation BrowseImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (_localIdentifierArr.count <= 0) {
        _localIdentifierArr = [NSMutableArray arrayWithArray:_selectedImgArr];
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
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.delegate sendSelectedImgArr:_selectedImgArr];
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    ZoomViewController *tempView = _tempPageVC.viewControllers[0];
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
}

- (void)createMiddleVC{
    _middleVC = [[ZoomViewController alloc] init];
    [self getImageforMediaAsset:_showIndex imageView:_middleVC.imageView viewController:(ZoomViewController *)_middleVC];
    _middleVC.showIndex = _showIndex;
    _middleVC.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showOrHideBar:)];
    //把手势添加到置指定的控件上
    [_middleVC.imageView addGestureRecognizer:tap];
}
- (void)createRightVC{
    _rightVC = [[ZoomViewController alloc] init];
    _rightVC.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showOrHideBar:)];
    //把手势添加到置指定的控件上
    [_rightVC.imageView addGestureRecognizer:tap];
    
}

- (void)showOrHideBar:(UITapGestureRecognizer *)tap{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.titleBarBGView.alpha = 1-weakSelf.titleBarBGView.alpha;
        weakSelf.titleBarBGView.frame = CGRectMake(0, -64-weakSelf.titleBarBGView.frame.origin.y, weakSelf.titleBarBGView.frame.size.width, 64);
        weakSelf.finishBtn.alpha = 1-weakSelf.finishBtn.alpha;
    }];
    
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
    imageView.image = nil;
    MediaAssetModel *assetModel = _mediaAssetArray[index];
    if (assetModel.imageClear) {
        imageView.image = assetModel.imageClear;
        [viewController setImageFrame];
    }else{
        [CameraImgManagerTool fetchCostumMediaAssetModel:assetModel localIdentifier:_localIdentifierArr[index] handler:^(NSData *imageData) {
            imageView.image = nil;
            imageView.image = [UIImage imageWithData:imageData];
            [viewController setImageFrame];
        }];
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
        [_selectButton setBackgroundColor:[UIColor colorWithRed:107/255.0 green:192/255.0 blue:28/255.0 alpha:1]];
    }else{
        _selectButton.layer.borderWidth = 2;
        [_selectButton setTitle:@"" forState:UIControlStateNormal];
        [_selectButton setBackgroundColor:[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1]];
    }
    
    if(_selectedImgArr.count>0){
        [_finishBtn setTitle:[NSString stringWithFormat:@"完成(%ld)",_selectedImgArr.count] forState:UIControlStateNormal];
    }else{
        [_finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    }
    
    
}

- (void)createTitleBar{
    _titleBarBGView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, KIsiPhoneX?84:64)];
    _titleBarBGView.backgroundColor = [UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:0.8];
    [self.view addSubview:_titleBarBGView];
    [self.view bringSubviewToFront:_titleBarBGView];
    
    CGFloat selectedBtnHW = 24;
    _selectButton = [[UIButton alloc] initWithFrame:CGRectMake(0 , 0, selectedBtnHW, selectedBtnHW)];
    _selectButton.center = CGPointMake( _titleBarBGView.frame.size.width-20, _titleBarBGView.frame.size.height-22);
    _selectButton.layer.borderWidth = 2;
    _selectButton.alpha = _restrictNumber>0;
    _selectButton.layer.borderColor = [UIColor colorWithRed:188/255.0 green:188/255.0 blue:188/255.0 alpha:1].CGColor;
    [_selectButton setBackgroundColor:[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1]];
    _selectButton.layer.cornerRadius = 12.0;
    [_selectButton addTarget:self action:@selector(selectedImg:) forControlEvents:UIControlEventTouchUpInside];
    [_titleBarBGView addSubview:_selectButton];

    
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    _backBtn.frame = CGRectMake(0, _titleBarBGView.frame.size.height-34, 40, 24);
    _backBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [_titleBarBGView addSubview:_backBtn];

    _titleLabel = [[UILabel alloc]init];
    _titleLabel.frame = CGRectMake(80, _titleBarBGView.frame.size.height-34, self.view.frame.size.width-160, 24);
    _titleLabel.text = _titleStr;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_titleBarBGView addSubview:_titleLabel];
}

- (void)createFooterBar{
    _finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    _finishBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_finishBtn setBackgroundColor: [UIColor colorWithRed:112/255.0 green:198/255.0 blue:17/255.0 alpha:1/1.0]];
    _finishBtn.frame = CGRectMake(0, 0, 160, 45);
    _finishBtn.center = CGPointMake(self.view.center.x, self.view.frame.size.height-40);
    _finishBtn.layer.cornerRadius = 22.5;
    [self.view  addSubview:_finishBtn];
    [self.view bringSubviewToFront:_finishBtn];
}

- (void)back:(UIButton *)btn{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)selectedImg:(UIButton *)btn{
    
    if(_selectedImgArr.count<=self.restrictNumber){
        if([_selectedImgArr containsObject:self.localIdentifierArr[_showIndex]]){
            
            [self.selectedImgArr removeObject:self.localIdentifierArr[_showIndex]];
            MediaAssetModel *tempModel =self.mediaAssetArray[_showIndex];
            tempModel.selected = NO;
            tempModel.imgNo = nil;
            self.mediaAssetArray[_showIndex] = tempModel;
        }else{
            if (_selectedImgArr.count<self.restrictNumber) {
                MediaAssetModel *tempModel =self.mediaAssetArray[_showIndex];
                tempModel.selected = YES;
                tempModel.imgNo = [NSString stringWithFormat:@"%ld",_showIndex+1];
                self.mediaAssetArray[_showIndex] = tempModel;
                [self.selectedImgArr addObject:self.localIdentifierArr[_showIndex]];
            }else{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"最多只能选择%ld张",_restrictNumber] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *iKnow = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil];
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
    CGSize size = self.view.frame.size;
    _titleBarBGView.frame=CGRectMake(0, 0, size.width,  size.width>size.height?44:KIsiPhoneX?84:64);
    _titleBarBGView.alpha = 1;
    _selectButton.center = CGPointMake( _titleBarBGView.frame.size.width-20, _titleBarBGView.frame.size.height-22);
    _titleLabel.frame = CGRectMake(80, _titleBarBGView.frame.size.height-34, size.width-160, 24);
    _finishBtn.center = CGPointMake(size.width/2, size.height-40);
    _finishBtn.alpha = 1;
    _backBtn.frame = CGRectMake(0, _titleBarBGView.frame.size.height-34, 40,24);
    
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
