//
//  ATAppnextBaseManager.h
//  AnyThinkAppnextAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNetworkBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATAppnextBaseManager : ATNetworkBaseManager

@end

@protocol ATAppnextSDKApi<NSObject>
+ (NSString *) getSDKVersion;
@end

NS_ASSUME_NONNULL_END
