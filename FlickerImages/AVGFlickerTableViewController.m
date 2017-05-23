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
#import "AVGOperation.h"
#import "AVGFlickrService.h"

@interface AVGFlickerTableViewController () <UISearchBarDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

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
    
    AVGOperation *operation = [AVGOperation new];
    operation.downloadProgressBlock = ^(float progress) {
        cell.searchedImageView.progressView.progress = progress;
    };
    [operation setUrlPathFromImageInformation:imageInfo];
    UIImage *image = [self.imageCache objectForKey:operation.imageUrlString];
    
    if (image) {
        cell.searchedImageView.image = image;
    } else {
        [cell.searchedImageView.activityIndicatorView startAnimating];
        [self.queue addOperation:operation];
        
        __weak AVGFlickrCell *weakCell = cell;
        __weak AVGOperation *weakOperation = operation;
        operation.downloadBlock = ^(UIImage *image) {
            __strong AVGFlickrCell *strongCell = weakCell;
            __strong AVGOperation *strongOperation = weakOperation;
            
            if (strongCell && strongOperation) {
                [strongCell.searchedImageView.activityIndicatorView stopAnimating];
                [self.imageCache setObject:strongOperation.downloadedImage forKey:strongOperation.imageUrlString];
                strongCell.searchedImageView.image = strongOperation.downloadedImage;
                [strongCell layoutSubviews];
            }

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
