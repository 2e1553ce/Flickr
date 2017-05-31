//
//  AVGImageService.h
//  FlickerImages
//
//  Created by aiuar on 26.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

@import Foundation;
#import "AVGFlickrCell.h"

@protocol AVGFlickrCellImageServiceDelegate;

@interface AVGImageService : NSObject <AVGFlickrCellImageServiceDelegate>

- (void)cancelDownload;

@end
