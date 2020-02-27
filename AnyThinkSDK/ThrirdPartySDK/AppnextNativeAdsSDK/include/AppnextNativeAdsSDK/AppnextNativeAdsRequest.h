//
//  AppnextNativeAdsRequest.h
//  AppnextNativeAdsSDK
//
//  Created by Eran Mausner on 17/08/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextSDKCorePublicDefs.h>

@interface AppnextNativeAdsRequest : NSObject

@property (nonatomic, strong) NSString *categories;
@property (nonatomic, strong) NSString *postback;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) ANCreativeType creativeType;
@property (nonatomic, assign) BOOL clickInApp;

@end
