//
//  ExternalConsentManager.h
//  OguryConsentManagerTests
//
//  Copyright © 2019 Ogury Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^ExternalConsentManagerCompletionBlock)(NSString * response);
@interface ExternalConsentManager : NSObject

+ (void)setConsentWithAssetKey:(NSString * _Nonnull)assetKey iabString:(NSString * _Nonnull)iabString andNonIABVendorsAccepted:(NSArray<NSString*>* _Nullable)nonIABVendorsAccepted;

@end

NS_ASSUME_NONNULL_END
