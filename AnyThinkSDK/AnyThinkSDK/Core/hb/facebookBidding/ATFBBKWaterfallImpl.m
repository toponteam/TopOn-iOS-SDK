//
//  ATFBBKWaterfallImpl.m
//  AnyThinkSDK
//
//  Created by Jason on 2021/1/5.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import "ATFBBKWaterfallImpl.h"
#import "ATFBBKWaterfallEntryImpl.h"

@interface ATFBBKWaterfallImpl ()

@property(nonatomic, strong) NSMutableArray<id<FBBKWaterfallEntry>> *waterfallEntries;

@end

@implementation ATFBBKWaterfallImpl

- (NSArray<id<FBBKWaterfallEntry>> *)entries {
    return self.waterfallEntries;
}

- (instancetype)initWithEntries:(NSArray<id<FBBKWaterfallEntry>> *)kEntries {
    self = [super init];
    self.waterfallEntries = kEntries.mutableCopy;
    return self;
}

- (id<FBBKWaterfall>)createWaterfallCopy {
    ATFBBKWaterfallImpl *impl = [[ATFBBKWaterfallImpl alloc]initWithEntries:self.waterfallEntries];
    return impl;
}

- (void)insertEntryUsingBid:(id<ATFBBKBid>)bid {
    ATFBBKWaterfallEntryImpl *impl = [[ATFBBKWaterfallEntryImpl alloc] initWithBid:bid CPMCents:bid.price entryName:bid.bidderName];
    [self insertEntry:impl];
}

- (void)insertEntry:(id<FBBKWaterfallEntry>)entry {
    if (entry == nil) {
        return;
    }
    [self.waterfallEntries addObject:entry];
    [self.waterfallEntries sortUsingComparator:^NSComparisonResult(id<FBBKWaterfallEntry>  _Nonnull obj1, id<FBBKWaterfallEntry>  _Nonnull obj2) {
        return obj1.CPMCents < obj2.CPMCents;
    }];
}

@end
