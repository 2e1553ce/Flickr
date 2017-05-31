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

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation AVGLoadImageOperation

#warning inits
- (instancetype)init {
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    return [self initWithUrlString:nil];
}

- (instancetype)initWithUrlString:(NSString *)urlString {
    self = [super init];
    if (self) {
        self.urlString = urlString;
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
        
        self.semaphore = dispatch_semaphore_create(0);
        
        self.sessionDataTask = [self.session dataTaskWithURL:photoUrl];
        [_sessionDataTask resume];
        
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    }
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
    
    if (self.isCancelled) {
        _downloadedImage = nil;
        NSLog(@"Operation CANCELLLLLLEEEEEEEDDDDD");
        _downloadProgress = 0.f;
        [_sessionDataTask cancel];
        dispatch_semaphore_signal(self.semaphore);
    }
    
    if (_downloadProgress == 1.0) {
        _downloadedImage = [UIImage imageWithData:_dataToDownload];
        dispatch_semaphore_signal(_semaphore);
    }
}

@end
