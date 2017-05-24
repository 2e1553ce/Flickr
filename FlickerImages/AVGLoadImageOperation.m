//
//  AVGLoadImageOperation.m
//  FlickerImages
//
//  Created by aiuar on 24.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AVGLoadImageOperation.h"
#import <UIKit/UIKit.h>
#import "AVGImageInformation.h"

@interface AVGLoadImageOperation () <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

@property (nonatomic, retain) NSMutableData *dataToDownload;
@property (nonatomic) float downloadSize;
@property (nonatomic) float downloadProgress;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation AVGLoadImageOperation

- (instancetype)initWithImageInfromation:(AVGImageInformation *)imageInfo {
    self = [super init];
    if (self) {
        self.imageInfo = imageInfo;
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        //self.session = [NSURLSession sessionWithConfiguration:sessionConfig];
        self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}

- (void)main {
    
    if (_imageInfo) {
        
        NSURL *photoUrl = [NSURL URLWithString:[self.imageInfo.url stringByAddingPercentEncodingWithAllowedCharacters:
                                                [NSCharacterSet URLFragmentAllowedCharacterSet]]];
        
        NSMutableURLRequest *request = [NSMutableURLRequest new];
        [request setURL:photoUrl];
        [request setHTTPMethod:@"GET"];
        
        self.semaphore = dispatch_semaphore_create(0);
        /*
        self.sessionDataTask = [self.session dataTaskWithRequest:request
                                               completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                   
                                                   self.downloadedImage = [UIImage imageWithData:data];
                                                   dispatch_semaphore_signal(semaphore);
                                                   NSLog(@"2");
        }];
        */
        self.sessionDataTask = [self.session dataTaskWithURL:photoUrl];
        [self.sessionDataTask resume];
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    }
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
    
    self.downloadProgress = 0.0f;
    _downloadSize=[response expectedContentLength];
    _dataToDownload=[[NSMutableData alloc]init];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [_dataToDownload appendData:data];
    self.downloadProgress = [ _dataToDownload length ]/_downloadSize;
    NSLog(@"%f", self.downloadProgress);
    if (self.downloadProgressBlock) {
        self.downloadProgressBlock(self.downloadProgress);
    }
    if (self.downloadProgress == 1.0) {
        self.downloadedImage = [UIImage imageWithData:_dataToDownload];
        dispatch_semaphore_signal(self.semaphore);
    }
}

@end
