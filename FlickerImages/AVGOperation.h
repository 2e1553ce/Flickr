//
//  AVGOperation.h
//  FlickerImages
//
//  Created by iOS-School-1 on 20.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AVGImageInformation.h"

@interface AVGOperation : NSOperation

@property (nonatomic, copy) NSString *imageUrlString;
@property (nonatomic, strong) UIImage *downloadedImage;

- (void)setUrlPathFromImageInformation:(AVGImageInformation *)info;

@end
