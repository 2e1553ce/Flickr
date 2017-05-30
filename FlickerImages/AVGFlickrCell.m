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
    self.searchedImageView.image = nil;
}

#pragma mark - Constraints

- (void)createSubviewsWithContact {
    
    self.searchedImageView = [AVGSearchImageView new];
    
    self.filterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.filterButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [self.filterButton setTitle:@"Фильтр" forState:UIControlStateNormal];
    [self.filterButton addTarget:self
                          action:@selector(filterButtonAction:)
                forControlEvents:UIControlEventTouchUpInside];
    self.filterButton.enabled = NO;
    self.accessoryView = self.filterButton;
    
    
    [self addSubview:self.searchedImageView];
    [self addSubview:self.filterButton];
    
    // Masonry
    UIView *superview = self;
    
    // Left thumbnail
    [self.searchedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@150);
        make.height.equalTo(@150); // wtf
        make.left.equalTo(superview).with.offset(10);
        make.top.equalTo(superview).with.offset(5);
        make.bottom.equalTo(superview).with.offset(-5);
    }];
    
    // Filter button
    [self.filterButton mas_makeConstraints:^(MASConstraintMaker *make) {
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
            _filterButton.enabled = YES;
            _searchedImageView.image = image;
            [self setNeedsLayout];
            [_searchedImageView.activityIndicatorView stopAnimating];
            _searchedImageView.progressView.hidden = YES;
        }
    });
}

- (void)imageBinarizeEndedWithImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (image) {
    #warning animation not working 
            [UIView animateWithDuration:1.0f animations:^{
                _searchedImageView.thumbnailState = AVGThumbnailStateBinarized;
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
