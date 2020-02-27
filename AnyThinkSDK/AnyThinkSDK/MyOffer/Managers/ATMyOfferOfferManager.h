//
//  ATMyOfferOfferManager.h
//  AnyThinkMyOffer
//
//  Created by Martin Lau on 2019/9/23.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATMyOfferSetting.h"
#import "ATMyOfferOfferModel.h"
#import "ATMyOfferInterstitialDelegate.h"
#import "ATMyOfferRewardedVideoDelegate.h"
@interface ATMyOfferOfferManager : NSObject
+(instancetype) sharedManager;
-(BOOL) resourceReadyForOfferModel:(ATMyOfferOfferModel*)offerModel;
-(BOOL) offerReadyForOfferModel:(ATMyOfferOfferModel*)offerModel;
-(ATMyOfferOfferModel*) defaultOfferInOfferModels:(NSArray<ATMyOfferOfferModel*>*)offerModels;
-(void) loadOfferWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting extra:(NSDictionary*)extra completion:(void(^)(NSError *error))completion;
-(void) showInterstitialWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting viewController:(UIViewController*)viewController delegate:(id<ATMyOfferInterstitialDelegate>)delegate;
-(void) showRewardedVideoWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting viewController:(UIViewController*)viewController delegate:(id<ATMyOfferRewardedVideoDelegate>)delegate;
@end
