//
//  PresageOptinVideo.h
//  PresageSDK
//
//  Copyright © 2019 Ogury. All rights reserved.
//

#import "OguryAdsInterstitial.h"
NS_ASSUME_NONNULL_BEGIN

@interface OguryAdsOptinVideo : OguryAdsInterstitial
@property (nonatomic, weak) id <OguryAdsOptinVideoDelegate> optInVideoDelegate;

- (instancetype _Nullable)initWithAdUnitID:( NSString* _Nullable )adUnitID;
@end



NS_ASSUME_NONNULL_END
