//
//  ATFBBKWaterfallEntryImpl.h
//  AnyThinkSDK
//
//  Created by Jason on 2021/1/5.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATFBBiddingManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATFBBKWaterfallEntryImpl : NSObject<FBBKWaterfallEntry>

@property(nonatomic) id<ATFBBKBid> ATBid;
@property(nonatomic) double ATCPMCents;
@property(nonatomic, copy) NSString *ATEntryName;

- (instancetype)initWithBid:(id<ATFBBKBid>)bid CPMCents:(double)cents entryName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
