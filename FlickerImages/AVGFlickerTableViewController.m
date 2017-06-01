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
#import "AVGImageService.h"
#import "AVGUrlService.h"

@interface AVGFlickerTableViewController () <UISearchBarDelegate>

@property (nonatomic, strong) NSArray <AVGImageInformation *> *arrayOfImagesInformation;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) AVGUrlService *urlService;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSCache *imageCache;

@property (nonatomic, strong) NSMutableArray <AVGImageService *> *imageServices;

@end

@implementation AVGFlickerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Flickr";
    [self.tableView registerClass:[AVGFlickrCell class] forCellReuseIdentifier:flickrCellIdentifier];
    
    self.urlService = [AVGUrlService new];
    CGRect bounds = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40.f);
    self.searchBar = [[UISearchBar alloc] initWithFrame:bounds];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"Поиск";
    self.tableView.tableHeaderView = self.searchBar;
    
    self.queue = [NSOperationQueue new];
    self.imageCache = [NSCache new];
    _imageCache.countLimit = 50;
    
    self.imageServices = [NSMutableArray new];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arrayOfImagesInformation count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AVGFlickrCell *cell = [tableView dequeueReusableCellWithIdentifier:flickrCellIdentifier forIndexPath:indexPath];
    cell.searchedImageView.image = nil;
    #warning no need
    /*
    if (!cell) {
        NSLog(@"Cell created");
        cell = [[AVGFlickrCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:flickrCellIdentifier];
    }
    */
    // separate to another method
    AVGImageService *imageService = _imageServices[indexPath.row];
    cell.imageServiceDelegate = imageService;
    
    AVGImageInformation *imageInfo = _arrayOfImagesInformation[indexPath.row];
    UIImage *cachedImage = [_imageCache objectForKey:imageInfo.url];
    
    if (imageService.imageState == AVGImageStateBinarized) {
        cell.filterButton.enabled = NO;
    } else {
        cell.filterButton.enabled = YES;
    }
    
    if (cachedImage) {
        cell.searchedImageView.image = cachedImage;
    } else {
        [cell.imageServiceDelegate loadImageFromUrlString:imageInfo.url andCache:self.imageCache forCell:cell];
    }
    // pause/resume
    // page loading
    
    return cell;
}
#warning self & _
#warning separate!
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AVGFlickrCell heightForCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_searchBar endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    AVGImageService *service = _imageServices[indexPath.row];
    AVGImageProgressState state = [service imageProgressState];
    if (state == AVGImageProgressStateDownloading) {
        [service pause];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    AVGImageService *service = _imageServices[indexPath.row];
    AVGImageProgressState state = [service imageProgressState];
    if (state == AVGImageProgressStatePaused) {
        [service resume];
    }
}

#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    NSString *searchText = searchBar.text;
    
    [_urlService loadInformationWithText:searchText];
    [_urlService parseInformationWithCompletionHandler:^(NSArray *imageUrls) {
        
        _arrayOfImagesInformation = imageUrls;
        NSUInteger countOfImages = [imageUrls count];
        for (NSUInteger i = 0; i < countOfImages; i++) {
            AVGImageService *imageService = [AVGImageService new];
            [_imageServices addObject:imageService];
        }
        
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            [self.searchBar endEditing:YES];
        });
    }];
}

@end
