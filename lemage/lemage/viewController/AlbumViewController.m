//
//  secondViewController.m
//  wkWebview
//
//  Created by 王炜光 on 2018/5/28.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//


#define KIsiPhoneX ([[UIDevice currentDevice].systemVersion integerValue] >= 11 ?([UIApplication sharedApplication].windows[0].safeAreaInsets.bottom>0) : NO)
#import "AlbumViewController.h"
#import <Photos/Photos.h>
#import "ImageSelectedCell.h"
#import "CameraImgManagerTool.h"
#import "MediaAssetModel.h"
#import "BrowseImageController.h"
#import "ZoomViewController.h"
#import "AlbumCell.h"
#import "DrawingSingle.h"
#import "Lemage.h"
#import "LemageUsageText.h"
#import "ProgressHUD.h"
@interface AlbumViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
/**
 @brief 当前显示照片的UICollectionView
 */
@property (nonatomic, strong) UICollectionView *collection;
/**
 @brief 所有相册
 */
@property (nonatomic, strong) UICollectionView *albumCollection;
/**
 @brief 当先显示的照片数组
 */
@property (nonatomic, strong) NSMutableArray <MediaAssetModel *>*mediaAssetArray;
/**
 @brief 所有的照片
 */
@property (nonatomic, strong) NSMutableArray *allAlbumArray;
/**
 @brief 完成btn
 */
@property (nonatomic, strong) UIButton *finishBtn;
/**
 @brief 当前已选择的图片数组
 */
@property (nonatomic, strong) NSMutableArray *selectedImgArr;
/**
 @brief titleBar背景
 */
@property (nonatomic, strong) UIView *titleBarBGView;
/**
 @brief 动画是否正在执行
 */
@property (nonatomic, assign) BOOL isAnimate;
/**
 @brief 显示在title的btn
 */
@property (nonatomic, strong) UIButton *titleBtn;
/**
 @brief 预览btn
 */
@property (nonatomic, strong) UIButton *previewBtn;
/**
 @brief 原图btn
 */
@property (nonatomic, strong) UIButton *originalImageBtn;
/**
 @brief 当先选择的相册下标
 */
@property (nonatomic, assign) NSUInteger selectedAlbumIndex;
/**
 @brief 没有图片label
 */
@property (nonatomic, strong) UILabel *noImgLabel;
/**
 @brief assets 的localIdentifier数组
 */
@property (nonatomic, strong) NSMutableArray *localIdentifierArr;
/**
 @brief 取消按钮
 */
@property (nonatomic, strong) UIButton *cancelBtn;
/**
 @brief 底部功能按钮背景
 */
@property (nonatomic, strong) UIView *functionBGView;

/**
 @brief 当前选择的类型
 */
@property (nonatomic, assign) NSInteger nowMediaType;
@property (nonatomic, strong) ProgressHUD * progressHUD;

@end

@implementation AlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = false;
    _restrictNumber == 0 ?_restrictNumber = 9 : _restrictNumber;//默认为9
    _mediaAssetArray = [NSMutableArray array];
    _localIdentifierArr = [NSMutableArray array];
    self.selectedAlbumIndex = 0;
    _selectedImgArr = [NSMutableArray new];
    [self initViews];
    [self createTitleBar];
    [self createFunctionView];
    [self createNoImgLabel];
    
    self.progressHUD = [[ProgressHUD alloc] initWithHudColor:[UIColor whiteColor] backgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    [self.view addSubview:self.progressHUD];
    [self.view bringSubviewToFront:self.progressHUD];
    [self.progressHUD progressHUDStart];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self preferredStatusBarStyle];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)initViews{
     [self.navigationController setNavigationBarHidden:YES animated:YES];
     [self.view addSubview:self.collection];
    __block typeof(self) weakSelf = self;
    [CameraImgManagerTool getAllImagesType:self.selectedType complete:^(NSArray<MediaAssetModel *> *allAlbumArray) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            weakSelf.mediaAssetArray = [NSMutableArray arrayWithArray:allAlbumArray];
            if (weakSelf.allAlbumArray) {
                [weakSelf.allAlbumArray insertObject:@{@"albumName":[Lemage getUsageText].allImages,@"assetArr":weakSelf.mediaAssetArray} atIndex:0];
                
            }
            for (MediaAssetModel *tempModel in weakSelf.mediaAssetArray) {
                [weakSelf.localIdentifierArr addObject:[NSString stringWithFormat:@"lemage://album/%@",tempModel.localIdentifier]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.mediaAssetArray.count <= 0) {
                    [weakSelf.view addSubview:weakSelf.noImgLabel];
                    
                }else{
                    [weakSelf.noImgLabel removeFromSuperview];
                }
                [weakSelf.collection reloadData];
                if (weakSelf.allAlbumArray) {
                    [weakSelf.progressHUD progressHUDStop];
                }
            });
        });
        
    }];
    
    [CameraImgManagerTool getAllAlbum:self.selectedType complete:^(NSArray<MediaAssetModel *> *allAlbumArray) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            weakSelf.allAlbumArray = [NSMutableArray arrayWithArray:allAlbumArray];
            if (weakSelf.mediaAssetArray) {
                
                [weakSelf.allAlbumArray insertObject:@{@"albumName":[Lemage getUsageText].allImages,@"assetArr":weakSelf.mediaAssetArray} atIndex:0];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.mediaAssetArray.count <= 0) {
                    [weakSelf.view addSubview:weakSelf.noImgLabel];
                    
                }else{
                    [weakSelf.noImgLabel removeFromSuperview];
                }
                [weakSelf.albumCollection reloadData];
                if (weakSelf.mediaAssetArray) {
                    [weakSelf.progressHUD progressHUDStop];
                }
            });
        });
        
    }];

    [self.view addSubview:self.albumCollection];
}

- (void)createNoImgLabel{
    _noImgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, 30)];
    _noImgLabel.text = [Lemage getUsageText].noImages;
    _noImgLabel.font = [UIFont systemFontOfSize:30];
    _noImgLabel.center = self.view.center;
    _noImgLabel.textAlignment = NSTextAlignmentCenter;
    if (_mediaAssetArray.count <= 0) {
        [self.view addSubview:_noImgLabel];
        
    }else{
        [_noImgLabel removeFromSuperview];
    }
}

- (UICollectionView *)collection {
    if (!_collection) {
        CGRect rect = CGRectMake(0.0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height );
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat gap = 5.0;
        layout.minimumLineSpacing = gap;
        layout.minimumInteritemSpacing = gap;
        layout.sectionInset = UIEdgeInsetsMake(gap, gap, gap, gap);
        CGFloat itemWH = ((self.view.frame.size.width>self.view.frame.size.height?self.view.frame.size.height:self.view.frame.size.width) - gap * 5) / 4;
        layout.itemSize = CGSizeMake(itemWH, itemWH);
        
        
        _collection = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _collection.backgroundColor = [UIColor whiteColor];
        _collection.dataSource = self;
        _collection.delegate = self;
        [_collection registerClass:[ImageSelectedCell class] forCellWithReuseIdentifier:NSStringFromClass([ImageSelectedCell class])];
        [_collection registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView"];
        [_collection registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerView"];
    }
    return _collection;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == ((UIScrollView *)_collection)) {
        if (_albumCollection.frame.origin.y>=0) {
            [self dismissAlbumCollection];
        }
        
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == _collection) {
        if (kind == UICollectionElementKindSectionHeader) {
            UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView" forIndexPath:indexPath];
            //一定不要再这里面创建视图,而是使用自定义的UIClooectionReusableView,涉及到重用的问题
            
            return view;
        }else if(kind == UICollectionElementKindSectionFooter){
            UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerView" forIndexPath:indexPath];
            //一定不要再这里面创建视图,而是使用自定义的UIClooectionReusableView,涉及到重用的问题
            
            return view;
        }else{
            return nil;
        }
    }else{
        return nil;
    }
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (collectionView == _collection) {
        
        return CGSizeMake(0, 44);
    }
    return CGSizeZero;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    
    if (collectionView == _collection) {
        return CGSizeMake(0, 75);
    }
    return CGSizeZero;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == _collection) {
        ImageSelectedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ImageSelectedCell class]) forIndexPath:indexPath];
        //使用了注册,就不需要判断是否为空;
        
        
        cell.themeColor = _themeColor;
        MediaAssetModel *tempModel = self.mediaAssetArray[indexPath.row];
        tempModel.selected = [_selectedImgArr containsObject:self.localIdentifierArr[indexPath.row]]?YES:NO;
        self.mediaAssetArray[indexPath.row]=tempModel;
        cell.assetModel = tempModel;
        cell.canSelected = _selectedImgArr.count>=_restrictNumber?NO:([self.styleType isEqualToString:@"unique"]?(self.nowMediaType>0?(tempModel.mediaType == self.nowMediaType?YES:NO):YES):YES);
        cell.imgNo = [_selectedImgArr containsObject:self.localIdentifierArr[indexPath.row]]?[NSString stringWithFormat:@"%ld",[_selectedImgArr indexOfObject:self.localIdentifierArr[indexPath.row]]+1]:@"";
        __weak typeof(cell) weakCell = cell;
        __weak typeof(self) weakSelf = self;
        cell.selectedBlock = ^(BOOL selected) {
            if(weakSelf.selectedImgArr.count<=self.restrictNumber){
                if([weakSelf.selectedImgArr containsObject:weakSelf.localIdentifierArr[indexPath.row]]){
                    [weakSelf.selectedImgArr removeObject:weakSelf.localIdentifierArr[indexPath.row]];
                }else{
                    [weakSelf.selectedImgArr addObject:weakSelf.localIdentifierArr[indexPath.row]];
                    
                }
                if (weakSelf.selectedImgArr.count == 0) {
                    weakSelf.nowMediaType = 0;
                }else{
                    weakSelf.nowMediaType = weakCell.assetModel.mediaType;
                }
                weakCell.assetModel.selected = !weakCell.assetModel.selected;
                weakCell.selectButton.selected = weakCell.assetModel.selected;
            }
            [weakSelf dismissAlbumCollection];
            [weakSelf setFinishBtnTitle];
            [weakSelf.collection reloadData];
            
            
        };
        return cell;
    }else{
        AlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([AlbumCell class]) forIndexPath:indexPath];
        cell.themeColor = _themeColor;
        NSDictionary *tempDic = _allAlbumArray[indexPath.row];
        NSArray *tempArr =tempDic[@"assetArr"];
        cell.albumTitleStr = [NSString stringWithFormat:@"%@%ld",_allAlbumArray[indexPath.row][@"albumName"],tempArr.count];
        
        if(tempArr.count > 0){
            cell.assetModel = tempArr[0];
        }else{
            cell.assetModel = nil;
        }
        
        if (indexPath.row == _selectedAlbumIndex) {
            cell.selectButton.selected = YES;
        }else{
            cell.selectButton.selected = NO;
        }
        
        __weak typeof(self) weakSelf = self;
        cell.selectedBlock = ^(BOOL selected) {
            [weakSelf initDisplayImage:indexPath.row];
            
        };
        
        return cell;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == _collection) {
        if (_mediaAssetArray.count) {
            [self dismissAlbumCollection];
            
            [Lemage startPreviewerWithImageUrlArr:_localIdentifierArr chooseImageUrlArr:_selectedImgArr allowChooseCount:_restrictNumber showIndex:indexPath.row themeColor:_themeColor styleType:self.styleType nowMediaType:self.nowMediaType willClose:^(NSArray<NSString *> * _Nonnull imageUrlList, BOOL isOriginal) {
                self.selectedImgArr = [NSMutableArray arrayWithArray:imageUrlList];
                if (self.willClose) {
                    self.willClose(self.selectedImgArr, self.originalImageBtn.selected);
                }
            } closed:^(NSArray<NSString *> * _Nonnull imageUrlList, BOOL isOriginal) {
                self.selectedImgArr = [NSMutableArray arrayWithArray:imageUrlList];
                if (self.closed) {
                    self.closed(self.selectedImgArr, self.originalImageBtn.selected);
                }
                
            } cancelBack:^(NSArray<NSString *> * _Nonnull imageUrlList, BOOL isOriginal,NSInteger NowMediaType) {
                self.nowMediaType = NowMediaType;
                self.selectedImgArr = [NSMutableArray arrayWithArray:imageUrlList];
                [self.collection reloadData];
                
            }];
        }
    }else{
        [self initDisplayImage:indexPath.row];
        
    }
    
}

- (void)initDisplayImage:(NSInteger)indexPathRow{
    _mediaAssetArray = [NSMutableArray arrayWithArray:_allAlbumArray[indexPathRow][@"assetArr"]];
    [_localIdentifierArr removeAllObjects];
    for (MediaAssetModel *tempModel in _mediaAssetArray) {
        [_localIdentifierArr addObject:[NSString stringWithFormat:@"lemage://album/%@",tempModel.localIdentifier]];
    }
    
    if (_mediaAssetArray.count <= 0) {
        [self.view addSubview:_noImgLabel];
        
    }else{
        [_noImgLabel removeFromSuperview];
    }
    
    
    _selectedAlbumIndex = indexPathRow;
    [_titleBtn setTitle:_allAlbumArray[indexPathRow][@"albumName"] forState:UIControlStateNormal];
    [_titleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, [self getWidthForWord:_titleBtn.titleLabel.text height:24 font:_titleBtn.titleLabel.font].width, 0, -[self getWidthForWord:_titleBtn.titleLabel.text height:24 font:_titleBtn.titleLabel.font].width)];
    [_albumCollection reloadData];
    [_collection reloadData];
    [self dismissAlbumCollection];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _collection) {
        
        return _mediaAssetArray.count;
    }else{
        return _allAlbumArray.count;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createTitleBar{
    _titleBarBGView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, KIsiPhoneX?84:64)];
    _titleBarBGView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    [self.view addSubview:_titleBarBGView];
    [self.view bringSubviewToFront:_titleBarBGView];
    
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelBtn setTitle:[Lemage getUsageText].cancel forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelSelected:) forControlEvents:UIControlEventTouchUpInside];
    _cancelBtn.frame = CGRectMake(_titleBarBGView.frame.size.width-80, _titleBarBGView.frame.size.height-34, 64, 24);
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    _cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_titleBarBGView addSubview:_cancelBtn ];
    
    _titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _titleBtn.frame = CGRectMake(80, _titleBarBGView.frame.size.height-34, self.view.frame.size.width-160, 24);
    [_titleBtn setTitle:[Lemage getUsageText].allImages forState:UIControlStateNormal];
    [_titleBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_titleBtn setImage:[[DrawingSingle shareDrawingSingle] getTriangleSize:CGSizeMake(16, 16) color:[UIColor whiteColor] positive:YES] forState:UIControlStateNormal];
    [_titleBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -(20), 0, (20))];
    [_titleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, [self getWidthForWord:[Lemage getUsageText].allImages height:24 font:_titleBtn.titleLabel.font].width, 0, -[self getWidthForWord:[Lemage getUsageText].allImages height:24 font:_titleBtn.titleLabel.font].width)];
    [_titleBtn addTarget:self action:@selector(selectdAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [_titleBarBGView addSubview:_titleBtn];
    
}

/**
 自适应宽度

 @param str 字符串
 @param height 设置的高度
 @param font 字体大小
 @return 自适应的cgsize
 */
- (CGSize)getWidthForWord:(NSString *)str height:(CGFloat)height font:(UIFont*)font{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:font.pointSize],NSFontAttributeName, nil];
    CGRect rect = [str boundingRectWithSize:CGSizeMake(0, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    return rect.size;
}


- (void)createFunctionView{
    _functionBGView = [[UIView alloc] init];
    if (_hideOriginal) {
        _functionBGView.frame = CGRectMake(0, self.view.frame.size.height-50, 240, 45);
    }else{
        _functionBGView.frame = CGRectMake(0, self.view.frame.size.height-50, 360, 45);
    }
    _functionBGView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    _functionBGView.layer.cornerRadius = 22.5;
    _functionBGView.layer.masksToBounds = YES;
    _functionBGView.center = CGPointMake(self.view.center.x, self.view.frame.size.height-50);
    [self.view addSubview:_functionBGView];
    [self.view bringSubviewToFront:_functionBGView];
    
    
    
    
    //三个button 预览 原图 和完成按钮
    _previewBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    _previewBtn.userInteractionEnabled=NO;//交互关闭
    _previewBtn.frame = CGRectMake(0, 00, 120, 45);
    _previewBtn.alpha = 0.6;
    [_previewBtn setTitle:[Lemage getUsageText].preview forState:UIControlStateNormal];
    [_previewBtn setTintColor:[UIColor whiteColor]];
    _previewBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_previewBtn addTarget:self action:@selector(previewImg:) forControlEvents:UIControlEventTouchUpInside];
    [_functionBGView addSubview:_previewBtn];
    
    _originalImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _originalImageBtn.selected = _hideOriginal;
    _originalImageBtn.frame = CGRectMake(120, 0, 120, 45);
    [_originalImageBtn setTitle:[Lemage getUsageText].originalImage forState:UIControlStateNormal];
    [_originalImageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_originalImageBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_originalImageBtn setImage:[[DrawingSingle shareDrawingSingle] getCircularSize:CGSizeMake(22, 22) color:[UIColor whiteColor] insideColor:[UIColor clearColor] solid:NO] forState:UIControlStateNormal];
    [_originalImageBtn setImageEdgeInsets:UIEdgeInsetsMake(5, _originalImageBtn.imageEdgeInsets.left, 5,5)];
    _originalImageBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_originalImageBtn addTarget:self action:@selector(useOriginalImage:) forControlEvents:UIControlEventTouchUpInside];
    [_functionBGView addSubview:_originalImageBtn];
    
    _finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_finishBtn setTitle:[Lemage getUsageText].complete forState:UIControlStateNormal];
    [_finishBtn setBackgroundColor:_themeColor];
    _finishBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    _finishBtn.frame = CGRectMake(_functionBGView.frame.size.width-120, 0, 120, 45);
    _finishBtn.userInteractionEnabled=NO;//交互关闭
    _finishBtn.alpha=0.6;//透明度
    [_finishBtn addTarget:self action:@selector(finishSelectedImg: ) forControlEvents:UIControlEventTouchUpInside];
    [_functionBGView addSubview:_finishBtn];
}

- (void)finishSelectedImg:(UIButton *)btn{
    

    if (self.willClose) {
        self.willClose(_selectedImgArr, _originalImageBtn.selected);
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.closed) {
            self.closed(self.selectedImgArr, self.originalImageBtn.selected);
        }
        
    }];
}
/**
 预览图片

 @param btn 预览btn
 */
- (void)previewImg:(UIButton *)btn{

    [Lemage startPreviewerWithImageUrlArr:_selectedImgArr chooseImageUrlArr:_selectedImgArr allowChooseCount:_selectedImgArr.count showIndex:0 themeColor:_themeColor styleType:self.styleType nowMediaType:self.nowMediaType willClose:^(NSArray<NSString *> * _Nonnull imageUrlList, BOOL isOriginal) {
        self.selectedImgArr = [NSMutableArray arrayWithArray:imageUrlList];
        if (self.willClose) {
            self.willClose(self.selectedImgArr, self.originalImageBtn.selected);
        }
    } closed:^(NSArray<NSString *> * _Nonnull imageUrlList, BOOL isOriginal) {
        self.selectedImgArr = [NSMutableArray arrayWithArray:imageUrlList];
        if (self.closed) {
            self.closed(self.selectedImgArr, self.originalImageBtn.selected);
        }
    } cancelBack:^(NSArray<NSString *> * _Nonnull imageUrlList, BOOL isOriginal,NSInteger NowMediaType) {
        self.selectedImgArr = [NSMutableArray arrayWithArray:imageUrlList];
        [self.collection reloadData];
        
    }];
}


/**
 设置完成按钮的title
 */
- (void )setFinishBtnTitle{
    if (_selectedImgArr.count>0) {
        [_finishBtn setTitle:[NSString stringWithFormat:@"%@(%ld)",[Lemage getUsageText].complete,_selectedImgArr.count] forState:UIControlStateNormal];
        _finishBtn.userInteractionEnabled = YES;
        _finishBtn.alpha = 1;
        _previewBtn.userInteractionEnabled = YES;
        _previewBtn.alpha = 1;
    }else{
        [_finishBtn setTitle:[Lemage getUsageText].complete forState:UIControlStateNormal];
        _finishBtn.userInteractionEnabled = NO;
        _finishBtn.alpha = 0.6;
        _previewBtn.userInteractionEnabled = NO;
        _previewBtn.alpha = 0.6;
    }
}


/**
 原图按钮的选择状态改变

 @param btn 原图btn
 */
- (void)useOriginalImage:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [btn setImage:[[DrawingSingle shareDrawingSingle] getCircularSize:CGSizeMake(23, 23) color:[UIColor whiteColor] insideColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0] solid:YES] forState:UIControlStateSelected];
    }else{
        [btn setImage:[[DrawingSingle shareDrawingSingle] getCircularSize:CGSizeMake(22, 22) color:[UIColor whiteColor] insideColor:[UIColor clearColor] solid:NO] forState:UIControlStateNormal];
    }
    
}

- (void)cancelSelected:(UIButton *)btn{
    [self dismissViewControllerAnimated:YES completion:nil];
}



//============================
-(UICollectionView *)albumCollection{
    if(!_albumCollection){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat gap = 5.0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = gap;
        layout.minimumInteritemSpacing = gap;
        layout.sectionInset = UIEdgeInsetsMake(gap, gap, gap, gap);
        CGFloat itemWH = (MIN(self.view.frame.size.height, self.view.frame.size.width) - gap * 5)/4;
        CGRect rect = CGRectMake(0.0,64, [UIScreen mainScreen].bounds.size.width, itemWH+36 );
        
        layout.itemSize = CGSizeMake(itemWH, itemWH+20);
        
        _albumCollection = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _albumCollection.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        _albumCollection.dataSource = self;
        _albumCollection.delegate = self;
        [_albumCollection registerClass:[AlbumCell class] forCellWithReuseIdentifier:NSStringFromClass([AlbumCell class])];
        [self.view insertSubview:_albumCollection belowSubview:_titleBarBGView];
    }
    return _albumCollection;
}

- (void)selectdAlbum:(UIButton *)btn{
    if (self.albumCollection.frame.origin.y<=0) {
        [self showAlbumCollection];
    }else{
        [self dismissAlbumCollection];
    }
}

/**
 隐藏相册
 */
- (void)dismissAlbumCollection{
    if (!_isAnimate) {
        self.isAnimate = YES;
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.4 animations:^{
            CGSize size = self.view.frame.size;
            CGFloat itemWH = size.width>size.height?(size.height/4-50/4):(size.width/4-50/4);
            weakSelf.albumCollection.frame = CGRectMake(0, -itemWH+30-64, weakSelf.albumCollection.frame.size.width, weakSelf.albumCollection.frame.size.height);
            weakSelf.albumCollection.alpha = 0;
            [weakSelf.titleBtn setImage:[[DrawingSingle shareDrawingSingle] getTriangleSize:CGSizeMake(16, 16) color:[UIColor whiteColor] positive:YES] forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            weakSelf.isAnimate = NO;
        }];
    }
    
}

/**
 显示相册
 */
- (void)showAlbumCollection{

    if (!_isAnimate) {
         [_collection setContentOffset:_collection.contentOffset animated:NO];
        self.isAnimate = YES;
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.4 animations:^{
            [weakSelf.albumCollection scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.selectedAlbumIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            
            weakSelf.albumCollection.frame = CGRectMake(0, weakSelf.titleBarBGView.frame.size.height, weakSelf.albumCollection.frame.size.width, weakSelf.albumCollection.frame.size.height);
            weakSelf.albumCollection.alpha = 1;
            
            [weakSelf.titleBtn setImage:[[DrawingSingle shareDrawingSingle] getTriangleSize:CGSizeMake(16, 16) color:[UIColor whiteColor] positive:NO] forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            weakSelf.isAnimate = NO;
        }];
    }
}

/**
 预览界面回调函数

 @param selectedArr 已选择数组
 */
- (void)sendSelectedImgArr:(NSMutableArray *)selectedArr{
    self.selectedImgArr = [NSMutableArray arrayWithArray:selectedArr];
    [self setFinishBtnTitle];
    [_collection reloadData];
}
- (void)viewWillLayoutSubviews{
    
    
    if (!_isAnimate) {
        CGSize size = self.view.frame.size;
        _titleBarBGView.frame = CGRectMake(0, 0, size.width, size.width>size.height?44:KIsiPhoneX?84:64);
        _cancelBtn.frame = CGRectMake(_titleBarBGView.frame.size.width-80, _titleBarBGView.frame.size.height-34, 64, 24);
        _titleBtn.frame = CGRectMake(80, _titleBarBGView.frame.size.height-34, size.width-160, 24);
        _collection.frame = CGRectMake(0, 0, size.width, size.height);
        CGFloat itemWH = (MIN(size.height,size.width) - 5 * 5)/4;
        CGRect rect = CGRectMake(0.0,-itemWH+30-64, size.width, itemWH+36 );
        _albumCollection.frame = rect;
        _albumCollection.alpha = 0;
        _functionBGView.center = CGPointMake(size.width/2, size.height-50);
    }
    
}

#pragma mark - Getters

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
