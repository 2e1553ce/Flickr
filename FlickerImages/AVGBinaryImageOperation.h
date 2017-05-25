//
//  AVGBinaryImageOperation.h
//  FlickerImages
//
//  Created by aiuar on 24.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;

typedef NS_ENUM(NSInteger, AVGOperationState) {
    AVGOperationStateNormal = 0,
    AVGOperationStateBinarized
};

@interface AVGBinaryImageOperation : NSBlockOperation

@property (nonatomic, strong) UIImage *filteredImage;
@property (nonatomic, assign) AVGOperationState state;

@end
