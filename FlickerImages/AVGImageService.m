//
//  AVGImageService.m
//  FlickerImages
//
//  Created by aiuar on 26.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AVGImageService.h"
#import "AVGBinaryImageOperation.h"
#import "AVGFlickrCell.h"
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
        self.imageState = AVGImageStateNormal;
        
        self.queue = [NSOperationQueue new];
        self.loadOperation = [AVGLoadImageOperation new];
        self.binaryOperation = [AVGBinaryImageOperation new];
        self.operationDataContainer = [AVGOperationsContainer new];
        
        _loadOperation.operationDataContainer = _operationDataContainer;
        
        _binaryOperation.operationDataContainer = _operationDataContainer;
        [_binaryOperation addDependency:_loadOperation];
        
    }
    
    return  self;
}

#pragma mark - Progess state for image load

- (AVGImageProgressState)imageProgressState {
    return _loadOperation.imageProgressState;
}

#pragma mark - Resume, pause , cancel image load

- (void)resume {
    if (_loadOperation.imageProgressState == AVGImageProgressStateCancelled) {
        [_queue cancelAllOperations];
        [_loadOperation cancel];
        self.loadOperation = [AVGLoadImageOperation new];
        [_binaryOperation addDependency:_loadOperation];
        [self loadImageFromUrlString:_urlString andCache:_cache forRowAtIndexPath:_indexPath];
        NSLog(@"Downloading AGAIIIIIIN");
    }
}

- (void)pause {
    [_loadOperation pauseDownload];
}

- (void)cancel {
    [_loadOperation cancelDownload];
}

#pragma mark - Operations on image

- (void)loadImageFromUrlString:(NSString *)urlString
                      andCache:(NSCache *)cache
                       forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _cache = cache;
    _urlString = urlString;
    _indexPath = indexPath;
    
    // Notificate controller for image load, start actinityIndicator and progressView
    [_delegate serviceStartedImageDownload:self forRowAtIndexPath:indexPath];
    
    _loadOperation.urlString = urlString;
    if (_loadOperation.imageProgressState == AVGImageProgressStateNew) {
        [_queue addOperation:_loadOperation];
        _loadOperation.imageProgressState = AVGImageProgressStateDownloading;
        
    } else if (_loadOperation.imageProgressState == AVGImageProgressStatePaused) {
        [_loadOperation resumeDownload];
        _loadOperation.imageProgressState = AVGImageProgressStateDownloading;
    }
    
    // Update progressView
    __weak typeof(self) weakSelf = self;
    _loadOperation.downloadProgressBlock = ^(float progress) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
             [strongSelf.delegate service:strongSelf updateImageDownloadProgress:progress forRowAtIndexPath:indexPath];
        }
    };

    // Notificate controller for stop activityIndicator and progressView
    _loadOperation.completionBlock = ^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            
            //strongSelf.downloadedImage = strongSelf.loadOperation.downloadedImage;
            if (strongSelf.operationDataContainer.image) {
                [strongSelf.cache setObject:strongSelf.operationDataContainer.image forKey:urlString];
            }
            [strongSelf.delegate service:strongSelf downloadedImage:strongSelf.operationDataContainer.image forRowAtIndexPath:indexPath];
        }
    };
}

- (void)filterImageforRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_binaryOperation.isFinished) {
        return;
    }
    
    NSArray *opertions = _queue.operations;
    if (![opertions containsObject:_binaryOperation]) {
        [_queue addOperation:_binaryOperation];
        
        __weak typeof(self) weakSelf = self;
        _binaryOperation.completionBlock = ^{
            __strong typeof(self) strongSelf = weakSelf;
            if (strongSelf) {
                
                //strongSelf.binarizedImage = strongSelf.binaryOperation.filteredImage;
                if (strongSelf.operationDataContainer.image) {
                    [strongSelf.cache setObject:strongSelf.operationDataContainer.image forKey:strongSelf.urlString];
                }
                
                _imageState = AVGImageStateBinarized;
                [strongSelf.delegate service:strongSelf binarizedImage:strongSelf.operationDataContainer.image forRowAtIndexPath:indexPath];
                
            }
        };
    }
}

@end
