//
//  secondViewController.m
//  wkWebview
//
//  Created by 王炜光 on 2018/5/28.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//


#define KIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#import "AlbumViewController.h"
#import <Photos/Photos.h>
#import "ImageSelectedCell.h"
#import "CameraImgManagerTool.h"
#import "MediaAssetModel.h"
#import "BrowseImageController.h"
#import "ZoomViewController.h"
#import "AlbumCell.h"
#import "DrawingSingle.h"

@interface AlbumViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,BrowseImageControllerDelegate>
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
    
    _mediaAssetArray = [NSMutableArray arrayWithArray:[CameraImgManagerTool getAllImages]];
    for (MediaAssetModel *tempModel in _mediaAssetArray) {
        [_localIdentifierArr addObject:tempModel.localIdentifier];
    }
    [self.collection reloadData];

    
    _allAlbumArray = [NSMutableArray arrayWithArray:[CameraImgManagerTool getAllAlbum]];
    [_allAlbumArray insertObject:@{@"albumName":@"全部图片",@"assetArr":_mediaAssetArray} atIndex:0];
    [self.view addSubview:self.albumCollection];
    [self.albumCollection reloadData];
}

- (void)createNoImgLabel{
    _noImgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, 30)];
    _noImgLabel.text = @"没有图片";
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
        CGFloat gap = 10.0;
        layout.minimumLineSpacing = gap;
        layout.minimumInteritemSpacing = gap;
        layout.sectionInset = UIEdgeInsetsMake(gap, gap, gap, gap);
        CGFloat itemWH = ([UIScreen mainScreen].bounds.size.width - gap * 5) / 4;
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
        cell.contentView.backgroundColor = [UIColor yellowColor];
        
        
        
        MediaAssetModel *tempModel = self.mediaAssetArray[indexPath.row];
//        tempModel.imgNo = [_selectedImgArr containsObject:self.localIdentifierArr[indexPath.row]]?[NSString stringWithFormat:@"%ld",[_selectedImgArr indexOfObject:self.localIdentifierArr[indexPath.row]]+1]:@"";
        self.mediaAssetArray[indexPath.row]=tempModel;
        cell.assetModel = _mediaAssetArray[indexPath.row];
        cell.canSelected = _selectedImgArr.count==_restrictNumber?NO:YES;
        cell.imgNo = [_selectedImgArr containsObject:self.localIdentifierArr[indexPath.row]]?[NSString stringWithFormat:@"%ld",[_selectedImgArr indexOfObject:self.localIdentifierArr[indexPath.row]]+1]:@"";
        __weak typeof(cell) weakCell = cell;
        __weak typeof(self) weakSelf = self;
        cell.selectedBlock = ^(BOOL selected) {
            if(weakSelf.selectedImgArr.count<=self.restrictNumber){
                if(weakCell.selectButton.selected){
//                    [weakSelf.selectedImgArr removeObject:weakSelf.mediaAssetArray[indexPath.row]];
                    [weakSelf.selectedImgArr removeObject:weakSelf.localIdentifierArr[indexPath.row]];
                }else{
//                    [weakSelf.selectedImgArr addObject:weakSelf.mediaAssetArray[indexPath.row]];
                    [weakSelf.selectedImgArr addObject:weakSelf.localIdentifierArr[indexPath.row]];
                    
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
            BrowseImageController *tempVC = [[BrowseImageController alloc] init];
            tempVC.mediaAssetArray =_mediaAssetArray;
            tempVC.localIdentifierArr = _localIdentifierArr;
            tempVC.restrictNumber = _restrictNumber;
            tempVC.selectedImgArr = _selectedImgArr;
            tempVC.localIdentifierArr = _localIdentifierArr;
            tempVC.showIndex = indexPath.row;
            tempVC.delegate = self;
            tempVC.titleStr = _titleBtn.titleLabel.text;
            [self.navigationController pushViewController:tempVC animated:YES];
        }
    }else{
        [self initDisplayImage:indexPath.row];
        
    }
    
}

- (void)initDisplayImage:(NSInteger)indexPathRow{
    _mediaAssetArray = [NSMutableArray arrayWithArray:_allAlbumArray[indexPathRow][@"assetArr"]];
    [_localIdentifierArr removeAllObjects];
    for (MediaAssetModel *tempModel in _mediaAssetArray) {
        [_localIdentifierArr addObject:tempModel.localIdentifier];
    }
    
    if (_mediaAssetArray.count <= 0) {
        [self.view addSubview:_noImgLabel];
        
    }else{
        [_noImgLabel removeFromSuperview];
    }
    
    
    _selectedAlbumIndex = indexPathRow;
    [_titleBtn setTitle:_allAlbumArray[indexPathRow][@"albumName"] forState:UIControlStateNormal];
    [_titleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, [self getWidthForWord:_titleBtn.titleLabel.text height:24 font:_titleBtn.titleLabel.font].width, 0, -[self getWidthForWord:_titleBtn.titleLabel.text height:24 font:_titleBtn.titleLabel.font].width)];
//    [self.selectedImgArr removeAllObjects];
//    [self selectedImgArr];
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
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelSelected:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.frame = CGRectMake(_titleBarBGView.frame.size.width-80, _titleBarBGView.frame.size.height-34, 80, 24);
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    [_titleBarBGView addSubview:cancelBtn];
    
   _titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _titleBtn.frame = CGRectMake(80, _titleBarBGView.frame.size.height-34, self.view.frame.size.width-160, 24);
    [_titleBtn setTitle:@"全部图片" forState:UIControlStateNormal];
    [_titleBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_titleBtn setImage:[[DrawingSingle shareDrawingSingle] getTriangleSize:CGSizeMake(16, 16) color:[UIColor whiteColor] positive:YES] forState:UIControlStateNormal];
    [_titleBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -(20), 0, (20))];
    [_titleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, [self getWidthForWord:@"全部图片" height:24 font:_titleBtn.titleLabel.font].width, 0, -[self getWidthForWord:@"全部图片" height:24 font:_titleBtn.titleLabel.font].width)];
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
    UIView *functionBGView = [[UIView alloc] init];
    if (_hideOriginal) {
        functionBGView.frame = CGRectMake(0, self.view.frame.size.height-60, 240, 45);
    }else{
        functionBGView.frame = CGRectMake(0, self.view.frame.size.height-60, 360, 45);
    }
    functionBGView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    functionBGView.layer.cornerRadius = 22.5;
    functionBGView.layer.masksToBounds = YES;
    functionBGView.center = CGPointMake(self.view.center.x, self.view.frame.size.height-60);
    [self.view addSubview:functionBGView];
    [self.view bringSubviewToFront:functionBGView];
    
    
    
    
    //三个button 预览 原图 和完成按钮
    _previewBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    _previewBtn.userInteractionEnabled=NO;//交互关闭
    _previewBtn.frame = CGRectMake(0, 00, 120, 45);
    _previewBtn.alpha = 0.6;
    [_previewBtn setTitle:@"预览" forState:UIControlStateNormal];
    [_previewBtn setTintColor:[UIColor whiteColor]];
    _previewBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_previewBtn addTarget:self action:@selector(previewImg:) forControlEvents:UIControlEventTouchUpInside];
    [functionBGView addSubview:_previewBtn];
    
    _originalImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _originalImageBtn.selected = NO;
    _originalImageBtn.frame = CGRectMake(120, 0, 120, 45);
    [_originalImageBtn setTitle:@"原图" forState:UIControlStateNormal];
    [_originalImageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_originalImageBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_originalImageBtn setImage:[[DrawingSingle shareDrawingSingle] getCircularSize:CGSizeMake(22, 22) color:[UIColor whiteColor] insideColor:[UIColor clearColor] solid:NO] forState:UIControlStateNormal];
    [_originalImageBtn setImageEdgeInsets:UIEdgeInsetsMake(5, _originalImageBtn.imageEdgeInsets.left, 5,5)];
    _originalImageBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_originalImageBtn addTarget:self action:@selector(useOriginalImage:) forControlEvents:UIControlEventTouchUpInside];
    [functionBGView addSubview:_originalImageBtn];
    
    _finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [_finishBtn setBackgroundColor:[UIColor colorWithRed:94/255.0 green:170/255.0 blue:6/255.0 alpha:1/1.0]];
    _finishBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    _finishBtn.frame = CGRectMake(functionBGView.frame.size.width-120, 0, 120, 45);
    _finishBtn.userInteractionEnabled=NO;//交互关闭
    _finishBtn.alpha=0.6;//透明度
    [_finishBtn addTarget:self action:@selector(finishSelectedImg: ) forControlEvents:UIControlEventTouchUpInside];
    [functionBGView addSubview:_finishBtn];

}

- (void)finishSelectedImg:(UIButton *)btn{
    NSMutableArray *imageArr = [NSMutableArray new];
    for (NSInteger i = 0; i<_selectedImgArr.count; i++) {
        __weak typeof(self) weakSelf = self;
        [CameraImgManagerTool fetchCostumMediaAssetModel:nil localIdentifier:_selectedImgArr[i] handler:^(NSData *imageData) {
            if (weakSelf.originalImageBtn.selected) {
                [imageArr addObject:imageData];
            }else{
                //压缩图片
                [imageArr addObject:[CameraImgManagerTool compressImageSize:imageData toKB:400]];
                
            }
            if (imageArr.count == weakSelf.selectedImgArr.count) {
                NSLog(@"%ld",imageArr.count);
            }
            
        }];
    }
    
    
}

/**
 预览图片

 @param btn 预览btn
 */
- (void)previewImg:(UIButton *)btn{
    BrowseImageController *tempVC = [[BrowseImageController alloc] init];
    tempVC.selectedImgArr = _selectedImgArr;
    tempVC.showIndex = 0;
    tempVC.restrictNumber = _selectedImgArr.count;
    tempVC.delegate = self;
    tempVC.titleStr = @"预览";
    
    NSMutableArray *tempArr = [NSMutableArray new];
    for (NSInteger i= 0; i<_mediaAssetArray.count;i++) {
        if ([_selectedImgArr containsObject:_mediaAssetArray[i].localIdentifier]) {
            [tempArr addObject:_mediaAssetArray[i]];
        }
        if (tempArr.count == _selectedImgArr.count) {
            break;
        }
    }
    tempVC.mediaAssetArray = tempArr;
    
    [self.navigationController pushViewController:tempVC animated:YES];
}


/**
 设置完成按钮的title
 */
- (void )setFinishBtnTitle{
    if (_selectedImgArr.count>0) {
        [_finishBtn setTitle:[NSString stringWithFormat:@"完成(%ld)",_selectedImgArr.count] forState:UIControlStateNormal];
        _finishBtn.userInteractionEnabled = YES;
        _finishBtn.alpha = 1;
        _previewBtn.userInteractionEnabled = YES;
        _previewBtn.alpha = 1;
    }else{
        [_finishBtn setTitle:@"完成" forState:UIControlStateNormal];
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
        [btn setImage:[[DrawingSingle shareDrawingSingle] getCircularSize:CGSizeMake(23, 23) color:[UIColor whiteColor] insideColor:[UIColor greenColor] solid:YES] forState:UIControlStateSelected];
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
        CGFloat gap = 10.0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = gap;
        layout.minimumInteritemSpacing = gap;
        layout.sectionInset = UIEdgeInsetsMake(0, gap, 0, gap);
        CGFloat itemWH = self.view.frame.size.width/4-50/4;
        CGRect rect = CGRectMake(0.0,64, [UIScreen mainScreen].bounds.size.width, itemWH+30 );
        
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
            weakSelf.albumCollection.frame = CGRectMake(0, -weakSelf.view.frame.size.width/4-50/4+30, weakSelf.albumCollection.frame.size.width, weakSelf.view.frame.size.width/4-50/4+30);
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
            weakSelf.albumCollection.frame = CGRectMake(0, 64, weakSelf.albumCollection.frame.size.width, weakSelf.view.frame.size.width/4-50/4+30);
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    _titleBarBGView.frame = CGRectMake(0, 0, size.width, _titleBarBGView.frame.size.height);
    _cancelBtn.frame = CGRectMake(_titleBarBGView.frame.size.width-80, _titleBarBGView.frame.size.height-34, 80, 24);
    _titleBtn.frame = CGRectMake(80, _titleBarBGView.frame.size.height-34, size.width-160, 24);
    _collection.frame = CGRectMake(0, 0, size.width, size.height);
    
    CGFloat itemWH = size.width>size.height?(size.height/4-50/4):(size.width/4-50/4);
    CGRect rect = CGRectMake(0.0,-itemWH+30-64, size.width, itemWH+30 );
    _albumCollection.frame = rect;
    _functionBGView.center = CGPointMake(size.width/2, size.height-60);
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
