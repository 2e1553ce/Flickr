//
//  AVGServerManager.h
//  FlickerImages
//
//  Created by aiuar on 22.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

@protocol AVGServerManager <NSObject>

@required
- (void)loadImagesInformationWithName:(NSString *)text
                withCompletionHandler:(void(^)(NSArray *imagesInfo, NSError *error))completion;

@end

