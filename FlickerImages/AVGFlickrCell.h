//
//  AVGFlickrCell.h
//  FlickerImages
//
//  Created by iOS-School-1 on 20.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVGSearchImageView.h"

extern NSString *const flickrCellIdentifier;

@interface AVGFlickrCell : UITableViewCell

@property (nonatomic, strong) AVGSearchImageView *searchedImageView;
@property (nonatomic, strong) UIButton *filterButton;

+ (CGFloat)heightForCell;

@end
