//
//  ATNativeRenderer.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 25/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATNativeRenderer.h"
#import "ATNativeADView.h"
#import "ATNativeADConfiguration.h"
#import "ATNativeADView+Internal.h"
#import "ATNativeADCache.h"
#import "ATNativeADView+Internal.h"

@implementation ATNativeRenderer
-(instancetype) initWithConfiguraton:(ATNativeADConfiguration*)configuration adView:(ATNativeADView*)adView {
    self = [super init];
    if (self != nil) {
        _configuration = configuration;
        _ADView = adView;
    }
    return self;
}

+(id) retrieveRendererWithOffer:(ATNativeADCache*)offer {
    return nil;
}

-(UIView*)retriveADView {
    return nil;
}

-(__kindof UIView*)createMediaView {
    return nil;
}

-(void) renderOffer:(ATNativeADCache *)offer {
    if ([self.ADView respondsToSelector:@selector(advertiserLabel)]) [self.ADView advertiserLabel].text = offer.advertiser;
    if ([self.ADView respondsToSelector:@selector(titleLabel)]) [self.ADView titleLabel].text = offer.title;
    if ([self.ADView respondsToSelector:@selector(textLabel)]) [self.ADView textLabel].text = offer.mainText;
    if ([self.ADView respondsToSelector:@selector(iconImageView)]) [self.ADView iconImageView].image = offer.icon;
    if ([self.ADView respondsToSelector:@selector(mainImageView)]) [self.ADView mainImageView].image = offer.mainImage;
    if ([self.ADView respondsToSelector:@selector(logoImageView)]) [self.ADView logoImageView].image = offer.logo;
    if ([self.ADView respondsToSelector:@selector(sponsorImageView)]) [self.ADView sponsorImageView].image = offer.sponsorImage;
    if ([self.ADView respondsToSelector:@selector(ctaLabel)]) [self.ADView ctaLabel].text = offer.ctaText;
    if ([self.ADView respondsToSelector:@selector(ratingLabel)]) [self.ADView ratingLabel].text = offer.rating != nil ? [NSString stringWithFormat:@"%@", offer.rating] : @"";
}

/**
 * The default implemention return the offer's value of isVideoContents; but for some network(mintegral for instance), this infomation's contained in it's media view, therefore the subclass has to override this method to give the correct return value.
 */
-(BOOL) isVideoContents {
    return self.ADView.nativeAd.isVideoContents;
}
@end
