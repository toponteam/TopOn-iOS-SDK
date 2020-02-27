//
//  NADReward.h
//  NendAd
//

#import <Foundation/Foundation.h>

@interface NADReward : NSObject

/// Name of the reward currency.
@property (nonatomic, readonly, copy) NSString *name;

/// Amount rewarded to the user.
@property (nonatomic, readonly) NSInteger amount;

@end
