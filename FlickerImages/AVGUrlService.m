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
#import "AVGLoadParseContainer.h"

@interface AVGUrlService ()

@property (nonatomic, copy) NSString *searchText;

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) AVGLoadUrlOperation *loadUrlsOperation;
@property (nonatomic, strong) AVGParseUrlOperation *parseUrlsOperation;

@property (nonatomic, strong) AVGLoadParseContainer *operationDataContainer;

@end

@implementation AVGUrlService

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queue = [NSOperationQueue new];
    }
    
    return  self;
}

- (void)loadInformationWithText:(NSString *)text {
    
    self.operationDataContainer = [AVGLoadParseContainer new];
    
    self.loadUrlsOperation = [AVGLoadUrlOperation new];
    _loadUrlsOperation.container = _operationDataContainer;
    
    self.parseUrlsOperation = [AVGParseUrlOperation new];
    _parseUrlsOperation.container = _operationDataContainer;
    [_parseUrlsOperation addDependency:_loadUrlsOperation];
    
    _loadUrlsOperation.searchText = text;
    [_queue addOperation:_loadUrlsOperation];
}

- (void)parseInformationWithCompletionHandler:(void(^)(NSArray *imageUrls))completion {
    [_queue addOperation:_parseUrlsOperation];
    
    __weak typeof(self) weakSelf = self;
    _parseUrlsOperation.completionBlock = ^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.imagesUrls = strongSelf.operationDataContainer.imagesUrl;
        if (completion) {
            completion(strongSelf.imagesUrls);
        }
    };
}

@end
