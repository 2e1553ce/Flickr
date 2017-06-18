//
//  AVGBinaryImageOperation.m
//  FlickerImages
//
//  Created by aiuar on 24.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AVGBinaryImageOperation.h"
#import "AVGOperationsContainer.h"
@import UIKit;

@implementation AVGBinaryImageOperation

- (void)main {
    if (self.operationDataContainer) {
        // stackoverflow was here
        // Create image rectangle with current image width/height
        CGRect imageRect = CGRectMake(0, 0, self.operationDataContainer.image.size.width, self.operationDataContainer.image.size.height);
        
        // Grayscale color space
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        
        // Create bitmap content with current image size and grayscale colorspace
        CGContextRef context = CGBitmapContextCreate(nil, self.operationDataContainer.image.size.width, self.operationDataContainer.image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
        
        // Draw image into current context, with specified rectangle
        // using previously defined context (with grayscale colorspace)
        CGContextDrawImage(context, imageRect, [self.operationDataContainer.image CGImage]);
        
        // Create bitmap image info from pixel data in current context
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        
        // Create a new UIImage object
        self.operationDataContainer.image = [UIImage imageWithCGImage:imageRef];
        
        // Release colorspace, context and bitmap information
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);
        CFRelease(imageRef); // could be leak
    }
}

@end
