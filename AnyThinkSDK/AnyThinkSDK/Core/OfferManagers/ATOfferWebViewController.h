//
//  ATOfferWebViewController.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/9/30.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATOfferWebViewController : UIViewController

@property (copy, nonatomic) NSString *urlString;
@property (copy, nonatomic) NSString *storeUrlStr;

// When true, it will open the url in safari after the redirection is failed.
@property (nonatomic) BOOL openInSafariWhenFailed;

@end

NS_ASSUME_NONNULL_END
