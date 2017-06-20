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

#pragma mark - Initialization

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createSubviews];
    }
    return self;
}

#pragma mark - Reusing

- (void)prepareForReuse {
    self.searchedImageView.image = nil;
}

#pragma mark - Constraints

- (void)createSubviews {
    
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
        make.centerY.equalTo(@(superview.center.y)).with.offset(0); // без 0 почемуто вниз уходит ?? bug
    }];
}

#pragma mark - Cell Height

+ (CGFloat)heightForCell {
    return 160;
}

#pragma mark - Actions

- (void)filterButtonAction:(UIButton *)sender {
    [self.delegate filterImageForCell:self];
}

@end
