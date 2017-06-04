//
//  AVGUrlService.h
//  FlickerImages
//
//  Created by aiuar on 26.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

@import Foundation;

@class AVGImageInformation;

@interface AVGUrlService : NSObject

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, copy) NSArray <AVGImageInformation *> *imagesUrls;

- (void)loadInformationWithText:(NSString *)text
                        forPage:(NSInteger)page;
- (void)parseInformationWithCompletionHandler:(void(^)(NSArray *imageUrls))completion;

@end
