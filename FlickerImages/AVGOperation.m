//
//  AVGOperation.m
//  FlickerImages
//
//  Created by iOS-School-1 on 20.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AVGOperation.h"
@import UIKit;
#import "AVGFlickrService.h"

@interface AVGOperation ()

@property (nonatomic, strong) AVGFlickrService *flickrService;

@end

@implementation AVGOperation

- (instancetype)init {
    self = [super init];
    if (self) {
        self.flickrService = [AVGFlickrService new];
    }
    return self;
}

- (void)main {
    
    [self.flickrService downloadImageFromUrl:_imageUrlString withCompletionHandler:^(UIImage *image, NSError *error) {
        self.downloadedImage = image;
        self.downloadBlock(image);
    }];
}

- (void)setUrlPathFromImageInformation:(AVGImageInformation *)info {
    self.imageUrlString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@.jpg",
                                info.farm,
                                info.serverID,
                                info.imageID,
                                info.secretID];
}

@end
