//
//  ATOnlineApiRewardedVideoAdapter.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATOnlineApiRewardedVideoAdapter : NSObject

@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);

@end

NS_ASSUME_NONNULL_END
