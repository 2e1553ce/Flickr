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

@interface AVGImageService ()

@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) AVGLoadImageOperation *loadOperation;
@property (strong, nonatomic) AVGBinaryImageOperation *binaryOperation;

@end

@implementation AVGImageService

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.queue = [NSOperationQueue new];
    }
    
    return  self;
}

- (UIImage *)loadImageFromUrlString:(NSString *)urlString {
    // otsuda v completion blocke vizvat metod delegata celki i obnovit ee
    
    self.loadOperation = [[AVGLoadImageOperation alloc] initWithUrlString:urlString];
    [_queue addOperation:_loadOperation];
    
    //__weak typeof(self) weakSelf = self;
    //__weak typeof(_loadOperation) weakLoadOperation = _loadOperation;
    //__weak typeof(_delegate) weakDelegate = _delegate;
    _loadOperation.completionBlock = ^{
        //__strong typeof(self) strongSelf = weakSelf;
        //__strong typeof(_loadOperation) strongLoadOperation = weakLoadOperation;
        //__strong typeof(_delegate) strongDelegate = weakDelegate;
        //if (strongSelf) {
        NSLog(@"");
            [_delegate service:self dowloadedImage:_loadOperation.downloadedImage];
        //}
    };
    return nil;
}

- (UIImage *)binaryImage:(UIImage *)image {
    return nil;
}

@end
