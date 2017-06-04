//
//  AVGBinaryImageOperation.h
//  FlickerImages
//
//  Created by aiuar on 24.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

@import Foundation;

@class UIImage, AVGOperationsContainer;

@interface AVGBinaryImageOperation : NSBlockOperation

@property (nonatomic, strong) AVGOperationsContainer *operationDataContainer;

@end
