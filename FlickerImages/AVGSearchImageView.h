//
//  AVGSearchImageView.h
//  FlickerImages
//
//  Created by aiuar on 23.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AVGThumbnailState) {
    AVGThumbnailStateNormal = 0,
    AVGThumbnailStateBinarized
};

@interface AVGSearchImageView : UIImageView

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) AVGThumbnailState thumbnailState;

@end
