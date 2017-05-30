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
#import "AVGLoadImageOperation.h"
#import "AVGBinaryImageOperation.h"
#import "AVGImageService.h"
#import "AVGUrlService.h"

@interface AVGFlickerTableViewController () <UISearchBarDelegate>

@property (strong, nonatomic) NSArray <AVGImageInformation *> *arrayOfImagesInformation;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (nonatomic, strong) AVGUrlService *urlService;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSCache *imageCache;

@property (nonatomic, strong) NSMutableArray <filterBlock> *arrayOfBlocks;
@property (nonatomic, strong) NSMutableArray <AVGBinaryImageOperation *> *binaryOperations;
@property (nonatomic, strong) NSMutableArray <AVGImageService *> *imageServices;

@end

@implementation AVGFlickerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Flickr"]; // property
    [self.tableView registerClass:[AVGFlickrCell class] forCellReuseIdentifier:flickrCellIdentifier];
    
    self.urlService = [AVGUrlService new];
    CGRect bounds = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40.f);
    self.searchBar = [[UISearchBar alloc] initWithFrame:bounds];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Поиск";
    self.tableView.tableHeaderView = self.searchBar;
    
    self.queue = [NSOperationQueue new];
    self.imageCache = [NSCache new];
    [self.imageCache setCountLimit:50];
    
    self.arrayOfBlocks = [NSMutableArray new];
    self.binaryOperations = [NSMutableArray new];
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
    AVGImageService *imageService = [AVGImageService new];
    cell.imageServiceDelegate = imageService;
    [self.imageServices addObject:imageService];
    
    AVGImageInformation *imageInfo = _arrayOfImagesInformation[indexPath.row];
    UIImage *cachedImage = [self.imageCache objectForKey:imageInfo.url];
    
    if (cachedImage) {
        cell.searchedImageView.image = cachedImage;
    } else {
        [cell.imageServiceDelegate loadImageFromUrlString:imageInfo.url andCache:self.imageCache forCell:cell];
    }
    // pause/resume
    // page loading
    
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

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    AVGImageService *imageService = self.imageServices[indexPath.row];
    [imageService cancelDownload];
}

#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    NSString *searchText = searchBar.text;
    
    [_urlService loadInformationWithText:searchText];
    [_urlService parseInformationWithCompletionHandler:^(NSArray *imageUrls) {
        _arrayOfImagesInformation = imageUrls;
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
