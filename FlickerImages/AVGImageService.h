//
//  AVGImageService.h
//  FlickerImages
//
//  Created by aiuar on 26.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

@import Foundation;
#import "AVGLoadImageOperation.h"

@class AVGImageService;

typedef NS_ENUM(NSInteger, AVGImageState) {
    AVGImageStateNormal = 0,
    AVGImageStateBinarized
};

@protocol AVGImageServiceDelegate <NSObject>

@required
- (void)serviceStartedImageDownload:(AVGImageService *)service forRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)service:(AVGImageService *)service updateImageDownloadProgress:(float)progress forRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)service:(AVGImageService *)service downloadedImage:(UIImage *)image forRowAtIndexPath:(NSIndexPath*)indexPath;

@optional
- (void)service:(AVGImageService *)service binarizedImage:(UIImage *)image forRowAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface AVGImageService : NSObject

@property (nonatomic, assign) AVGImageState imageState;
@property (nonatomic, weak) id<AVGImageServiceDelegate> delegate;

- (void)loadImageFromUrlString:(NSString *)urlString
                      andCache:(NSCache *)cache
             forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)filterImageforRowAtIndexPath:(NSIndexPath *)indexPath;

- (AVGImageProgressState)imageProgressState;

- (void)resume;
- (void)pause;
- (void)cancel;

@end
