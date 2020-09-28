//
//  ATMyOfferRewardedVideoAdapter.h
//  AnyThinkMyOfferRewardedVideoAdapter
//
//  Created by Topon on 2019/10/9.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ATMyOfferOfferModel.h"
#import "ATMyOfferSetting.h"

@protocol ATMyOfferRewardedVideoDelegate <NSObject>

-(void) myOfferRewardedVideoFailToShowOffer:(ATMyOfferOfferModel*)offer error:(NSError*)error;
-(void) myOfferRewardedVideoShowOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferRewardedVideoVideoStartOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferRewardedVideoVideoEndOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferRewardedVideoClickOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferRewardedVideoCloseOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferRewardedVideoRewardOffer:(ATMyOfferOfferModel*)offer;
-(NSString*) lifeCircleIDForOffer:(ATMyOfferOfferModel*)offer;

@end

@protocol  ATMyOfferOfferManager <NSObject>
+(instancetype) sharedManager;
-(BOOL) resourceReadyForOfferModel:(ATMyOfferOfferModel*)offerModel;
-(BOOL) offerReadyForOfferModel:(ATMyOfferOfferModel*)offerModel;
-(void) loadOfferWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting extra:(NSDictionary*)extra completion:(void(^)(NSError *error))completion;
-(void) showRewardedVideoWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting viewController:(UIViewController*)viewController delegate:(id<ATMyOfferRewardedVideoDelegate>)delegate;

@end


@interface ATMyOfferRewardedVideoAdapter : NSObject

@end


