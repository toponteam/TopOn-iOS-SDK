//
//  ATOfferModel.h
//  AnyThinkSDK
//
//  Created by stephen on 21/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATModel.h"

@interface ATOfferModel : ATModel

@property(nonatomic, readwrite) NSString *resourceID;
@property(nonatomic, readwrite) NSString *offerID;
@property(nonatomic, readwrite) NSString *pkgName;
@property(nonatomic, readwrite) NSString *title;
@property(nonatomic, readwrite) NSString *text;
@property(nonatomic, readwrite) NSInteger rating;
@property(nonatomic, readwrite) NSString *iconURL;
@property(nonatomic, readwrite) NSString *fullScreenImageURL;
@property(nonatomic, readwrite) ATInterstitialType interstitalType;//check the offer for video or image
@property(nonatomic, readwrite) NSString *logoURL;//adv_u
@property(nonatomic, readwrite) NSString *CTA;
@property(nonatomic, readwrite) NSString *videoURL;
@property(nonatomic, readwrite) NSString *storeURL;
@property(nonatomic, readwrite) ATLinkType linkType;
@property(nonatomic, readwrite) NSString *clickURL;
@property(nonatomic, readwrite) NSString *deeplinkUrl;
@property(nonatomic, readwrite) NSString *localResourceID;
@property(nonatomic, readwrite) ATOfferModelType offerModelType;

//banner(myoffer:5.6.6)
@property(nonatomic, readwrite) NSString *bannerImageUrl;
@property(nonatomic, readwrite) NSString *bannerBigImageUrl;
@property(nonatomic, readwrite) NSString *rectangleImageUrl;
@property(nonatomic, readwrite) NSString *homeImageUrl;

@property(nonatomic, readwrite) NSArray<NSString*>* resourceURLs;

@end


