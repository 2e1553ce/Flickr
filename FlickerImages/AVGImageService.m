//
//  AVGImageService.m
//  FlickerImages
//
//  Created by aiuar on 26.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AVGImageService.h"
#import "AVGBinaryImageOperation.h"
#import "AVGOperationsContainer.h"

@interface AVGImageService ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) AVGLoadImageOperation *loadOperation;
@property (nonatomic, strong) AVGBinaryImageOperation *binaryOperation;
@property (nonatomic, strong) AVGOperationsContainer *operationDataContainer;

@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, copy) NSString *urlString;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation AVGImageService

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.semaphore = dispatch_semaphore_create(0);
        self.queue = [NSOperationQueue new];
        self.operationDataContainer = [AVGOperationsContainer new];
    }
    return  self;
}

#pragma mark - Progess state for image load

- (AVGImageProgressState)imageProgressState {
    return self.loadOperation.imageProgressState;
}

#pragma mark - Resume, pause , cancel image load

- (void)resume {
    
}

- (void)pause {
    [self.loadOperation pauseDownload];
}

- (void)cancel {
    [self.loadOperation cancelDownload];
}

#pragma mark - Operations on image

- (void)loadImageFromUrlString:(NSString *)urlString
                      andCache:(NSCache *)cache
                       forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.cache = cache;
    self.urlString = urlString;
    self.indexPath = indexPath;
    
    [self.queue cancelAllOperations];
    
    self.loadOperation = [AVGLoadImageOperation new];
    self.binaryOperation = [AVGBinaryImageOperation new];
    
    self.loadOperation.operationDataContainer = self.operationDataContainer;
    self.binaryOperation.operationDataContainer = self.operationDataContainer;
    [self.binaryOperation addDependency:self.loadOperation];
    
    self.imageState = AVGImageStateNormal;
    self.loadOperation.imageProgressState = AVGImageProgressStateNew;
    self.loadOperation.urlString = urlString;
    [self.queue addOperation:self.loadOperation];
    
    // Notificate controller for image load, start actinityIndicator and progressView
    [self.delegate serviceStartedImageDownload:self forRowAtIndexPath:indexPath];
    
    // Update progressView
    __weak typeof(self) weakSelf = self;
    self.loadOperation.downloadProgressBlock = ^(float progress) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
             [strongSelf.delegate service:strongSelf updateImageDownloadProgress:progress forRowAtIndexPath:indexPath];
        }
    };

    // Notificate controller for stop activityIndicator and progressView
    self.loadOperation.completionBlock = ^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            
            if (strongSelf.operationDataContainer.image) {
                [strongSelf.cache setObject:strongSelf.operationDataContainer.image forKey:urlString];
            }
            [strongSelf.delegate service:strongSelf downloadedImage:strongSelf.operationDataContainer.image forRowAtIndexPath:indexPath];
        }
    };
}

- (void)filterImageforRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.binaryOperation.isFinished) {
        return;
    }
    
    NSArray *opertions = self.queue.operations;
    if (![opertions containsObject:self.binaryOperation]) {
        [self.queue addOperation:self.binaryOperation];
        
        __weak typeof(self) weakSelf = self;
        self.binaryOperation.completionBlock = ^{
            __strong typeof(self) strongSelf = weakSelf;
            if (strongSelf) {
                
                if (strongSelf.operationDataContainer.image) {
                    [strongSelf.cache setObject:strongSelf.operationDataContainer.image forKey:strongSelf.urlString];
                }
                
                strongSelf.imageState = AVGImageStateBinarized;
                [strongSelf.delegate service:strongSelf binarizedImage:strongSelf.operationDataContainer.image forRowAtIndexPath:indexPath];
            }
        };
    }
}

@end
