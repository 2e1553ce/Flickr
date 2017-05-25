//
//  AVGFlickrService.h
//  FlickerImages
//
//  Created by aiuar on 22.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;

@interface AVGFlickrService : NSObject

- (void)loadImagesInformationWithName:(NSString *)text
                withCompletionHandler:(void(^)(NSArray *imagesInfo, NSError *error))completion;

@end
