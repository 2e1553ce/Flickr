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

@property (nonatomic, copy) NSString *urlString;

@end

@implementation AVGLoadImageOperation

- (instancetype)initWithUrlString:(NSString *)urlString {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        self.urlString = urlString;
        self.state = AVGDownloadOperationStateNew;
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
        [self.sessionDataTask resume];
        
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    }
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    completionHandler(NSURLSessionResponseAllow);
    
    self.downloadProgress = 0.0f;
    self.downloadSize = [response expectedContentLength];
    self.dataToDownload = [[NSMutableData alloc]init];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    [self.dataToDownload appendData:data];
    self.downloadProgress = [self.dataToDownload length ] / self.downloadSize;
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
