//
//  AVGFlickerTableViewController.m
//  FlickerImages
//
//  Created by iOS-School-1 on 20.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

typedef void (^filterBlock)(void);

#import "AVGFlickerTableViewController.h"
#import "AVGFlickrCell.h"
#import "AVGImageInformation.h"
#import "AVGFlickrService.h"
#import "AVGLoadImageOperation.h"
#import "AVGBinaryImageOperation.h"

@interface AVGFlickerTableViewController () <UISearchBarDelegate>

@property (strong, nonatomic) NSArray *arrayOfImageUrls;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (nonatomic, strong) AVGFlickrService *flickrService;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSCache *imageCache;

@property (nonatomic, strong) NSMutableArray <filterBlock> *arrayOfBlocks;
@property (nonatomic, strong) NSMutableArray <AVGBinaryImageOperation *> *binaryOperations;
@property (nonatomic, strong) NSMutableArray <AVGLoadImageOperation *> *loadOperations;

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
    
    self.arrayOfBlocks = [NSMutableArray new];
    self.binaryOperations = [NSMutableArray new];
    self.loadOperations = [NSMutableArray new];
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
    
    // Image URL ========================================================
    AVGImageInformation *imageInfo = self.arrayOfImageUrls[indexPath.row];
    // ==================================================================
    
    // Filter black-white button ========================================
    [cell.filterButton addTarget:self
                          action:@selector(filterButtonAction:)
                forControlEvents:UIControlEventTouchUpInside];
    #warning  :(
    cell.filterButton.tag = indexPath.row;
    // ==================================================================
    
    // Operations load ==================================================
    AVGLoadImageOperation *loadImageOperation = self.loadOperations[indexPath.row];
    
    #warning  :(
    // [binaryOperation addDependency:loadImageOperation];
    [self.queue addOperation:loadImageOperation];
    // ==================================================================
    
    // Cached image =====================================================
    UIImage *image = [self.imageCache objectForKey:imageInfo.url];
    // ==================================================================
    
    // Disable/Enable black-white button ================================
    AVGBinaryImageOperation *op = self.binaryOperations[indexPath.row];
    if (op.state == AVGOperationStateBinarized) {
        cell.filterButton.enabled = NO;
    } else {
        cell.filterButton.enabled = YES;
    }
    // ==================================================================
    
    if (image) {
        cell.searchedImageView.image = image;
    } else {
        
        // Downloading image ============================================
        [cell.searchedImageView.activityIndicatorView startAnimating];
        cell.searchedImageView.progressView.hidden = NO;
        
        __weak AVGFlickrCell *weakCell = cell;
        loadImageOperation.downloadProgressBlock = ^(float progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong AVGFlickrCell *strongCell = weakCell;
                if (strongCell) {
                    if (progress == 1.0f) {
                        strongCell.searchedImageView.progressView.hidden = YES;
                        strongCell.searchedImageView.progressView.progress = 0.f;
                    }
                    strongCell.searchedImageView.progressView.progress = progress;
                }
            });
        };
        
        __weak AVGLoadImageOperation *weakLoadOperation = loadImageOperation;
        __weak AVGBinaryImageOperation *weakBinaryOperation = self.binaryOperations[indexPath.row];
        __weak NSCache *weakCache = self.imageCache;
        
        loadImageOperation.completionBlock = ^{
            
            __strong AVGFlickrCell *strongCell = weakCell;
            __strong AVGLoadImageOperation *strongLoadOperation = weakLoadOperation;
            __strong AVGBinaryImageOperation *strongBinaryOperation = weakBinaryOperation;
            __strong NSCache *strongCache = weakCache;
            
            if (strongBinaryOperation) {
                strongBinaryOperation.filteredImage = strongLoadOperation.downloadedImage;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongCell && strongLoadOperation) {
                    [strongCell.searchedImageView.activityIndicatorView stopAnimating];
                    [strongCache setObject:strongLoadOperation.downloadedImage forKey:imageInfo.url];
                    strongCell.searchedImageView.image = strongLoadOperation.downloadedImage;
                    [strongCell layoutSubviews];
                }
            });
            
        };
        // ==================================================================
        
        // Adding black-white filter by Button===============================
        __weak NSOperationQueue *weakQueue = self.queue;
        weakBinaryOperation = self.binaryOperations[indexPath.row];
        
        filterBlock block = ^{
            __strong AVGBinaryImageOperation *strongBinaryOperation = weakBinaryOperation;
            __strong NSOperationQueue *strongQueue = weakQueue;
            if (strongBinaryOperation) {
                
                if (strongBinaryOperation.state == AVGOperationStateNormal) {
                    [strongQueue addOperation:strongBinaryOperation];
                    
                    strongBinaryOperation.completionBlock = ^{
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            __strong AVGBinaryImageOperation *strongBinaryOperation = weakBinaryOperation;
                            __strong AVGFlickrCell *strongCell = weakCell;
                            __strong NSCache *strongCache = weakCache;
                            
                            if (strongCell) {
                                strongCell.searchedImageView.image = nil;
                                
                                strongCell.searchedImageView.image = strongBinaryOperation.filteredImage;
                                [strongCache setObject:strongBinaryOperation.filteredImage forKey:imageInfo.url];
                                [strongCell layoutSubviews];
                                strongCell.filterButton.enabled = NO;
                            }
                        });
                    };
                }
            };
        };
        [self.arrayOfBlocks addObject:block];
        // ==================================================================
    }
    
    return cell;
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
    
    [self.arrayOfBlocks removeAllObjects];
    [self.binaryOperations removeAllObjects];
    [self.loadOperations removeAllObjects];
    
    __weak typeof(self) weakSelf = self;
    [self.flickrService loadImagesInformationWithName:searchText withCompletionHandler:^(NSArray *imagesInfo, NSError *error) {
        
        __strong typeof(self) strongSelf = weakSelf;
        if ([imagesInfo count] > 0) {
            if (strongSelf) {
                strongSelf.arrayOfImageUrls = imagesInfo;
                
                for (NSInteger i = 0; i < [imagesInfo count]; ++i) {
                    
                    AVGBinaryImageOperation *binaryOperation = [AVGBinaryImageOperation new];
                    self.binaryOperations[i] = binaryOperation;
                    
                    AVGLoadImageOperation *loadOperation = [AVGLoadImageOperation new];
                    self.loadOperations[i] = loadOperation;
                }
                
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

#pragma mark - Actions

- (void)filterButtonAction:(UIButton *)sender {
    
    filterBlock block = self.arrayOfBlocks[sender.tag];
    block();
}

@end
