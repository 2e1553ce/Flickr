//
//  AVGLoadImageOperation.h
//  FlickerImages
//
//  Created by aiuar on 24.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

@import  Foundation;

@class UIImage, AVGOperationsContainer;

typedef NS_ENUM(NSInteger, AVGImageProgressState) {
    AVGImageProgressStateNew = 0,
    AVGImageProgressStateDownloading,
    AVGImageProgressStatePaused,
    AVGImageProgressStateDownloaded,
    AVGImageProgressStateCancelled
};

typedef void (^downloadProgressBlock)(float progress);

@interface AVGLoadImageOperation : NSOperation

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) downloadProgressBlock downloadProgressBlock;
@property (nonatomic, assign) AVGImageProgressState imageProgressState;
@property (nonatomic, strong) AVGOperationsContainer *operationDataContainer;

- (void)resumeDownload;
- (void)pauseDownload;
- (void)cancelDownload;

- (instancetype)init;
- (instancetype)initWithUrlString:(NSString *)urlString NS_DESIGNATED_INITIALIZER;

@end
