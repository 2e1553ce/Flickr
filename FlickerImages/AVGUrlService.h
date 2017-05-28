//
//  AVGUrlService.h
//  FlickerImages
//
//  Created by aiuar on 26.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AVGImageInformation;

@interface AVGUrlService : NSObject

@property (nonatomic, copy) NSArray <AVGImageInformation *> *imagesUrls;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (void)loadInformationWithText:(NSString *)text;
- (void)parseInformationWithCompletionHandler:(void(^)(NSArray *imageUrls))completion;

@end
