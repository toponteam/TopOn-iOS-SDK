//
//  ATKidozBaseManager.h
//  AnyThinkKidozAdapter
//
//  Created by Topon on 12/23/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkSDK/AnyThinkSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATKidozBaseManager : ATNetworkBaseManager

@end

@protocol ATKidozSDK <NSObject>
+ (id)instance;
- (NSString*)getSdkVersion;
@end

NS_ASSUME_NONNULL_END
