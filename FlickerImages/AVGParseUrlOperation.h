//
//  AVGParseUrlOperation.h
//  FlickerImages
//
//  Created by aiuar on 26.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AVGLoadParseContainer;

@interface AVGParseUrlOperation : NSOperation

@property (nonatomic, strong) AVGLoadParseContainer *container;

@end
