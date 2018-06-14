//
//  albumCell.m
//  wkWebview
//
//  Created by 王炜光 on 2018/6/8.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import "AlbumCell.h"

@implementation AlbumCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.backgroundColor = [UIColor blueColor];
        _imageView.layer.masksToBounds = true;
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void)clickedBtn:(UIButton *)sender {

    if (_selectedBlock) {
        _selectedBlock(_assetModel.selected);
    }
}

- (void)setAssetModel:(MediaAssetModel *)assetModel {
    if (assetModel) {
        _assetModel = assetModel;
        self.selectButton.selected = _assetModel.selected;
        self.imageView.image = _assetModel.imageThumbnail;

    }else{
        _assetModel = assetModel;
        self.selectButton.selected = NO;
        self.imageView.image = [UIImage imageNamed:@"message_oeuvre_btn_normal"];
    }
}


- (UIButton *)selectButton {
    if (!_selectButton) {
        CGFloat selectedBtnHW = 24;
        _selectButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - selectedBtnHW , 0, selectedBtnHW, selectedBtnHW)];
        [self.contentView addSubview:_selectButton];
        [_selectButton setImage:[[DrawingSingle shareDrawingSingle] getCircularSize:CGSizeMake(24, 24) color:[UIColor whiteColor] insideColor:[UIColor clearColor] solid:NO] forState:UIControlStateNormal];
        [_selectButton setImage:[[DrawingSingle shareDrawingSingle] getCircularSize:CGSizeMake(24, 24) color:[UIColor greenColor] insideColor:[UIColor whiteColor] solid:YES] forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
        _selectButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    }
    return _selectButton;
}

- (void)setAlbumTitleStr:(NSString *)albumTitleStr{
    _albumTitleStr = albumTitleStr;
    self.albumTitleLabel.text = _albumTitleStr;
}

- (UILabel *)albumTitleLabel{
    if (!_albumTitleLabel) {
        _albumTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.width, self.frame.size.width, 20)];
        _albumTitleLabel.textAlignment = NSTextAlignmentCenter;
        _albumTitleLabel.font = [UIFont systemFontOfSize:14];
        _albumTitleLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_albumTitleLabel];
    }
    return _albumTitleLabel;
}


@end
