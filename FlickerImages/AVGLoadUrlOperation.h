//
//  AVGLoadUrlOperation.h
//  FlickerImages
//
//  Created by aiuar on 26.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

@import Foundation;
@class AVGOperationsContainer;

@interface AVGLoadUrlOperation : NSOperation

@property (nonatomic, copy) NSString *searchText;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger perPage;

@property (nonatomic, strong) AVGOperationsContainer *container;

@end
