//
//  ATMyOfferOfferModel.h
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/23.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATModel.h"
#import "ATMyOfferSetting.h"
typedef NS_ENUM(NSInteger, ATMyOfferScreenOrientation) {
    ATMyOfferScreenOrientationPortrait,
    ATMyOfferScreenOrientationLandscape
};

typedef NS_ENUM(NSInteger, ATMyOfferInterstitialType) {
    ATMyOfferInterstitialVideo = 1,
    ATMyOfferInterstitialPicture
};

typedef NS_ENUM(NSInteger, ATMyOfferJumpType) {
    ATMyOfferJumpTypeAppStore = 1,
    ATMyOfferJumpTypeSafari,
    ATMyOfferJumpTypeInternalBrowser
};

@interface ATMyOfferOfferModel : ATModel
-(instancetype) initWithDictionary:(NSDictionary *)dictionary placeholders:(NSDictionary*)placeholders format:(NSInteger)format setting:(ATMyOfferSetting*)setting;
@property(nonatomic, readonly) NSString *offerID;
@property(nonatomic, readonly) NSString *resourceID;
@property(nonatomic, readonly) NSString *title;
@property(nonatomic, readonly) NSString *text;
@property(nonatomic, readonly) NSString *iconURL;
//@property(nonatomic, readonly) NSString *mainImageURL;//Not being used in v4.5.0, commented out
@property(nonatomic, readonly) NSString *fullScreenImageURL;
@property(nonatomic, readonly) ATMyOfferScreenOrientation imageOrientation;
@property(nonatomic, readonly) NSString *logoURL;
@property(nonatomic, readonly) NSString *CTA;
@property(nonatomic, readonly) NSString *videoURL;
@property(nonatomic, readonly) ATMyOfferInterstitialType interstitalType;
@property(nonatomic, readonly) ATMyOfferScreenOrientation videoOrientation;
@property(nonatomic, readonly) NSString *storeURL;
@property(nonatomic, readonly) BOOL performsAsynchronousRedirection;
@property(nonatomic, readonly) ATMyOfferJumpType jumpType;
//@property(nonatomic, readonly) NSString *deepLink;//Implemented in future version
@property(nonatomic, readonly) NSString *videoStartTKURL;
@property(nonatomic, readonly) NSString *video25TKURL;
@property(nonatomic, readonly) NSString *video50TKURL;
@property(nonatomic, readonly) NSString *video75TKURL;
@property(nonatomic, readonly) NSString *videoEndTKURL;
@property(nonatomic, readonly) NSString *endCardShowTKURL;
@property(nonatomic, readonly) NSString *endCardCloseTKURL;
@property(nonatomic, readonly) NSString *clickURL;
@property(nonatomic, readonly) NSString *impURL;
@property(nonatomic, readonly) NSString *impTKURL;
@property(nonatomic, readonly) NSString *clickTKURL;
@property(nonatomic, readonly) NSInteger dailyCap;
@property(nonatomic, readonly) NSTimeInterval pacing;
@property(nonatomic, readonly) NSDictionary<NSString*, NSString*> *placeholders;
@property(nonatomic, readonly) NSArray<NSString*>* resourceURLs;

//v5.6.6
@property(nonatomic, readonly) NSString *bannerImageUrl;
@property(nonatomic, readonly) NSString *bannerBigImageUrl;
@property(nonatomic, readonly) NSString *rectangleImageUrl;
@property(nonatomic, readonly) NSString *homeImageUrl;
//@property(nonatomic, readonly) NSInteger screenOrientation;

@property(nonatomic, readonly) NSString *pkgName;
@property(nonatomic, readonly) NSString *localResourceID;

+(instancetype) mockOfferModel;
@end


