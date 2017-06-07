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

@interface AVGFlickerTableViewController () <UISearchBarDelegate, AVGImageServiceDelegate, AVGFlickrCellDelegate>

@property (nonatomic, strong) NSCache *imageCache; // need service

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, copy)   NSString *searchText;
@property (nonatomic, assign) NSInteger page;

@property (nonatomic, strong) NSMutableArray <AVGImageService *> *imageServices;
@property (nonatomic, strong) NSMutableArray <AVGImageInformation *> *arrayOfImagesInformation;
@property (nonatomic, strong) AVGUrlService *urlService;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isLoadingBySearch; // при втором и далее поиске(через серч бар) вызывает didEndDisplay и канселит загрузку

@property (nonatomic, strong) UIActivityIndicatorView *indicatorFooter;

@end

@implementation AVGFlickerTableViewController

#pragma mark - View controller life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Flickr";
    [self.tableView registerClass:[AVGFlickrCell class] forCellReuseIdentifier:flickrCellIdentifier];
    
    self.urlService = [AVGUrlService new];
    self.imageCache = [NSCache new];
    _imageCache.countLimit = 50;
    self.imageServices = [NSMutableArray new];
    self.isLoading = YES;
    _isLoadingBySearch = YES;
    
    CGRect bounds = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40.f);
    self.searchBar = [[UISearchBar alloc] initWithFrame:bounds];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"Поиск";
    self.tableView.tableHeaderView = self.searchBar;
    
    _indicatorFooter = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44)];
    [_indicatorFooter setColor:[UIColor blackColor]];
    [self.tableView setTableFooterView:_indicatorFooter];
    self.tableView.tableFooterView.hidden = YES;
}

#pragma mark - Download when scrolling

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        if (!_isLoading) {
            _isLoading = YES;
            self.tableView.tableFooterView.hidden = NO;
            [_indicatorFooter startAnimating];
            [self loadImages];
        }
    }
}

#pragma mark - Page loading (AVGImageService.m contains variable how many images load per page)

- (void)loadImages {
    _isLoadingBySearch = NO;
    _page++;
    
    [_urlService loadInformationWithText:_searchText forPage:_page];
    [_urlService parseInformationWithCompletionHandler:^(NSArray *imageUrls) {
        
        [_arrayOfImagesInformation addObjectsFromArray:[imageUrls mutableCopy]];
        NSUInteger countOfImages = [imageUrls count];
        for (NSUInteger i = 0; i < countOfImages; i++) {
            AVGImageService *imageService = [AVGImageService new];
            [_imageServices addObject:imageService];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSMutableArray *arrayOfIndexPathes = [[NSMutableArray alloc] init];
            
            for(int i = (int)[_arrayOfImagesInformation count] - (int)[imageUrls count]; i < [_arrayOfImagesInformation count]; ++i){
                
                [arrayOfIndexPathes addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            
            self.tableView.tableFooterView.hidden = YES;
            [_indicatorFooter stopAnimating];
            
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:arrayOfIndexPathes withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            [self.searchBar endEditing:YES];
            _isLoading = NO;
        });
    }];

}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arrayOfImagesInformation count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AVGFlickrCell *cell = [tableView dequeueReusableCellWithIdentifier:flickrCellIdentifier forIndexPath:indexPath];
    
    AVGImageService *imageService = _imageServices[indexPath.row];
    AVGImageInformation *imageInfo = _arrayOfImagesInformation[indexPath.row];
    UIImage *cachedImage = [_imageCache objectForKey:imageInfo.url];
    
    if (cachedImage) {
        [cell.searchedImageView.activityIndicatorView stopAnimating];
        cell.searchedImageView.progressView.hidden = YES;
        cell.searchedImageView.image = cachedImage;
    } else {
        cell.delegate = self;
        imageService.delegate = self;
        imageService.imageState = AVGImageStateNormal;
        [imageService loadImageFromUrlString:imageInfo.url andCache:self.imageCache forRowAtIndexPath:(NSIndexPath *)indexPath];
    }
    
    if (imageService.imageState == AVGImageStateBinarized) {
        cell.filterButton.enabled = NO;
    } else {
        cell.filterButton.enabled = YES;
    }
    
    return cell;
}

#warning (self & _) - code style, вынести делегаты датасорсы в отдельные файлы
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
    if (state == AVGImageProgressStateDownloading && !_isLoadingBySearch) {
        [service cancel];
    }
}

#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [_imageServices removeAllObjects];
    _page = 1;
    _isLoadingBySearch = YES;
    
    _searchText = searchBar.text;
    
    [_urlService loadInformationWithText:_searchText forPage:_page];
    [_urlService parseInformationWithCompletionHandler:^(NSArray *imageUrls) {
        
        _arrayOfImagesInformation = [imageUrls mutableCopy];
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
            _isLoading = NO;
        });
    }];
}

#pragma mark - AVGFlickrCellDelegate

- (void)filterImageForCell:(AVGFlickrCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    AVGImageService *service = _imageServices[indexPath.row];
    [service filterImageforRowAtIndexPath:indexPath];
}

#pragma mark - AVGImageServiceDelegate

- (void)serviceStartedImageDownload:(AVGImageService *)service forRowAtIndexPath:(NSIndexPath*)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        AVGFlickrCell *cell = (AVGFlickrCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.searchedImageView.progressView.hidden = NO;
        cell.searchedImageView.activityIndicatorView.hidden = NO;
        cell.searchedImageView.progressView.progress = 0.f;
        [cell.searchedImageView.activityIndicatorView startAnimating];
    });
}

- (void)service:(AVGImageService *)service updateImageDownloadProgress:(float)progress forRowAtIndexPath:(NSIndexPath*)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        AVGFlickrCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.searchedImageView.progressView.progress = progress;
    });
}

- (void)service:(AVGImageService *)service downloadedImage:(UIImage *)image forRowAtIndexPath:(NSIndexPath*)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (image) {
            AVGFlickrCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.searchedImageView.image = image;
            [cell.searchedImageView.activityIndicatorView stopAnimating];
            cell.searchedImageView.progressView.hidden = YES;
            [cell setNeedsLayout];
        }
    });

}

- (void)service:(AVGImageService *)service binarizedImage:(UIImage *)image forRowAtIndexPath:(NSIndexPath*)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (image) {
            AVGFlickrCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.filterButton.enabled = NO;
            
            [UIView animateWithDuration:0.3f animations:^{
                cell.searchedImageView.alpha = 0.f;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3f animations:^{
                    cell.searchedImageView.image = image;
                    cell.searchedImageView.alpha = 1.f;
                }];
            }];
            [cell setNeedsLayout];
        }
    });
}

@end
