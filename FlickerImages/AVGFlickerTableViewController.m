//
//  AVGFlickerTableViewController.m
//  FlickerImages
//
//  Created by iOS-School-1 on 20.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AVGFlickerTableViewController.h"
#import "AVGFlickrCell.h"
#import "AVGImageInformation.h"
#import "AVGFlickrService.h"
#import "AVGLoadImageOperation.h"

@interface AVGFlickerTableViewController () <UISearchBarDelegate>

@property (strong, nonatomic) NSArray *arrayOfImageUrls;

@property (strong, nonatomic) NSOperationQueue *queue;

@property (nonatomic, strong) AVGFlickrService *flickrService;

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) NSCache *imageCache;

@end

@implementation AVGFlickerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Flickr"]; // property
    [self.tableView registerClass:[AVGFlickrCell class] forCellReuseIdentifier:flickrCellIdentifier];
    
    self.flickrService = [AVGFlickrService new];
    CGRect bounds = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40.f);
    self.searchBar = [[UISearchBar alloc] initWithFrame:bounds];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Поиск";
    self.tableView.tableHeaderView = self.searchBar;
    
    self.queue = [NSOperationQueue new];
    self.imageCache = [NSCache new];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arrayOfImageUrls count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AVGFlickrCell *cell = [tableView dequeueReusableCellWithIdentifier:flickrCellIdentifier forIndexPath:indexPath];
    cell.searchedImageView.image = nil;
    if (!cell) {
        cell = [[AVGFlickrCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:flickrCellIdentifier];
    }
    
    AVGImageInformation *imageInfo = self.arrayOfImageUrls[indexPath.row];
    
    AVGLoadImageOperation *loadImageOperation = [[AVGLoadImageOperation alloc] initWithImageInfromation:imageInfo];
    [self.queue addOperation:loadImageOperation];
    
    UIImage *image = [self.imageCache objectForKey:imageInfo.url];
    
    if (image) {
        cell.searchedImageView.image = image;
    } else {
        [cell.searchedImageView.activityIndicatorView startAnimating];
        cell.searchedImageView.progressView.hidden = NO;
        loadImageOperation.downloadProgressBlock = ^(float progress) {
            if (progress == 1.0f) {
                cell.searchedImageView.progressView.hidden = YES;
            }
            cell.searchedImageView.progressView.progress = progress;
        };
        
        __weak AVGFlickrCell *weakCell = cell;
        __weak AVGLoadImageOperation *weakOperation = loadImageOperation;
        loadImageOperation.completionBlock = ^{

            __strong AVGFlickrCell *strongCell = weakCell;
            __strong AVGLoadImageOperation *strongOperation = weakOperation;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongCell && strongOperation) {
                    [strongCell.searchedImageView.activityIndicatorView stopAnimating];
                    [self.imageCache setObject:strongOperation.downloadedImage forKey:imageInfo.url];
                    strongCell.searchedImageView.image = strongOperation.downloadedImage;
                    [strongCell layoutSubviews];
                }
            });
            
        };
    }
    
    return cell;
    // svyazat cell & nsoperation cherez delegate
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AVGFlickrCell heightForCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    NSString *searchText = searchBar.text;
    
    __weak typeof(self) weakSelf = self;
    [self.flickrService loadImagesInformationWithName:searchText withCompletionHandler:^(NSArray *imagesInfo, NSError *error) {
        
        __strong typeof(self) strongSelf = weakSelf;
        if ([imagesInfo count] > 0) {
            if (strongSelf) {
                strongSelf.arrayOfImageUrls = imagesInfo;
                
                NSIndexSet *set = [NSIndexSet indexSetWithIndex:0];
                [strongSelf.tableView beginUpdates];
                [strongSelf.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
                [strongSelf.tableView endUpdates];
                [strongSelf.searchBar endEditing:YES];
            }
        } else {
            // No photos! - show uiview animationduration?
            [strongSelf.searchBar endEditing:YES];
        }
    }];
}

@end
