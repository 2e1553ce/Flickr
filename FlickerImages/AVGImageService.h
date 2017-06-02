//
//  AVGImageService.h
//  FlickerImages
//
//  Created by aiuar on 26.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

@import Foundation;
#import "AVGLoadImageOperation.h"
#import "AVGFlickrCell.h"

typedef NS_ENUM(NSInteger, AVGImageState) {
    AVGImageStateNormal = 0,
    AVGImageStateBinarized
};

@interface AVGImageService : NSObject <AVGFlickrCellImageServiceDelegate>

@property (nonatomic, assign) AVGImageState imageState;

- (AVGImageProgressState)imageProgressState;

- (void)resume;
- (void)pause;
- (void)cancel;

@end
