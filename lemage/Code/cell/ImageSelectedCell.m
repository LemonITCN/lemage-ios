//
//  imageSelectedCell.m
//  wkWebview
//
//  Created by 王炜光 on 2018/6/6.
//  Copyright © 2018年 Ezrea1. All rights reserved.
//

#import "ImageSelectedCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DrawingSingle.h"
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
        if (_assetModel.videoTime) {
            self.timeLabel.text =[self timeFormatted:[[self decimalwithFormat:@"0" floatV:[_assetModel.videoTime floatValue]] intValue]];
            self.videoImageView.image = [[DrawingSingle shareDrawingSingle] getVideoImageSize:_videoImageView.frame.size color:[UIColor whiteColor]];
        }else{
            self.timeLabel.text = nil;
            self.videoImageView.image = nil;
        }
        
        if (_assetModel.imageThumbnail) {
            self.imageView.image = _assetModel.imageThumbnail;
        }
    }
    
}
//格式话小数 四舍五入类型
- (NSString *) decimalwithFormat:(NSString *)format  floatV:(float)floatV{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    [numberFormatter setPositiveFormat:format];
    
    return  [numberFormatter stringFromNumber:[NSNumber numberWithFloat:floatV]];
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
- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width/5*2, self.contentView.frame.size.height-20, self.contentView.frame.size.width/5*3, 14)];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textColor = [UIColor whiteColor];
        
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}
- (UIImageView *)videoImageView{
    if (!_videoImageView) {
        _videoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height-19, self.contentView.frame.size.width/5*2, 12)];
        [self.contentView addSubview:_videoImageView];
    }
    return _videoImageView;
}
- (void)setImgNo:(NSString *)imgNo{
    _imgNo = imgNo;
    if (self.imgNo.length > 0) {
        _selectButton.layer.borderWidth = 0;
        [_selectButton setTitle:self.imgNo forState:UIControlStateNormal];
        [_selectButton setBackgroundColor:_themeColor];
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
