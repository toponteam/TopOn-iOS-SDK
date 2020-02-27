//
//                   .h
//  AppnextLib
//
//  Created by shalom.b on 1/23/18.
//  Copyright © 2018 Appnext. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BannerRequest.h"
#import <AppnextSDKCore/AppnextError.h>

@protocol AppnextBannerDelegate <NSObject>
@optional
- (void) onAppnextBannerLoadedSuccessfully;
- (void) onAppnextBannerError:(AppnextError) error;
- (void) onAppnextBannerClicked;
- (void) onAppnextBannerImpressionReported;
@end

@interface AppnextBannerView : UIView
@property (nonatomic, weak) id<AppnextBannerDelegate> delegate;
- (instancetype) initBannerWithPlacementID:(NSString *) placemnetID;
- (void) loadAd:(BannerRequest *) bannerRequest;
@end
