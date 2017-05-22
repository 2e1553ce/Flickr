//
//  AVGOperation.m
//  FlickerImages
//
//  Created by iOS-School-1 on 20.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AVGOperation.h"
@import UIKit;

@interface AVGOperation ()



@end

@implementation AVGOperation

- (void)main {
    
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: _imageUrlString]];
    UIImage *image = [UIImage imageWithData: imageData];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.downloadedImage = image;
    });
}

- (void)setUrlPathFromImageInformation:(AVGImageInformation *)info {
    self.imageUrlString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@.jpg",
                                info.farm,
                                info.serverID,
                                info.imageID,
                                info.secretID];
}

@end
