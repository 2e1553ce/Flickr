//
//  AVGOperation.m
//  FlickerImages
//
//  Created by iOS-School-1 on 20.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AVGOperation.h"
@

@implementation AVGOperation

- (void)main {
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: _imageUrlString]];
    UIImage *image = [UIImage imageWithData: imageData];
}

@end
