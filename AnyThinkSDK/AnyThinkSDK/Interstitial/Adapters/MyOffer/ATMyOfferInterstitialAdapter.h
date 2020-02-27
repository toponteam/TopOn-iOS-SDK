//
//  ATMyOfferInterstitialAdapter.h
//  AnyThinkMyOfferInterstitialAdapter
//
//  Created by Topon on 2019/10/9.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ATMyOfferOfferModel.h"
#import "ATMyOfferSetting.h"

@protocol ATMyOfferInterstitialDelegate<NSObject>
-(void) myOfferIntersititalFailToShowOffer:(ATMyOfferOfferModel*)offer error:(NSError*)error;
-(void) myOfferIntersititalShowOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferInterstitialVideoStartOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferInterstitialVideoEndOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferInterstitialClickOffer:(ATMyOfferOfferModel*)offer;
-(void) myOfferInterstitialCloseOffer:(ATMyOfferOfferModel*)offer;
-(NSString*) lifeCircleIDForOffer:(ATMyOfferOfferModel*)offer;
@end

@protocol  ATMyOfferOfferManager <NSObject>
+(instancetype) sharedManager;
-(BOOL) resourceReadyForOfferModel:(ATMyOfferOfferModel*)offerModel;
-(BOOL) offerReadyForOfferModel:(ATMyOfferOfferModel*)offerModel;
-(void) loadOfferWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting extra:(NSDictionary*)extra completion:(void(^)(NSError *error))completion;
-(void) showInterstitialWithOfferModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting viewController:(UIViewController*)viewController delegate:(id<ATMyOfferInterstitialDelegate>)delegate;

@end

@interface ATMyOfferInterstitialAdapter : NSObject

@end


