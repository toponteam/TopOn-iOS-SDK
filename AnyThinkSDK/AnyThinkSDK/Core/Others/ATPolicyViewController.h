//
//  ATPolicyViewController.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 18/05/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATPolicyViewController : UIViewController
@property(nonatomic) NSURL *policyPageURL;
@property(nonatomic, copy) void(^dismissalCallback)(void);
@property(nonatomic, copy) void(^loadingFailureCallback)(NSError *error);
@end
