//
//  ATGDTBaseManager.h
//  AnyThinkGDTAdapter
//
//  Created by Topon on 11/11/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNetworkBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATGDTBaseManager : ATNetworkBaseManager
@end

@protocol ATGDTSDKConfig<NSObject>
+ (BOOL)registerAppId:(NSString *)appId;
+ (NSString *)sdkVersion;
+ (void)enableDefaultAudioSessionSetting:(BOOL)enabled;
@end


NS_ASSUME_NONNULL_END
