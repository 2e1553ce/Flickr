//
//  AVGParseUrlOperation.m
//  FlickerImages
//
//  Created by aiuar on 26.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AVGParseUrlOperation.h"
#import "AVGOperationsContainer.h"
#import "AVGImageInformation.h"

@implementation AVGParseUrlOperation

#pragma mark - Parse urls

- (void)main {
    
    if (_container.dataFromFlickr) {
        
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:_container.dataFromFlickr
                                                             options:0
                                                               error:&error];
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
        _container.imagesUrl = images;
    }
}

@end
