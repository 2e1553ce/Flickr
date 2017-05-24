//
//  AVGLoadImageOperation.h
//  FlickerImages
//
//  Created by aiuar on 24.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

typedef void (^downloadProgressBlock)(float progress);

#import <Foundation/Foundation.h>
@class UIImage;
@class AVGImageInformation;

@interface AVGLoadImageOperation : NSOperation

@property (nonatomic, strong) AVGImageInformation *imageInfo;
@property (nonatomic, strong) UIImage *downloadedImage;
@property (nonatomic, copy) downloadProgressBlock downloadProgressBlock;

- (instancetype)initWithImageInfromation:(AVGImageInformation *)imageInfo;

@end
