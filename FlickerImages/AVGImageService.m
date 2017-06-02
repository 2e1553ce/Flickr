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

@interface AVGImageService () <AVGFlickrCellImageServiceDelegate>

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) AVGLoadImageOperation *loadOperation;
@property (nonatomic, strong) AVGBinaryImageOperation *binaryOperation;

@property (nonatomic, strong) UIImage *downloadedImage;
@property (nonatomic, strong) UIImage *binarizedImage;

@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, copy) NSString *urlString;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation AVGImageService

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.semaphore = dispatch_semaphore_create(0);
        self.imageState = AVGImageStateNormal;
        
        self.queue = [NSOperationQueue new];
        self.loadOperation = [AVGLoadImageOperation new];
        self.binaryOperation = [AVGBinaryImageOperation new];
        [_binaryOperation addDependency:_loadOperation];
    }
    
    return  self;
}

- (AVGImageProgressState)imageProgressState {
    return _loadOperation.imageProgressState;
}

- (void)resume {
    [_loadOperation resumeDownload];
}

- (void)pause {
    [_loadOperation pauseDownload];
}

- (void)cancel {
    [_loadOperation cancelDownload];
}

#pragma mark - AVGFlickrCellImageServiceDelegate

- (void)loadImageFromUrlString:(NSString *)urlString
                      andCache:(NSCache *)cache
                       forCell:(AVGFlickrCell *)cell {
    
    _cache = cache;
    _urlString = urlString;
    
    [cell imageDownloadStarted];
    
    _loadOperation.urlString = urlString;
    if (_loadOperation.imageProgressState == AVGImageProgressStateNew) {
        [_queue addOperation:_loadOperation];
        _loadOperation.imageProgressState = AVGImageProgressStateDownloading;
    } else if (_loadOperation.imageProgressState == AVGImageProgressStatePaused) {
        [_loadOperation resumeDownload];
        _loadOperation.imageProgressState = AVGImageProgressStateDownloading;
    }
    
    _loadOperation.downloadProgressBlock = ^(float progress) {
        [cell updateImageDownloadProgress:progress];
    };

    __weak typeof(self) weakSelf = self;
    _loadOperation.completionBlock = ^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            
            strongSelf.downloadedImage = strongSelf.loadOperation.downloadedImage;
            if (strongSelf.downloadedImage) {
                [strongSelf.cache setObject:strongSelf.downloadedImage forKey:urlString];
            }
            [cell imageDownloadEndedWithImage:strongSelf.downloadedImage];
        }
    };
}

- (void)didClickFilterButtonAtCell:(AVGFlickrCell *)cell {
    
#warning Create container
    _binaryOperation.filteredImage = _loadOperation.downloadedImage;
    [_queue addOperation:_binaryOperation];
    
    __weak typeof(self) weakSelf = self;
    _binaryOperation.completionBlock = ^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            
            strongSelf.binarizedImage = strongSelf.binaryOperation.filteredImage;
            if (strongSelf.binarizedImage) {
                [strongSelf.cache setObject:strongSelf.binarizedImage forKey:strongSelf.urlString];
            }
            
            _imageState = AVGImageStateBinarized;
            [cell imageBinarizeEndedWithImage:strongSelf.binarizedImage];
        }

    };
}

@end
