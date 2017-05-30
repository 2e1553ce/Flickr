//
//  AVGFlickrCell.h
//  FlickerImages
//
//  Created by iOS-School-1 on 20.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVGSearchImageView.h"
#import "AVGImageService.h"

#warning code style? forward declaration of protocols
@protocol AVGFlickrCellImageServiceDelegate;

extern NSString *const flickrCellIdentifier;

@interface AVGFlickrCell : UITableViewCell

@property (nonatomic, strong) AVGSearchImageView *searchedImageView;
@property (nonatomic, strong) UIButton *filterButton;
@property (nonatomic, weak) id <AVGFlickrCellImageServiceDelegate> imageServiceDelegate;

- (void)updateImageDownloadProgress:(float)progress;
- (void)imageDownloadStarted;
- (void)imageDownloadEndedWithImage:(UIImage *)image;
- (void)imageBinarizeEndedWithImage:(UIImage *)image;

+ (CGFloat)heightForCell;

@end

@protocol AVGFlickrCellImageServiceDelegate

@required
- (void)loadImageFromUrlString:(NSString *)urlString
                      andCache:(NSCache *)cache
                       forCell:(AVGFlickrCell *)cell;

- (void)didClickFilterButtonAtCell:(AVGFlickrCell *)cell;

@end
