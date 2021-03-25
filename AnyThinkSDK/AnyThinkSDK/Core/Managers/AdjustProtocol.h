//
//  AdjustProtocol.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/11/4.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AdjustEventProtocol <NSObject>

+ (instancetype)eventWithEventToken:(NSString *)token;
- (void)setRevenue:(double)revenue currency:(NSString *)currency;
- (void)setTransactionId:(nonnull NSString *)transactionId;
@end

@protocol AdjustProtocol <NSObject>

+ (void)trackEvent:(id<AdjustEventProtocol>)event;

@end

