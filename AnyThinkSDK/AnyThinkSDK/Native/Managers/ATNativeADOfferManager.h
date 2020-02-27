//
//  ATNativeADOfferManager.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 12/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATAd.h"
#import "ATAdManagement.h"
@class ATPlacementModel;
@class ATUnitGroupModel;
@class ATNativeADCache;
@interface ATNativeADOfferManager : NSObject<ATAdManagement>
+(instancetype)sharedManager;
-(ATNativeADCache*)nativeAdWithPlacementID:(NSString*)placementID extra:(NSDictionary*__autoreleasing*)extra;
-(ATNativeADCache*)nativeAdWithPlacementID:(NSString*)placementID invalidateStatus:(BOOL)invalidateStatus extra:(NSDictionary*__autoreleasing*)extra;
-(BOOL) offerExhaustedInPlacementID:(NSString*)placementID unitGroupID:(NSString*)unitGroupID;
@end
