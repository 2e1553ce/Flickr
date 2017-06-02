//
//  AVGFlickrCell.h
//  FlickerImages
//
//  Created by iOS-School-1 on 20.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AVGSearchImageView.h"

@class UIImage, AVGFlickrCell;

@protocol AVGFlickrCellDelegate <NSObject>

@required
- (void)filterImageForCell:(AVGFlickrCell *)cell;

@end

extern NSString *const flickrCellIdentifier;

@interface AVGFlickrCell : UITableViewCell

@property (nonatomic, strong) AVGSearchImageView *searchedImageView;
@property (nonatomic, strong) UIButton *filterButton;
@property (nonatomic, weak) id <AVGFlickrCellDelegate> delegate;

+ (CGFloat)heightForCell;

@end
