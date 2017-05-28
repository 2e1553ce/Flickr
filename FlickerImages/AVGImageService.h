//
//  AVGImageService.h
//  FlickerImages
//
//  Created by aiuar on 26.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;
@class AVGImageService;

@protocol AVGServiceDelegate <NSObject>

@required
- (void)service:(AVGImageService *)service dowloadedImage:(UIImage *)image;
- (void)service:(AVGImageService *)service binarizedImage:(UIImage *)image;

@end

@interface AVGImageService : NSObject

@property (nonatomic, weak) id <AVGServiceDelegate> delegate;

- (UIImage *)loadImageFromUrlString:(NSString *)urlString;

@end
