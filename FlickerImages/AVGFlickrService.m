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
                                                       image.url = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@.jpg",
                                                                    object[@"farm"],
                                                                    object[@"server"],
                                                                    object[@"id"],
                                                                    object[@"secret"]];
                                                       
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

@end
