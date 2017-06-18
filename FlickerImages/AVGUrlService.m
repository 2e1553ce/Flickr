//
//  AVGUrlService.m
//  FlickerImages
//
//  Created by aiuar on 26.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AVGUrlService.h"
#import "AVGLoadUrlOperation.h"
#import "AVGParseUrlOperation.h"
#import "AVGOperationsContainer.h"

@interface AVGUrlService ()

@property (nonatomic, copy) NSString *searchText;

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) AVGLoadUrlOperation *loadUrlsOperation;
@property (nonatomic, strong) AVGParseUrlOperation *parseUrlsOperation;

@property (nonatomic, strong) AVGOperationsContainer *operationDataContainer;

@end

@implementation AVGUrlService

static NSInteger const perPage = 50;

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queue = [NSOperationQueue new];
    }
    return  self;
}

#pragma mark - Loading urls for images

- (void)loadInformationWithText:(NSString *)text
                        forPage:(NSInteger)page {
    
    self.operationDataContainer = [AVGOperationsContainer new];
    
    self.loadUrlsOperation = [AVGLoadUrlOperation new];
    self.loadUrlsOperation.container = self.operationDataContainer;
    
    self.parseUrlsOperation = [AVGParseUrlOperation new];
    self.parseUrlsOperation.container = self.operationDataContainer;
    [self.parseUrlsOperation addDependency:self.loadUrlsOperation];
    
    self.loadUrlsOperation.searchText = text;
    self.loadUrlsOperation.page = page;
    self.loadUrlsOperation.perPage = perPage;
    
    [self.queue cancelAllOperations];
    [self.queue addOperation:self.loadUrlsOperation];
}

#pragma mark - Parsing loaded urls for images

- (void)parseInformationWithCompletionHandler:(void(^)(NSArray *imageUrls))completion {
    [self.queue addOperation:self.parseUrlsOperation];
    
    __weak typeof(self) weakSelf = self;
    self.parseUrlsOperation.completionBlock = ^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.imagesUrls = strongSelf.operationDataContainer.imagesUrl;
        if (completion) {
            completion(strongSelf.imagesUrls);
        }
    };
}

@end
