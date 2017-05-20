//
//  AVGFlickerTableViewController.m
//  FlickerImages
//
//  Created by iOS-School-1 on 20.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AVGFlickerTableViewController.h"
#import "AVGFlickrCell.h"
#import "AVGImage.h"
#import "AVGOperation.h"

@interface AVGFlickerTableViewController ()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

@property (strong, nonatomic) NSArray *arrayOfImageUrls;

@property (strong, nonatomic) NSOperationQueue *queue;

@end

@implementation AVGFlickerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Flickr"]; // property
    [self.tableView registerClass:[AVGFlickrCell class] forCellReuseIdentifier:flickrCellIdentifier];
    
    [self loadImagesWithName:@"sea" withCompletionHandler:^(NSArray *atms, NSError *error) {
        [self.tableView reloadData];
    }];
    
    self.queue = [NSOperationQueue new];
}

#pragma mark - Load info from Flickr

- (void)loadImagesWithName:(NSString *)text withCompletionHandler:(void(^)(NSArray *atms, NSError *error))completion {
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    if (self.sessionDataTask) {
        [self.sessionDataTask cancel];
    }
    
    NSString *urlBaseString = @"https://api.flickr.com/services/rest/?method=flickr.photos.search&license=1,2,4,7&has_geo=1&extras=original_format,description,date_taken,geo,date_upload,owner_name,place_url,tags&format=json&api_key=c55f5a419863413f77af53764f86bd66&nojsoncallback=1&";
    NSString *urlParametersString = [NSString stringWithFormat:@"text=%@", text];
    NSString *query = [NSString stringWithFormat:@"%@%@", urlBaseString, urlParametersString];
    NSURL *url = [NSURL URLWithString:[query stringByAddingPercentEncodingWithAllowedCharacters:
                                       [NSCharacterSet URLFragmentAllowedCharacterSet]]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    self.sessionDataTask = [self.session dataTaskWithRequest:request
                                           completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                               
                                               if (data) {
                                                   NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                   dict = dict[@"photos"];
                                                   dict = dict[@"photo"];
                                                   
                                                   NSMutableArray *images = [NSMutableArray new];
                                                   for (id object in dict) {
                                                       AVGImage *image = [AVGImage new];
                                                       image.farm = object[@"farm"];
                                                       image.secretID = object[@"secret"];
                                                       image.serverID = object[@"server"];
                                                       image.imageID = object[@"id"];
                                                       
                                                       [images addObject:image];
                                                   }
                                                   self.arrayOfImageUrls = images;
                                                   
                                                   if (completion) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           
                                                       });
                                                   }
                                               } else {
                                                   
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       completion(nil, error);
                                                   });
                                                   return;
                                               }
                                           }];
    [self.sessionDataTask resume];

}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arrayOfImageUrls count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AVGFlickrCell *cell = [tableView dequeueReusableCellWithIdentifier:flickrCellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[AVGFlickrCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:flickrCellIdentifier];
    }
    
    AVGImage *image = self.arrayOfImageUrls[indexPath.row];
    
    AVGOperation *operation = [AVGOperation new];
    operation.imageUrlString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@.jpg", image.farm, image.serverID, image.imageID, image.secretID];
    [self.queue addOperation:operation];

    return cell;
// svyazat cell & nsoperation cherez 
}

@end
