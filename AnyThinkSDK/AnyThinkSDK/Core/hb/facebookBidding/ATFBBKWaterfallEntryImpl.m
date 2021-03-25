//
//  ATFBBKWaterfallEntryImpl.m
//  AnyThinkSDK
//
//  Created by Jason on 2021/1/5.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import "ATFBBKWaterfallEntryImpl.h"

@implementation ATFBBKWaterfallEntryImpl

- (instancetype)initWithBid:(id<ATFBBKBid>)bid CPMCents:(double)cents entryName:(NSString *)name {
    self = [super init];
    if (self) {
        self.ATBid = bid;
        self.ATEntryName = name;
        self.ATCPMCents = cents;
    }
    return self;
}

- (NSString *)entryName {
    return self.ATEntryName;
}

- (double)CPMCents {
    return self.ATCPMCents;
}

- (id<ATFBBKBid>)bid {
    return self.ATBid;
}

@end
