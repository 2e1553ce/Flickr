//
//  AVGLoadImageOperation.m
//  FlickerImages
//
//  Created by aiuar on 24.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

@import UIKit;
#import "AVGLoadImageOperation.h"

@interface AVGLoadImageOperation () <NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

@property (nonatomic, retain) NSMutableData *dataToDownload;
@property (nonatomic) float downloadSize;
@property (nonatomic) float downloadProgress;

@property (nonatomic, strong) dispatch_semaphore_t dataTaskSemaphore;
@property (nonatomic, strong) dispatch_semaphore_t progressSemaphore;
@property (nonatomic, assign) BOOL isPaused;

@end

@implementation AVGLoadImageOperation

#warning inits
- (instancetype)init {
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.imageProgressState = AVGImageProgressStateNew;
    
    return [self initWithUrlString:nil];
}

- (instancetype)initWithUrlString:(NSString *)urlString {
    self = [super init];
    if (self) {
        self.urlString = urlString;
        _isPaused = NO;
    }
    return self;
}

- (void)main {
    
    if (_urlString) {
        
        NSURL *photoUrl = [NSURL URLWithString:[_urlString stringByAddingPercentEncodingWithAllowedCharacters:
                                                [NSCharacterSet URLFragmentAllowedCharacterSet]]];
        
        NSMutableURLRequest *request = [NSMutableURLRequest new];
        [request setURL:photoUrl];
        [request setHTTPMethod:@"GET"];
        
        self.dataTaskSemaphore = dispatch_semaphore_create(0);
        self.progressSemaphore = dispatch_semaphore_create(0);
        
        self.sessionDataTask = [self.session dataTaskWithURL:photoUrl];
        [_sessionDataTask resume];
        
        dispatch_semaphore_wait(_dataTaskSemaphore, DISPATCH_TIME_FOREVER);
    }
}

- (void)resumeDownload {
    _imageProgressState = AVGImageProgressStateDownloading;
    NSLog(@"DOWNLOADING");
    //dispatch_semaphore_signal(_progressSemaphore);
    [_sessionDataTask resume];
}

- (void)pauseDownload {
    /*
    if ([self isExecuting]) {
        _imageProgressState = AVGImageProgressStatePaused;
        NSLog(@"PAUSED");
        //_isPaused = YES;
    }*/
    _imageProgressState = AVGImageProgressStatePaused;
    [_sessionDataTask suspend];
}

- (void)cancelDownload {
    [self cancel];
    _imageProgressState = AVGImageProgressStateCancelled;
    NSLog(@"CANCELED");
    dispatch_semaphore_signal(_progressSemaphore);
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    completionHandler(NSURLSessionResponseAllow);
    
    _downloadProgress = 0.0f;
    _downloadSize = [response expectedContentLength];
    self.dataToDownload = [NSMutableData new];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    [_dataToDownload appendData:data];
    _downloadProgress = [_dataToDownload length ] / _downloadSize;
    NSLog(@"%f", self.downloadProgress);

    if (_downloadProgressBlock) {
        _downloadProgressBlock(_downloadProgress);
    }
    
    if (_isPaused) {
         dispatch_semaphore_wait(_progressSemaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"Operation PAAUUUUUSSSEEEDDD");
    }
    
    if (self.isCancelled) {
        _downloadedImage = nil;
        NSLog(@"Operation CANCELLLLLLEEEEEEEDDDDD");
        _downloadProgress = 0.f;
        [_sessionDataTask cancel];
        dispatch_semaphore_signal(_dataTaskSemaphore);
    }
    
    if (_downloadProgress == 1.0) {
        _downloadedImage = [UIImage imageWithData:_dataToDownload];
        dispatch_semaphore_signal(_dataTaskSemaphore);
    }
}

@end
