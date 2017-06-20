//
//  AVGLoadImageOperation.m
//  FlickerImages
//
//  Created by aiuar on 24.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

@import UIKit;
#import "AVGLoadImageOperation.h"
#import "AVGOperationsContainer.h"

@interface AVGLoadImageOperation () <NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

@property (nonatomic, retain) NSMutableData *dataToDownload;
@property (nonatomic) float downloadSize;
@property (nonatomic) float downloadProgress;

@property (nonatomic, strong) dispatch_semaphore_t dataTaskSemaphore;


@end

@implementation AVGLoadImageOperation

#pragma mark - Initialization

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
    }
    return self;
}

#pragma mark - Load image

- (void)main {
    if (self.urlString) {
        
        NSURL *photoUrl = [NSURL URLWithString:[self.urlString stringByAddingPercentEncodingWithAllowedCharacters:
                                                [NSCharacterSet URLFragmentAllowedCharacterSet]]];
        
        NSMutableURLRequest *request = [NSMutableURLRequest new];
        [request setURL:photoUrl];
        [request setHTTPMethod:@"GET"];
        
        self.dataTaskSemaphore = dispatch_semaphore_create(0);
        
        self.sessionDataTask = [self.session dataTaskWithURL:photoUrl];
        [self.sessionDataTask resume];
        self.imageProgressState = AVGImageProgressStateDownloading;
        
        dispatch_semaphore_wait(self.dataTaskSemaphore, DISPATCH_TIME_FOREVER);
        [self.session finishTasksAndInvalidate]; // why did u do that
    }
}

#pragma mark Resume, pause, cancel load operation

- (void)resumeDownload {
    // not using
    self.imageProgressState = AVGImageProgressStateDownloading;
    NSLog(@"DOWNLOADING");
    [self.sessionDataTask resume];
}

- (void)pauseDownload {
    NSLog(@"PAUSED");
    self.imageProgressState = AVGImageProgressStatePaused;
    [self.sessionDataTask cancel]; // :DD
}

- (void)cancelDownload {
    [self cancel];
    [self.sessionDataTask cancel];
    dispatch_semaphore_signal(self.dataTaskSemaphore);
    self.imageProgressState = AVGImageProgressStateCancelled;
    NSLog(@"CANCELED");
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    completionHandler(NSURLSessionResponseAllow);
    
    self.downloadProgress = 0.0f;
    self.downloadSize = [response expectedContentLength];
    self.dataToDownload = [NSMutableData new];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    [self.dataToDownload appendData:data];
    self.downloadProgress = [self.dataToDownload length ] / self.downloadSize;
    //NSLog(@"%f", self.downloadProgress);

    if (self.downloadProgressBlock) {
        self.downloadProgressBlock(self.downloadProgress);
    }
    
    if (self.downloadProgress == 1.0) {
        self.imageProgressState = AVGImageProgressStateDownloaded;
        self.operationDataContainer.image = [UIImage imageWithData:self.dataToDownload];
        dispatch_semaphore_signal(self.dataTaskSemaphore);
        NSLog(@"DOWNLOADED!");
    }
}

@end
