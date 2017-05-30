//
//  AVGImageService.m
//  FlickerImages
//
//  Created by aiuar on 26.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AVGImageService.h"
#import "AVGLoadImageOperation.h"
#import "AVGBinaryImageOperation.h"


#import "AVGFlickrCell.h"

@interface AVGImageService () <AVGFlickrCellImageServiceDelegate>

@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) AVGLoadImageOperation *loadOperation;
@property (strong, nonatomic) AVGBinaryImageOperation *binaryOperation;

@property (strong, nonatomic) UIImage *downloadedImage;
@property (strong, nonatomic) UIImage *binarizedImage;

@property (strong, nonatomic) NSCache *cache;
@property (copy, nonatomic) NSString *urlString;

@end

@implementation AVGImageService

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.queue = [NSOperationQueue new];
        self.loadOperation = [AVGLoadImageOperation new];
        self.binaryOperation = [AVGBinaryImageOperation new];
        [_binaryOperation addDependency:_loadOperation];
    }
    
    return  self;
}

- (void)cancelDownload {
    if ([_loadOperation isExecuting]) {
        [_loadOperation cancel];
        NSLog(@"CANCELED");
    }
}

- (void)loadImageFromUrlString:(NSString *)urlString
                      andCache:(NSCache *)cache
                       forCell:(AVGFlickrCell *)cell {
    
    _cache = cache;
    _urlString = urlString;
    
    [cell imageDownloadStarted];
    
    _loadOperation.urlString = urlString;
    [_queue addOperation:_loadOperation];
    
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
            [cell imageBinarizeEndedWithImage:strongSelf.binarizedImage];
        }

    };
}

@end
