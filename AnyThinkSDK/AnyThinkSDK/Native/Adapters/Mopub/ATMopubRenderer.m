//
//  ATMopubRenderer.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 16/05/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATMopubRenderer.h"
#import "ATNativeADConfiguration.h"
#import "ATAdManager+Internal.h"
#import "ATAPI+Internal.h"
#import "ATNativeADCache.h"
#import "ATNativeADView+Internal.h"
#import <objc/runtime.h>
#import "ATNativeADDelegate.h"
#import "ATNativeADCustomEvent.h"
#import "ATMopubCustomEvent.h"

@interface UIView(ADViewRetrieving)
@end
@implementation UIView(ADViewRetrieving)
-(ATNativeADView*)embededAdView {
    __block ATNativeADView *embededAdView = nil;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ATNativeADView class]]) {
            embededAdView = obj;
            *stop = YES;
        }
    }];
    return embededAdView;
}
@end

@interface ATMopubRenderer()
@property(nonatomic, readonly) NSString *placementID;
@end
@implementation ATMopubRenderer
+ (ATMopubRendererConfiguration *)rendererConfigurationWithRendererSettings:(id<ATMPNativeAdRendererSettings>)rendererSettings {
    ATMopubRendererConfiguration *config = [[ATMopubRendererConfiguration alloc] init];
    config.rendererClass = [self class];
    config.rendererSettings = rendererSettings;
    config.supportedCustomEvents = @[@"MPMoPubNativeCustomEvent"];
    
    return config;
}

- (instancetype)initWithRendererSettings:(id<ATMPNativeAdRendererSettings>)rendererSettings {
    if (self = [super init]) {  
    }
    return self;
}

-(UIView*)retrieveViewWithAdapter:(id<MPNativeAdAdapter>)adapter error:(NSError *__autoreleasing *)error {
    ATMopubCustomEvent *customEvent = [ATMopubCustomEvent new];
    customEvent.adView = self.ADView;
    self.ADView.customEvent = customEvent;
    return self.ADView;
}

+(id) retrieveRendererWithOffer:(ATNativeADCache*)offer {
    return [offer.assets[kAdAssetsCustomObjectKey] valueForKey:@"renderer"];
}

//For refreshing
-(UIView*)retriveADView {
    UIView *adView = [((id<ATMPNativeAd>)((ATNativeADCache*)self.ADView.nativeAd).assets[kAdAssetsCustomObjectKey]) retrieveAdViewWithError:nil];
    adView.frame = self.configuration.ADFrame;
    self.ADView.frame = adView.bounds;
    ATMopubCustomEvent *customEvent = [ATMopubCustomEvent new];
    customEvent.adView = self.ADView;
    self.ADView.customEvent = customEvent;
    ((id<ATMPNativeAd>)((ATNativeADCache*)self.ADView.nativeAd).assets[kAdAssetsCustomObjectKey]).delegate = customEvent;
    
    return adView;
}

-(__kindof UIView*)createMediaView {
    UIView *adView = [((id<ATMPNativeAd>)((ATNativeADCache*)self.ADView.nativeAd).assets[kAdAssetsCustomObjectKey]) retrieveAdViewWithError:nil];
    adView.frame = self.configuration.ADFrame;
    self.ADView.frame = adView.bounds;
    ((id<ATMPNativeAd>)((ATNativeADCache*)self.ADView.nativeAd).assets[kAdAssetsCustomObjectKey]).delegate = (id<ATMPNativeAdDelegate>)self.ADView.customEvent;
    return [UIView new];
}

- (void)nativeAdTapped {
    [self.ADView.customEvent trackClick];
    [self.ADView notifyNativeAdClick];
}
@end

@implementation ATMopubRenderSettings
@end

@implementation ATMopubRendererConfiguration
@end
