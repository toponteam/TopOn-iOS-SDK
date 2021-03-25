//
//  ATMaioBaseManager.h
//  AnyThinkMaioAdapter
//
//  Created by Topon on 11/16/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATNetworkBaseManager.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kMaioClassName;
@interface ATMaioBaseManager : ATNetworkBaseManager

@end

@protocol ATMaio<NSObject>
+ (NSString *)sdkVersion;
@end


NS_ASSUME_NONNULL_END
