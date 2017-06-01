//
//  AVGFlickrCell.m
//  FlickerImages
//
//  Created by iOS-School-1 on 20.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AVGFlickrCell.h"
#import "AVGImageService.h"
#import "Masonry.h"

NSString *const flickrCellIdentifier = @"flickrCellIdentifier";

@implementation AVGFlickrCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createSubviewsWithContact];
    }
    
    return self;
}

- (void)prepareForReuse {
    _searchedImageView.image = nil;
}

#pragma mark - Constraints

- (void)createSubviewsWithContact {
    
    self.searchedImageView = [AVGSearchImageView new];
    
    self.filterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _filterButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [_filterButton setTitle:@"Фильтр" forState:UIControlStateNormal];
    [_filterButton addTarget:self
                          action:@selector(filterButtonAction:)
                forControlEvents:UIControlEventTouchUpInside];
    _filterButton.enabled = NO;
    self.accessoryView = _filterButton;
    
    [self addSubview:_searchedImageView];
    [self addSubview:_filterButton];
    
    // Masonry
    UIView *superview = self;
    
    // Left thumbnail
    [_searchedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@150);
        make.height.equalTo(@150); // wtf
        make.left.equalTo(superview).with.offset(10);
        make.top.equalTo(superview).with.offset(5);
        make.bottom.equalTo(superview).with.offset(-5);
    }];
    
    // Filter button
    [_filterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@80);
        make.height.equalTo(@20);
        make.right.equalTo(superview).with.offset(-10);
        make.centerY.equalTo(@(superview.center.y)).with.offset(0); // без 0 почемуто вниз уходит ??
    }];
}

#pragma mark - Cell Height

+ (CGFloat)heightForCell {
    return 160;
}

#pragma mark - Image operations

- (void)updateImageDownloadProgress:(float)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        _searchedImageView.progressView.progress = progress;
    });
}

- (void)imageDownloadStarted {
    _searchedImageView.progressView.hidden = NO;
    _searchedImageView.progressView.progress = 0.f;
    [_searchedImageView.activityIndicatorView startAnimating];
}

- (void)imageDownloadEndedWithImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (image) {
            //_filterButton.enabled = YES;
            _searchedImageView.image = image;
            [_searchedImageView.activityIndicatorView stopAnimating];
            _searchedImageView.progressView.hidden = YES;
            [self setNeedsLayout];
        }
    });
}

- (void)imageBinarizeEndedWithImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (image) {
    #warning animation not working 
            [UIView animateWithDuration:1.0f animations:^{
                _filterButton.enabled = NO;
                _searchedImageView.image = image;
                [self setNeedsLayout];
            }];
        }
    });
}

#pragma mark - Actions

- (void)filterButtonAction:(UIButton *)sender {
    [_imageServiceDelegate didClickFilterButtonAtCell:self];
}

@end
