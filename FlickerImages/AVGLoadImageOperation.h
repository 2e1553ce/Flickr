//
//  AVGLoadImageOperation.h
//  FlickerImages
//
//  Created by aiuar on 24.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;
@class AVGImageInformation;

typedef void (^downloadProgressBlock)(float progress);

typedef NS_ENUM(NSInteger, AVGDownloadOperationState) {
    AVGDownloadOperationStateNew = 0,
    AVGDownloadOperationStateRunning,
    AVGDownloadOperationStatePaused
};

@interface AVGLoadImageOperation : NSOperation

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, strong) UIImage *downloadedImage;
@property (nonatomic, assign) AVGDownloadOperationState state;
@property (nonatomic, copy) downloadProgressBlock downloadProgressBlock;

- (instancetype)init;
- (instancetype)initWithUrlString:(NSString *)urlString NS_DESIGNATED_INITIALIZER;

@end
