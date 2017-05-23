//
//  AVGFlickrService.m
//  FlickerImages
//
//  Created by aiuar on 22.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AVGFlickrService.h"
#import "AVGImageInformation.h"
#import "AVGServerManager.h"
#import <UIKit/UIKit.h>

typedef void(^downloadCompletedBlock)(UIImage *image, NSError *error);

@interface AVGFlickrService () <AVGServerManager, NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

@property (nonatomic, retain) NSMutableData *dataToDownload;
@property (nonatomic) float downloadSize;
@property (nonatomic) float downloadProgress;

@property (nonatomic, copy) downloadCompletedBlock downloadBlock;

@end

@implementation AVGFlickrService

- (instancetype)init {
    self = [super init];
    
    if (self) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        //self.session = [NSURLSession sessionWithConfiguration:sessionConfig];
        self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    return self;
}

- (void)loadImagesInformationWithName:(NSString *)text withCompletionHandler:(void(^)(NSArray *imagesInfo, NSError *error))completion {
    
    if (self.sessionDataTask) {
        [self.sessionDataTask cancel];
    }
    
    NSString *urlBaseString = @"https://api.flickr.com/services/rest/?method=flickr.photos.search&license=1,2,4,7&has_geo=1&extras=original_format,description,date_taken,geo,date_upload,owner_name,place_url,tags&format=json&api_key=c55f5a419863413f77af53764f86bd66&nojsoncallback=1&";
    NSString *urlParametersString = [NSString stringWithFormat:@"text=%@", text];
    NSString *query = [NSString stringWithFormat:@"%@%@", urlBaseString, urlParametersString];
    NSURL *url = [NSURL URLWithString:[query stringByAddingPercentEncodingWithAllowedCharacters:
                                       [NSCharacterSet URLFragmentAllowedCharacterSet]]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    self.sessionDataTask = [self.session dataTaskWithRequest:request
                                           completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                               
                                               if (data) {
                                                   NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                   dict = dict[@"photos"];
                                                   dict = dict[@"photo"];
                                                   
                                                   NSMutableArray *images = [NSMutableArray new];
                                                   for (id object in dict) {
                                                       AVGImageInformation *image = [AVGImageInformation new];
                                                       image.farm = object[@"farm"];
                                                       image.secretID = object[@"secret"];
                                                       image.serverID = object[@"server"];
                                                       image.imageID = object[@"id"];
                                                       
                                                       [images addObject:image];
                                                   }
                                                   
                                                   if (completion) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           completion(images, error);
                                                       });
                                                   }
                                               } else {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       completion(nil, error);
                                                   });
                                                   
                                                   return;
                                               }
                                           }];
    [self.sessionDataTask resume];
}

#pragma mark - NSOperation image downloading

- (void)downloadImageFromUrl:(NSString *)url withCompletionHandler:(void(^)(UIImage *image, NSError *error))completion {

    NSURL *photoUrl = [NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:
                                       [NSCharacterSet URLFragmentAllowedCharacterSet]]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:photoUrl];
    [request setHTTPMethod:@"GET"];
    
    /*
    [[self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (completion) {
                completion(image, error);
            }
        }
        
    }] resume];
     */
    self.downloadBlock = completion;
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL: photoUrl];
    [dataTask resume];
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
    if (self.downloadProgress == 1.0) {
        UIImage *image = [UIImage imageWithData:_dataToDownload];
        self.downloadBlock(image, nil);
    }
}

@end
