//
//  imageSelectedCell.m
//  wkWebview
//
//  Created by 王炜光 on 2018/6/6.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import "ImageSelectedCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation ImageSelectedCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.backgroundColor = [UIColor cyanColor];
        _imageView.layer.masksToBounds = true;
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void)clickedBtn:(UIButton *)sender {
    if (_assetModel) {
        if (_selectedBlock) {
            _selectedBlock(!_selectButton.selected);
        }
    }
}

- (void)layoutSubviews{
    
}

- (void)setCanSelected:(BOOL)canSelected{
    _canSelected = canSelected;
    if (!_whiteView) {
        _whiteView = [[UIView alloc]initWithFrame:self.contentView.frame];
    }
    _whiteView.backgroundColor = [UIColor whiteColor];
    if (_canSelected || _selectButton.selected) {
        _whiteView.alpha = 0;
    }else{
        _whiteView.alpha = 0.5;
    }
    [self.contentView addSubview:_whiteView];
}

- (void)setAssetModel:(MediaAssetModel *)assetModel {
    if ([assetModel isKindOfClass:[MediaAssetModel class]]) {
        _assetModel = assetModel;
        self.selectButton.selected = _assetModel.selected;
        if (_assetModel.imageThumbnail) {
            self.imageView.image = _assetModel.imageThumbnail;
        }
    }
    
}

- (void)setImgNo:(NSString *)imgNo{
    _imgNo = imgNo;
    if (self.imgNo.length > 0) {
        _selectButton.layer.borderWidth = 0;
        [_selectButton setTitle:self.imgNo forState:UIControlStateNormal];
        [_selectButton setBackgroundColor:[UIColor colorWithRed:107/255.0 green:192/255.0 blue:28/255.0 alpha:1]];
    }else{
        _selectButton.layer.borderWidth = 2;
        [_selectButton setTitle:@"" forState:UIControlStateNormal];
        [_selectButton setBackgroundColor:[UIColor clearColor]];
    }
}


- (UIButton *)selectButton {
    
    if (!_selectButton) {
        CGFloat selectedBtnHW = 24;
        _selectButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - selectedBtnHW-3 , 3, selectedBtnHW, selectedBtnHW)];
        [self.contentView addSubview:_selectButton];
        _selectButton.layer.borderWidth = 2;
        _selectButton.layer.borderColor = [UIColor colorWithRed:188/255.0 green:188/255.0 blue:188/255.0 alpha:1].CGColor;
        _selectButton.layer.cornerRadius = 12.0;
        [_selectButton addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
        _selectButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _selectButton.alpha = 0.8;
        _selectHideButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2 , 0, self.frame.size.width/2, self.frame.size.height/2)];
        [_selectHideButton addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_selectHideButton];
    }

    return _selectButton;
}
@end
