//
//  AppDelegate.m
//  FlickerImages
//
//  Created by iOS-School-1 on 20.05.17.
//  Copyright © 2017 iOS-School-1. All rights reserved.
//

#import "AppDelegate.h"
#import "AVGFlickerTableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    AVGFlickerTableViewController *flickVC = [AVGFlickerTableViewController new];
    
    UINavigationController *navVC = [UINavigationController new];
    navVC.viewControllers = @[flickVC];
    
    self.window.rootViewController = navVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end

/*
 //
 //  DemoViewController.m
 //  NSOperation
 //
 //  Created by iOS-School-1 on 20.05.17.
 //  Copyright © 2017 iOS-School-1. All rights reserved.
 //
 
 #import "DemoViewController.h"
 #import "Operation.h"
 
 @interface DemoViewController ()
 
 @end
 
 @implementation DemoViewController
 
 - (void)viewDidLoad {
 [super viewDidLoad];
 self.view.backgroundColor = UIColor.cyanColor;
 
 NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
 
 
 NSOperationQueue *queue = [NSOperationQueue new];
 queue.qualityOfService = NSQualityOfServiceUserInitiated;
 //queue.maxConcurrentOperationCount = 1;
 
 /*
 NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self
 selector:@selector(someSelector:)
 object:@"invocationOperation"];
 
 [queue addOperation:invocationOperation];
 
 //
 NSOperation *operation = [NSOperation new];
 operation.completionBlock = ^{
 [self someSelector:@"asdda"];
 };
 [queue addOperation:operation];
 
 //
 NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
 sleep(1);
 [self someSelector:@"blockOperation1"];
 }];
 
 [queue addOperation:blockOperation];
 
 [blockOperation addDependency:operation];
 
 NSBlockOperation *blockOp2 = [NSBlockOperation blockOperationWithBlock:^{
 sleep(2);
 NSLog(@"blockOp2");
 }];
 
 //[invocationOperation addDependency:blockOp2];
 //[invocationOperation addDependency:operation];
 [mainQueue addOperation:blockOp2];
 */
/*
Operation *myOp1 = [Operation new];
myOp1.str = @"myOp1";
[queue addOperation:myOp1];
//[myOp1 start];

Operation *myOp2 = [Operation new];
myOp2.queuePriority = NSOperationQueuePriorityLow;
myOp2.str = @"myOp2";
[queue addOperation:myOp2];

Operation *myOp3 = [Operation new];
myOp3.str = @"myOp3";
[queue addOperation:myOp3];

Operation *myOp4 = [Operation new];
myOp4.str = @"myOp4";
myOp4.queuePriority = NSOperationQueuePriorityHigh;
[queue addOperation:myOp4];

Operation *myOp5 = [Operation new];
myOp5.str = @"myOp5";
[queue addOperation:myOp5];
}

- (void)someSelector:(NSString *)str {
    NSLog(@"%@", [NSThread currentThread]);
    NSLog(@"%@", str);
}

// poisk sverhu po kartinkam // binary image - filter

@end

*/
