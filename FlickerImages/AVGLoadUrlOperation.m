//
//  AVGLoadUrlOperation.m
//  FlickerImages
//
//  Created by aiuar on 26.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AVGLoadUrlOperation.h"
#import "AVGOperationsContainer.h"

@interface AVGLoadUrlOperation ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

@end

@implementation AVGLoadUrlOperation

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:sessionConfig];
    }
    return  self;
}

#pragma mark - Load urls

- (void)main {
    
    if (self.sessionDataTask) {
        [self.sessionDataTask cancel];
    }
    
    NSString *urlBaseString = @"https://api.flickr.com/services/rest/?method=flickr.photos.search&license=1,2,4,7&has_geo=1&extras=original_format,description,date_taken,geo,date_upload,owner_name,place_url,tags&format=json&api_key=c55f5a419863413f77af53764f86bd66&nojsoncallback=1&";
    NSString *urlParametersString = [NSString stringWithFormat:@"text=%@&page=%ld&per_page=%ld", _searchText, (long)_page, (long)_perPage];
    NSString *query = [NSString stringWithFormat:@"%@%@", urlBaseString, urlParametersString];
    NSURL *url = [NSURL URLWithString:[query stringByAddingPercentEncodingWithAllowedCharacters:
                                       [NSCharacterSet URLFragmentAllowedCharacterSet]]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    self.sessionDataTask = [self.session dataTaskWithRequest:request
                                           completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

                                               _container.dataFromFlickr = data;
                                               dispatch_semaphore_signal(semaphore);
                                           }];
    [self.sessionDataTask resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.session finishTasksAndInvalidate];
}

@end
