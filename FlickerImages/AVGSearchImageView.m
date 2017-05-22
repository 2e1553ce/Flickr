//
//  AVGSearchImageView.m
//  FlickerImages
//
//  Created by aiuar on 23.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AVGSearchImageView.h"
#import <Masonry.h>

@implementation AVGSearchImageView

- (instancetype)init {
    self = [super init];
    if (self) {
        /*
        self.layer.cornerRadius = 10.f;
        self.layer.masksToBounds = YES;
        self.layer.shouldRasterize = YES;
         */
        
        // Constraints for indicator
        self.activityIndicatorView = [UIActivityIndicatorView new];
        [self addSubview:self.activityIndicatorView];
        self.activityIndicatorView.color = UIColor.grayColor;
        
        self.progressView = [UIProgressView new];
        [self addSubview:self.progressView];
        _progressView.progress = 0.f;
        
        [self.activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@20);
            make.height.equalTo(@20);
            make.centerY.equalTo(@(self.center.y));
            make.centerX.equalTo(@(self.center.x));
        }];
        
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self);
            make.height.equalTo(@3);
            make.bottom.equalTo(self).with.offset(-5);
            make.centerX.equalTo(@(self.center.x));
        }];
    }
    return self;
}

@end
