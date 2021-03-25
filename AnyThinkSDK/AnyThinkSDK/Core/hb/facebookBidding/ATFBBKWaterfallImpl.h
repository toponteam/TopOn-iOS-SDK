//
//  ATFBBKWaterfallImpl.h
//  AnyThinkSDK
//
//  Created by Jason on 2021/1/5.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATFBBiddingManager.h"

NS_ASSUME_NONNULL_BEGIN

@class ATFBBKWaterfallEntryImpl;

@interface ATFBBKWaterfallImpl : NSObject<FBBKWaterfall>

- (instancetype)initWithEntries:(NSArray<id<FBBKWaterfallEntry>> *)kEntries;

@end

NS_ASSUME_NONNULL_END
