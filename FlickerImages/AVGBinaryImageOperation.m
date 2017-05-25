//
//  AVGBinaryImageOperation.m
//  FlickerImages
//
//  Created by aiuar on 24.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AVGBinaryImageOperation.h"
#import <UIKit/UIKit.h>

@implementation AVGBinaryImageOperation

- (instancetype)init {
    self = [super init];
    if (self) {
        self.state = AVGOperationStateNormal;
    }
    return self;
}

- (void)main {
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, self.filteredImage.size.width, self.filteredImage.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, self.filteredImage.size.width, self.filteredImage.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [self.filteredImage CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    self.filteredImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    self.state = AVGOperationStateBinarized;
    // Return the new grayscale image
}

@end